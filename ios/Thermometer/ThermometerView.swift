import SwiftUI
import UIKit

/// The glass tube + bulb silhouette. A rounded tube overlapping a circular
/// bulb at the bottom, filled as one shape (non-zero winding rule).
struct ThermometerGlassShape: Shape {
    func path(in rect: CGRect) -> Path {
        let bulbDiameter = rect.width
        let tubeWidth = rect.width * 0.44
        let tubeX = rect.midX - tubeWidth / 2
        let tubeTopY = rect.minY
        let tubeBottomY = rect.maxY - bulbDiameter * 0.62

        var path = Path()
        let tubeRect = CGRect(x: tubeX, y: tubeTopY, width: tubeWidth, height: max(tubeBottomY - tubeTopY, 0))
        path.addRoundedRect(in: tubeRect, cornerSize: CGSize(width: tubeWidth / 2, height: tubeWidth / 2))

        let bulbRect = CGRect(x: rect.midX - bulbDiameter / 2, y: rect.maxY - bulbDiameter, width: bulbDiameter, height: bulbDiameter)
        path.addEllipse(in: bulbRect)

        return path
    }
}

/// Smooth (non-stepped) temperature -> color mapping.
enum TemperatureColor {
    private static let stops: [(Double, Color)] = [
        (-20, Color(red: 0.13, green: 0.20, blue: 0.58)),
        (0,   Color(red: 0.16, green: 0.55, blue: 0.86)),
        (15,  Color(red: 0.15, green: 0.72, blue: 0.47)),
        (25,  Color(red: 0.96, green: 0.70, blue: 0.18)),
        (35,  Color(red: 0.86, green: 0.20, blue: 0.12)),
    ]

    static func color(for temperature: Double) -> Color {
        guard let first = stops.first, let last = stops.last else { return .gray }
        if temperature <= first.0 { return first.1 }
        if temperature >= last.0 { return last.1 }

        for index in 0..<(stops.count - 1) {
            let lower = stops[index]
            let upper = stops[index + 1]
            if temperature >= lower.0 && temperature <= upper.0 {
                let t = (temperature - lower.0) / (upper.0 - lower.0)
                return Color.interpolate(lower.1, upper.1, t)
            }
        }
        return last.1
    }
}

private extension Color {
    static func interpolate(_ a: Color, _ b: Color, _ t: Double) -> Color {
        let clampedT = min(max(t, 0), 1)
        var ra: CGFloat = 0, ga: CGFloat = 0, ba: CGFloat = 0, aa: CGFloat = 0
        var rb: CGFloat = 0, gb: CGFloat = 0, bb: CGFloat = 0, ab: CGFloat = 0
        UIColor(a).getRed(&ra, green: &ga, blue: &ba, alpha: &aa)
        UIColor(b).getRed(&rb, green: &gb, blue: &bb, alpha: &ab)
        return Color(
            red: Double(ra + (rb - ra) * clampedT),
            green: Double(ga + (gb - ga) * clampedT),
            blue: Double(ba + (bb - ba) * clampedT),
            opacity: Double(aa + (ab - aa) * clampedT)
        )
    }
}

private struct Bubble: Identifiable {
    let id = UUID()
    let xFraction: CGFloat
    let diameter: CGFloat
    let duration: Double
    let delay: Double
}

private struct BubbleLayer: View {
    let width: CGFloat
    let liquidHeight: CGFloat
    let bubbles: [Bubble]

    var body: some View {
        ZStack(alignment: .bottom) {
            ForEach(bubbles) { bubble in
                RisingBubble(bubble: bubble, liquidHeight: liquidHeight)
                    .position(x: width * bubble.xFraction, y: max(liquidHeight - bubble.diameter, 0))
            }
        }
        .frame(width: width, height: liquidHeight, alignment: .bottom)
    }
}

private struct RisingBubble: View {
    let bubble: Bubble
    let liquidHeight: CGFloat
    @State private var rise = false

    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.4))
            .frame(width: bubble.diameter, height: bubble.diameter)
            .offset(y: rise ? -liquidHeight : 0)
            .opacity(rise ? 0 : 0.7)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: bubble.duration)
                        .repeatForever(autoreverses: false)
                        .delay(bubble.delay)
                ) {
                    rise = true
                }
            }
    }
}

struct ThermometerView: View {
    let currentTemperature: Double?
    let scaleMin: Double
    let scaleMax: Double

    @State private var animatedFraction: CGFloat = 0
    @State private var glow = false
    @State private var shimmer = false

    private let bubbles: [Bubble] = (0..<5).map { index in
        Bubble(
            xFraction: CGFloat.random(in: 0.3...0.7),
            diameter: CGFloat.random(in: 4...9),
            duration: Double.random(in: 2.8...4.4),
            delay: Double(index) * 0.55 + Double.random(in: 0...0.5)
        )
    }

    private var isPlaceholder: Bool { currentTemperature == nil }

    private var fraction: CGFloat {
        guard let currentTemperature else { return 0.08 }
        guard scaleMax > scaleMin else { return 0 }
        let clamped = min(max(currentTemperature, scaleMin), scaleMax)
        return CGFloat((clamped - scaleMin) / (scaleMax - scaleMin))
    }

    private var liquidColor: Color {
        guard let currentTemperature else { return Color(white: 0.7) }
        return TemperatureColor.color(for: currentTemperature)
    }

    var body: some View {
        GeometryReader { geometry in
            let width = min(geometry.size.width, geometry.size.height * 0.34)
            let height = geometry.size.height

            ZStack {
                ThermometerGlassShape()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.22), Color.white.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: width, height: height)

                ZStack(alignment: .bottom) {
                    LinearGradient(
                        colors: [liquidColor.opacity(0.82), liquidColor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: max(height * animatedFraction, 2))

                    BubbleLayer(width: width, liquidHeight: max(height * animatedFraction, 2), bubbles: bubbles)
                        .opacity(isPlaceholder ? 0 : 1)
                }
                .frame(width: width, height: height, alignment: .bottom)
                .mask(ThermometerGlassShape().frame(width: width, height: height))

                if isPlaceholder {
                    ThermometerGlassShape()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.02), Color.white.opacity(0.28), Color.white.opacity(0.02)],
                                startPoint: shimmer ? .topLeading : .bottomTrailing,
                                endPoint: shimmer ? .bottomTrailing : .topLeading
                            )
                        )
                        .frame(width: width, height: height)
                }

                Ellipse()
                    .fill(liquidColor.opacity(glow ? 0.6 : 0.25))
                    .frame(width: width * 1.15, height: 20)
                    .blur(radius: 12)
                    .position(x: width / 2, y: height * (1 - animatedFraction))
                    .opacity(isPlaceholder ? 0 : 1)
                    .allowsHitTesting(false)

                ThermometerGlassShape()
                    .stroke(Color.white.opacity(0.55), lineWidth: 1.5)
                    .frame(width: width, height: height)
            }
            .frame(width: geometry.size.width, height: height)
        }
        .onAppear {
            withAnimation(.spring(response: 1.15, dampingFraction: 0.78)) {
                animatedFraction = fraction
            }
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                glow.toggle()
            }
            withAnimation(.linear(duration: 2.4).repeatForever(autoreverses: false)) {
                shimmer.toggle()
            }
        }
        .onChange(of: currentTemperature) { _, _ in
            withAnimation(.spring(response: 1.15, dampingFraction: 0.78)) {
                animatedFraction = fraction
            }
        }
    }
}
