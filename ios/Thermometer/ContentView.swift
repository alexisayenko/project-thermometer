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
    @AppStorage("isTextHidden") private var isTextHidden: Bool = false

    private let weatherService = WeatherService()

    /// The thermometer graphic claims all vertical space left over once the
    /// header, readout, and style picker have taken theirs, capped at a
    /// height:width ratio as a safety ceiling against an absurdly tall box
    /// (e.g. a very short header/readout on a tall screen). All six styles
    /// now aspect-fit a reference photo, and the tallest of them (the
    /// portrait ones, ~1.5:1) comfortably clears this cap without being
    /// constrained by it, so it doesn't need loosening for any current style.
    ///
    /// In the immersive (chrome-hidden) state there's no header/readout/
    /// picker left to protect, so the cap is dropped entirely and the goal
    /// changes to: push height as far as the available box allows. Width is
    /// deliberately left generous — much larger than the screen itself —
    /// so `.aspectRatio(contentMode: .fit)` is always height-bound, never
    /// width-bound. Any excess width simply overflows past the screen edges
    /// uncropped by anything here, which is fine since nothing else needs
    /// that space.
    ///
    /// The multiplier below is intentionally > 1.0: the reference photos
    /// carry their own internal letterboxing, so a box exactly the size of
    /// `available` still renders visible content noticeably short of
    /// `available.height`. Overshooting the box lets the *visible* content
    /// approach ~90% of the screen. The frame that places this box
    /// (see `body`) anchors it to the bottom in immersive mode, so the
    /// overshoot spills upward into the top clearance instead of being
    /// clipped at the bottom.
    private func thermometerSize(in available: CGSize, immersive: Bool) -> CGSize {
        guard available.width > 0, available.height > 0 else { return .zero }
        if immersive {
            return CGSize(width: available.height * 4, height: available.height * 1.08)
        }
        let maxAspect: CGFloat = 1.65
        let widthBoundHeight = available.width * maxAspect
        if widthBoundHeight <= available.height {
            return CGSize(width: available.width, height: widthBoundHeight)
        } else {
            return CGSize(width: available.height / maxAspect, height: available.height)
        }
    }

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()

            VStack(spacing: 14) {
                if !isTextHidden {
                    header
                        .transition(.opacity)
                }

                GeometryReader { geometry in
                    let size = thermometerSize(in: geometry.size, immersive: isTextHidden)
                    // RetroDigitalReadoutView renders a row of N tube images
                    // rather than one aspect-fit image, so it can't share the
                    // oversized-width box the other styles rely on (that
                    // width is deliberately wider than the screen so a
                    // single image is always height-bound, see
                    // thermometerSize) -- for a multi-tube row that same
                    // oversized width lets the row grow past the real screen
                    // edges. Give it the real available width instead; the
                    // height budget (size.height) is unaffected and still
                    // correctly reflects the immersive/chrome-visible cap.
                    let frameWidth = isRowLayoutStyle ? geometry.size.width : size.width
                    thermometer
                        .frame(width: frameWidth, height: size.height)
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height,
                            // Immersive mode overshoots the box height on
                            // purpose (see thermometerSize) to reach ~90% of
                            // screen height; bottom-anchoring sends that
                            // overshoot upward into the top clearance rather
                            // than centering it as equal top/bottom gaps,
                            // which also matches the requested "sit lower,
                            // not centered" placement. Chrome-visible mode
                            // never overshoots, so centering there is
                            // unaffected.
                            alignment: isTextHidden ? .bottom : .center
                        )
                }
                .gesture(styleSwipeGesture)

                if !isTextHidden {
                    readout
                        .transition(.opacity)
                }

                // The footer only carries real content (retry/settings
                // prompts) in the error/permission-denied phases; in
                // loading/ready it's an invisible 1pt spacer. Skip it (and
                // the VStack spacing it would otherwise claim) in immersive
                // mode whenever it has nothing to show, reclaiming that
                // space for the thermometer's height budget.
                if !isTextHidden || footerNeedsSpace {
                    footer
                }

                if !isTextHidden {
                    stylePicker
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 28)
            // In immersive mode there's no header/readout/picker/footer
            // competing for vertical space (see footerNeedsSpace above), so
            // this padding is the only thing still eating into the
            // ~95%-of-available-height target besides the safe area, which
            // stays respected. Shrink it to a sliver of top clearance and
            // drop the bottom padding entirely; the chrome-visible state
            // keeps its normal 16/16 padding untouched.
            .padding(.top, isTextHidden ? 4 : 16)
            .padding(.bottom, isTextHidden ? 0 : 16)

            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isTextHidden.toggle()
                        }
                    } label: {
                        Image(systemName: isTextHidden ? "eye.slash" : "eye")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.secondary)
                            .padding(10)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(.top, 6)
            .padding(.trailing, 14)
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

    /// True only while the active thermometer is RetroDigitalReadoutView's
    /// multi-tube row, which needs the real screen width rather than the
    /// oversized width box the single-image styles use (see the comment at
    /// its call site in `body`).
    private var isRowLayoutStyle: Bool {
        if case .ready = phase, selectedStyle == .retroDigitalReadout {
            return true
        }
        return false
    }

    /// Swipe left/right on the thermometer graphic to cycle styles, wrapping
    /// at the ends, as an alternative to tapping the picker row below. The
    /// minimum distance keeps small accidental touches from firing it, and
    /// requiring the horizontal move to dominate the vertical one keeps it
    /// from reacting to stray vertical drags.
    private var styleSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = value.translation.height
                guard abs(horizontal) > abs(vertical), abs(horizontal) > 24 else { return }
                cycleStyle(forward: horizontal < 0)
            }
    }

    private func cycleStyle(forward: Bool) {
        let cases = ThermometerVisualStyle.allCases
        guard let currentIndex = cases.firstIndex(of: selectedStyle) else { return }
        let count = cases.count
        let nextIndex = forward ? (currentIndex + 1) % count : (currentIndex - 1 + count) % count
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedStyle = cases[nextIndex]
        }
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
                        VStack(spacing: 1) {
                            Image(systemName: style.symbolName)
                                .font(.system(size: 13, weight: .medium))
                            Text(style.displayName)
                                .font(.system(size: 8, weight: .medium, design: .rounded))
                        }
                        .foregroundStyle(selectedStyle == style ? Color.primary : Color.secondary)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(selectedStyle == style ? Color.primary.opacity(0.08) : Color.clear)
                        )
                        // Visual pill stays slim; this invisible frame keeps
                        // the actual tap target at the ~44pt HIG minimum.
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(height: 44)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(uiColor: .secondarySystemBackground))
                .frame(height: 36)
        )
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

    private var footerNeedsSpace: Bool {
        switch phase {
        case .permissionDenied, .error:
            return true
        case .loading, .ready:
            return false
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
