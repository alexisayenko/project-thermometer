import SwiftUI

private struct GalileoSphereLayout {
    let calibrationTemp: Double
    let color: Color
    /// 0 = top of the tube, 1 = bottom.
    let fraction: CGFloat
    let isReading: Bool
}

/// A single weighted sphere: a radial-gradient ball with a gentle idle bob
/// (looping, phase-offset per sphere) and a spring resettle whenever its
/// target position changes.
private struct GalileoSphereView: View {
    let color: Color
    let diameter: CGFloat
    let isReading: Bool
    let phase: Double
    let baseY: CGFloat
    let x: CGFloat

    @State private var bob = false
    private let bobAmplitude: CGFloat = 4

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.95), color.opacity(0.65)],
                        center: .topLeading,
                        startRadius: 1,
                        endRadius: diameter
                    )
                )
                .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))

            if isReading {
                Circle()
                    .stroke(Color.black.opacity(0.55), lineWidth: 5)
                    .frame(width: diameter + 10, height: diameter + 10)
                Circle()
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: diameter + 10, height: diameter + 10)
            }
        }
        .frame(width: diameter, height: diameter)
        .position(x: x, y: baseY + (bob ? -bobAmplitude : bobAmplitude))
        .animation(.spring(response: 0.9, dampingFraction: 0.75), value: baseY)
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 2.4)
                    .repeatForever(autoreverses: true)
                    .delay(phase)
            ) {
                bob = true
            }
        }
    }
}

/// Style 3: Galileo Column. A sealed glass cylinder (no bulb) holding 5
/// weighted, calibrated spheres. Each sphere's vertical position is a
/// function of `currentTemp - sphere.calibrationTemp`: spheres calibrated
/// below the current temperature float near the top, ones calibrated above
/// it sink toward the bottom. The reading is the lowest of the floating
/// spheres, marked with a subtle ring.
struct GalileoColumnView: View {
    let currentTemperature: Double
    let scaleMin: Double
    let scaleMax: Double

    private let calibrationTemps: [Double] = [-10, 0, 10, 20, 30]

    var body: some View {
        GeometryReader { geometry in
            let width = min(geometry.size.width, geometry.size.height * 0.30)
            let height = geometry.size.height
            let sphereDiameter = width * 0.62
            let inset = sphereDiameter * 0.62
            let travel = max(height - inset * 2, 1)
            let layouts = Self.layouts(
                currentTemperature: currentTemperature,
                scaleMin: scaleMin,
                scaleMax: scaleMax,
                calibrationTemps: calibrationTemps,
                sphereDiameter: sphereDiameter,
                travel: travel
            )
            // Draw the reading sphere last so its highlight ring always sits
            // on top, even if a neighboring sphere's layout still slightly
            // overlaps it.
            let renderOrder = layouts.enumerated().sorted { lhs, rhs in
                (lhs.element.isReading ? 1 : 0) < (rhs.element.isReading ? 1 : 0)
            }

            ZStack {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.20), Color.white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: width, height: height)

                Capsule()
                    .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                    .frame(width: width, height: height)

                ForEach(renderOrder, id: \.element.calibrationTemp) { index, layout in
                    GalileoSphereView(
                        color: layout.color,
                        diameter: sphereDiameter,
                        isReading: layout.isReading,
                        phase: Double(index) * 0.45,
                        baseY: inset + travel * layout.fraction,
                        x: width / 2
                    )
                }
            }
            .frame(width: geometry.size.width, height: height)
        }
    }

    /// Maps calibration temperatures to normalized vertical fractions
    /// (0 = top, 1 = bottom), keeps them in sorted order with a minimum
    /// visual gap — derived from the actual sphere size so neighboring
    /// spheres don't visually overlap — then re-centers the whole stack
    /// within the tube's usable band so it spreads across most of the
    /// tube's vertical extent instead of clumping. Also picks the
    /// "reading" sphere: the one with the highest calibration temp still
    /// at or below the current temperature (falling back to the coldest
    /// sphere if the current temperature is below every calibration point).
    private static func layouts(
        currentTemperature: Double,
        scaleMin: Double,
        scaleMax: Double,
        calibrationTemps: [Double],
        sphereDiameter: CGFloat,
        travel: CGFloat
    ) -> [GalileoSphereLayout] {
        let range = max(scaleMax - scaleMin, 1)
        let amplitude: Double = 0.46

        var raw: [(calibration: Double, fraction: CGFloat)] = calibrationTemps.map { calibration in
            let delta = currentTemperature - calibration
            let normalized = min(max(delta / range, -1), 1)
            return (calibration, CGFloat(0.5 - normalized * amplitude))
        }
        raw.sort { $0.fraction < $1.fraction }

        // Require neighboring centers to be at least ~1.08x the sphere
        // diameter apart (expressed as a fraction of the usable travel) so
        // spheres read as distinct, only slightly touching at most.
        let minGap: CGFloat = travel > 0 ? (sphereDiameter * 1.08) / travel : 0.14
        for i in 1..<raw.count {
            if raw[i].fraction < raw[i - 1].fraction + minGap {
                raw[i].fraction = raw[i - 1].fraction + minGap
            }
        }

        // Re-center (and, only if it still overflows, uniformly compress)
        // the whole stack within the usable band instead of clamping each
        // sphere independently — independent clamping was reintroducing
        // overlap at the band's edges.
        let band: (lower: CGFloat, upper: CGFloat) = (0.04, 0.96)
        let minFraction = raw.first?.fraction ?? band.lower
        let maxFraction = raw.last?.fraction ?? band.upper
        let usedSpan = max(maxFraction - minFraction, 0.0001)
        let available = band.upper - band.lower
        if usedSpan > available {
            let scale = available / usedSpan
            for i in raw.indices {
                raw[i].fraction = band.lower + (raw[i].fraction - minFraction) * scale
            }
        } else {
            let shift = band.lower - minFraction + (available - usedSpan) / 2
            for i in raw.indices {
                raw[i].fraction += shift
            }
        }

        let floatingCalibrations = calibrationTemps.filter { $0 <= currentTemperature }
        let readingCalibration = floatingCalibrations.max() ?? calibrationTemps.min()

        return raw.map { entry in
            GalileoSphereLayout(
                calibrationTemp: entry.calibration,
                color: TemperatureColor.color(for: entry.calibration),
                fraction: entry.fraction,
                isReading: entry.calibration == readingCalibration
            )
        }
    }
}
