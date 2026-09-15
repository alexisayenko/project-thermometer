import SwiftUI

/// Style 5: Dial Gauge. A classic analog dial — semicircular arc with tick
/// marks spanning the dynamic min/max range, a spring-animated needle
/// pointing at the current temperature, and a numeric readout below the
/// pivot. The arc is filled with the shared cool-to-hot color ramp so the
/// dial itself reads the temperature, not just the needle.
struct DialGaugeView: View {
    let currentTemperature: Double
    let scaleMin: Double
    let scaleMax: Double

    private var range: Double { max(scaleMax - scaleMin, 1) }

    private var fraction: Double {
        min(max((currentTemperature - scaleMin) / range, 0), 1)
    }

    private var tickInterval: Double {
        range <= 20 ? 5 : (range <= 60 ? 10 : 20)
    }

    private var ticks: [Double] {
        var values: [Double] = []
        var value = scaleMin
        while value <= scaleMax + 0.001 {
            values.append(value)
            value += tickInterval
        }
        return values
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let center = CGPoint(x: width / 2, y: height * 0.54)
            let radius = min(width / 2 - 14, height * 0.42)

            ZStack {
                arcPath(center: center, radius: radius)
                    .stroke(arcGradient, style: StrokeStyle(lineWidth: 10, lineCap: .round))

                tickPath(center: center, radius: radius)
                    .stroke(Color.primary.opacity(0.45), lineWidth: 1.5)

                needle(center: center, radius: radius)

                Circle()
                    .fill(Color.primary.opacity(0.85))
                    .frame(width: 14, height: 14)
                    .position(center)

                Text(formattedTemperature)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(TemperatureColor.color(for: currentTemperature))
                    .contentTransition(.numericText())
                    .position(x: center.x, y: center.y + radius * 0.52)
            }
            .frame(width: width, height: height)
        }
    }

    // MARK: - Drawing

    /// Point on the dial's semicircle: `fraction` 0 = coldest (left, 9
    /// o'clock), 0.5 = top (12 o'clock), 1 = hottest (right, 3 o'clock).
    private func pointOnArc(fraction f: Double, radius: CGFloat, center: CGPoint) -> CGPoint {
        let angle = Angle.degrees(180 * f - 180).radians
        return CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
    }

    private func arcPath(center: CGPoint, radius: CGFloat) -> Path {
        Path { path in
            let steps = 96
            for i in 0...steps {
                let f = Double(i) / Double(steps)
                let point = pointOnArc(fraction: f, radius: radius, center: center)
                if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
            }
        }
    }

    private func tickPath(center: CGPoint, radius: CGFloat) -> Path {
        Path { path in
            for value in ticks {
                let f = (value - scaleMin) / range
                let outer = pointOnArc(fraction: f, radius: radius + 6, center: center)
                let inner = pointOnArc(fraction: f, radius: radius - 9, center: center)
                path.move(to: outer)
                path.addLine(to: inner)
            }
        }
    }

    @ViewBuilder
    private func needle(center: CGPoint, radius: CGFloat) -> some View {
        let rotation = Angle.degrees((fraction - 0.5) * 180)
        let length = radius * 0.9

        Capsule()
            .fill(TemperatureColor.color(for: currentTemperature))
            .frame(width: 5, height: length)
            .offset(y: -length / 2)
            .rotationEffect(rotation)
            .position(center)
            .animation(.spring(response: 0.55, dampingFraction: 0.7), value: currentTemperature)
    }

    private var arcGradient: LinearGradient {
        let stops = 6
        let colors = (0...stops).map { index -> Color in
            TemperatureColor.color(for: scaleMin + range * Double(index) / Double(stops))
        }
        return LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
    }

    private var formattedTemperature: String {
        "\(Int(currentTemperature.rounded()))°"
    }
}
