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

    private let weatherService = WeatherService()

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()

            VStack(spacing: 18) {
                header

                Spacer(minLength: 8)

                thermometer
                    .frame(width: 140, height: 380)

                readout

                Spacer(minLength: 8)

                footer
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
            ThermometerView(currentTemperature: weather.currentTemperature, scaleMin: range.min, scaleMax: range.max)
        case .permissionDenied, .error:
            ThermometerView(currentTemperature: nil, scaleMin: -10, scaleMax: 30)
                .opacity(0.35)
        }
    }

    @ViewBuilder
    private var readout: some View {
        switch phase {
        case .ready(let weather):
            VStack(spacing: 6) {
                Text(formattedTemperature(weather.currentTemperature))
                    .font(.system(size: 68, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())

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
