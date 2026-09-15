import Combine
import CoreLocation
import SwiftUI

struct ContentView: View {
    private enum Phase {
        case loading
        case permissionDenied
        case error(String)
        case ready(WeatherSnapshot)
    }

    @StateObject private var locationManager = LocationManager()
    @State private var phase: Phase = .loading
    @AppStorage("thermometerVisualStyle") private var selectedStyle: ThermometerVisualStyle = .classicGlassTube

    private let weatherService = WeatherService()

    /// The retro digit stack is wider and shorter than the tube-shaped
    /// styles, so it gets its own footprint — sized to claim roughly the
    /// same vertical weight the thermometer graphic has in the other styles.
    private var thermometerFrameSize: CGSize {
        selectedStyle == .retroDigitalReadout ? CGSize(width: 220, height: 380) : CGSize(width: 140, height: 380)
    }

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()

            VStack(spacing: 18) {
                header

                Spacer(minLength: 8)

                thermometer
                    .frame(width: thermometerFrameSize.width, height: thermometerFrameSize.height)

                readout

                Spacer(minLength: 8)

                footer

                stylePicker
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
        }
        .onAppear {
            locationManager.requestLocation()
        }
        .onChange(of: locationManager.authorizationStatus) { _, newValue in
            handleAuthorizationChange(newValue)
        }
        .onReceive(locationManager.$coordinate.compactMap { $0 }) { coordinate in
            Task { await loadWeather(latitude: coordinate.latitude, longitude: coordinate.longitude) }
        }
        .onReceive(locationManager.$locationError.compactMap { $0 }) { message in
            phase = .error(message)
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(spacing: 2) {
            Text("Today")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(.secondary)
            Text(Date(), format: .dateTime.month(.wide).day())
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.tertiary)
        }
        .padding(.top, 12)
    }

    @ViewBuilder
    private var thermometer: some View {
        switch phase {
        case .loading:
            ThermometerView(currentTemperature: nil, scaleMin: -10, scaleMax: 30)
        case .ready(let weather):
            let range = scaleRange(low: weather.todayLow, high: weather.todayHigh)
            styledThermometer(temperature: weather.currentTemperature, scaleMin: range.min, scaleMax: range.max)
        case .permissionDenied, .error:
            ThermometerView(currentTemperature: nil, scaleMin: -10, scaleMax: 30)
                .opacity(0.35)
        }
    }

    @ViewBuilder
    private func styledThermometer(temperature: Double, scaleMin: Double, scaleMax: Double) -> some View {
        switch selectedStyle {
        case .classicGlassTube:
            ThermometerView(currentTemperature: temperature, scaleMin: scaleMin, scaleMax: scaleMax)
        case .ornamentalGardenTube:
            OrnamentalGardenTubeView(currentTemperature: temperature, scaleMin: scaleMin, scaleMax: scaleMax)
        case .galileoColumn:
            GalileoColumnView(currentTemperature: temperature, scaleMin: scaleMin, scaleMax: scaleMax)
        case .retroDigitalReadout:
            RetroDigitalReadoutView(currentTemperature: temperature, scaleMin: scaleMin, scaleMax: scaleMax)
        case .dialGauge:
            DialGaugeView(currentTemperature: temperature, scaleMin: scaleMin, scaleMax: scaleMax)
        case .retroUSSR:
            RetroUSSRView(currentTemperature: temperature, scaleMin: scaleMin, scaleMax: scaleMax)
        }
    }

    private var stylePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(ThermometerVisualStyle.allCases) { style in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedStyle = style
                        }
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: style.symbolName)
                                .font(.system(size: 14, weight: .medium))
                            Text(style.displayName)
                                .font(.system(size: 9, weight: .medium, design: .rounded))
                        }
                        .foregroundStyle(selectedStyle == style ? Color.primary : Color.secondary)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(selectedStyle == style ? Color.primary.opacity(0.08) : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
        )
    }

    @ViewBuilder
    private var readout: some View {
        switch phase {
        case .ready(let weather):
            VStack(spacing: 6) {
                // The retro digit stack IS the readout — showing the big
                // number again here would display the temperature twice.
                if selectedStyle != .retroDigitalReadout {
                    Text(formattedTemperature(weather.currentTemperature))
                        .font(.system(size: 68, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                }

                HStack(spacing: 14) {
                    Label(formattedTemperature(weather.todayHigh), systemImage: "arrow.up")
                    Label(formattedTemperature(weather.todayLow), systemImage: "arrow.down")
                }
                .font(.system(.footnote, design: .rounded).weight(.medium))
                .foregroundStyle(.secondary)
            }
        case .loading:
            Text("—°")
                .font(.system(size: 68, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
                .redacted(reason: .placeholder)
        case .permissionDenied, .error:
            EmptyView()
        }
    }

    @ViewBuilder
    private var footer: some View {
        switch phase {
        case .permissionDenied:
            VStack(spacing: 12) {
                Text("Thermometer needs your location to show the temperature where you are.")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button {
                    openSettings()
                } label: {
                    Text("Open Settings")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
            }
        case .error(let message):
            VStack(spacing: 12) {
                Text(message)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button {
                    retry()
                } label: {
                    Label("Retry", systemImage: "arrow.clockwise")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                }
                .buttonStyle(.bordered)
            }
        case .loading, .ready:
            Color.clear.frame(height: 1)
        }
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(uiColor: .systemBackground),
                Color(uiColor: .secondarySystemBackground),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Logic

    private func handleAuthorizationChange(_ status: CLAuthorizationStatus) {
        switch status {
        case .denied, .restricted:
            phase = .permissionDenied
        case .authorizedWhenInUse, .authorizedAlways:
            if case .permissionDenied = phase {
                phase = .loading
            }
        default:
            break
        }
    }

    private func loadWeather(latitude: Double, longitude: Double) async {
        do {
            let snapshot = try await weatherService.fetchWeather(latitude: latitude, longitude: longitude)
            withAnimation(.easeInOut(duration: 0.4)) {
                phase = .ready(snapshot)
            }
        } catch {
            phase = .error(error.localizedDescription)
        }
    }

    private func retry() {
        phase = .loading
        locationManager.requestLocation()
    }

    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func formattedTemperature(_ value: Double) -> String {
        "\(Int(value.rounded()))°"
    }

    private func scaleRange(low: Double, high: Double) -> (min: Double, max: Double) {
        var paddedMin = low - 5
        var paddedMax = high + 5
        if paddedMax - paddedMin < 10 {
            let mid = (paddedMin + paddedMax) / 2
            paddedMin = mid - 5
            paddedMax = mid + 5
        }
        let clampedMin = max(paddedMin, -30)
        let clampedMax = min(paddedMax, 50)
        return (clampedMin, clampedMax)
    }
}
