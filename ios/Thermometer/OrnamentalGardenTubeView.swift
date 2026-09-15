import SwiftUI

/// A simple Path-drawn ornamental cap: a central knob flanked by two petal
/// flourishes, sitting on a rounded base bar. Reads as "ornamental end cap"
/// without being a literal fleur-de-lis.
private struct OrnamentCapShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let knobDiameter = min(rect.width * 0.34, rect.height * 0.95)
        let knobRect = CGRect(
            x: rect.midX - knobDiameter / 2,
            y: rect.minY,
            width: knobDiameter,
            height: knobDiameter
        )
        path.addEllipse(in: knobRect)

        let petalWidth = rect.width * 0.30
        let petalHeight = rect.height * 0.75
        let petalY = rect.minY + rect.height * 0.18
        path.addEllipse(in: CGRect(x: rect.minX, y: petalY, width: petalWidth, height: petalHeight))
        path.addEllipse(in: CGRect(x: rect.maxX - petalWidth, y: petalY, width: petalWidth, height: petalHeight))

        let barHeight = rect.height * 0.30
        let barRect = CGRect(x: rect.minX, y: rect.maxY - barHeight, width: rect.width, height: barHeight)
        path.addRoundedRect(in: barRect, cornerSize: CGSize(width: barHeight / 2, height: barHeight / 2))

        return path
    }
}

/// Style 2: Ornamental Garden Tube. Reuses the exact liquid-fill + color
/// ramp + glow + bubbles mechanism from `LiquidColumnView` (same as style
/// 1), staged inside a weathered copper/bronze frame with ornamental end
/// caps top and bottom.
struct OrnamentalGardenTubeView: View {
    let currentTemperature: Double
    let scaleMin: Double
    let scaleMax: Double

    private let copperGradient = LinearGradient(
        colors: [
            Color(red: 0.82, green: 0.58, blue: 0.32),
            Color(red: 0.58, green: 0.35, blue: 0.15),
            Color(red: 0.88, green: 0.68, blue: 0.42),
            Color(red: 0.46, green: 0.26, blue: 0.11),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let innerWidth = width * 0.60
            let innerHeight = height * 0.78
            let railWidth = width * 0.10
            let railGap = width * 0.04
            let capHeight = height * 0.11
            let railHeight = innerHeight * 0.92
            let railOffsetX = innerWidth / 2 + railGap + railWidth / 2
            let capSpan = innerWidth + 2 * (railGap + railWidth)

            ZStack {
                RoundedRectangle(cornerRadius: railWidth / 2, style: .continuous)
                    .fill(copperGradient)
                    .frame(width: railWidth, height: railHeight)
                    .position(x: width / 2 - railOffsetX, y: height / 2)
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)

                RoundedRectangle(cornerRadius: railWidth / 2, style: .continuous)
                    .fill(copperGradient)
                    .frame(width: railWidth, height: railHeight)
                    .position(x: width / 2 + railOffsetX, y: height / 2)
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)

                LiquidColumnView(currentTemperature: currentTemperature, scaleMin: scaleMin, scaleMax: scaleMax)
                    .frame(width: innerWidth, height: innerHeight)
                    .position(x: width / 2, y: height / 2)

                OrnamentCapShape()
                    .fill(copperGradient)
                    .frame(width: capSpan, height: capHeight)
                    .position(x: width / 2, y: height / 2 - innerHeight / 2 - capHeight * 0.45)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)

                OrnamentCapShape()
                    .fill(copperGradient)
                    .rotationEffect(.degrees(180))
                    .frame(width: capSpan, height: capHeight)
                    .position(x: width / 2, y: height / 2 + innerHeight / 2 + capHeight * 0.45)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            .frame(width: width, height: height)
        }
    }
}
