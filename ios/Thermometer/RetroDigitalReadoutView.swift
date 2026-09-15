import SwiftUI

/// Style 4: Retro Digital Readout. A glowing Nixie-tube/VFD-style numeral
/// readout — warm amber glow behind monospaced digits, a faint glass-tube
/// outline behind the stack, and a slow, subtle flicker. No liquid, no
/// needle.
struct RetroDigitalReadoutView: View {
    let currentTemperature: Double
    let scaleMin: Double
    let scaleMax: Double

    @State private var flickerOpacity: Double = 1.0

    private let amberColor = Color(red: 1.0, green: 0.62, blue: 0.15)
    private let flickerTimer = Timer.publish(every: 0.22, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            // Target size is height-driven so the readout claims the same
            // vertical real estate as the other styles' thermometer graphic;
            // minimumScaleFactor lets it shrink to fit width for wider
            // strings (e.g. negative temperatures) without clipping.
            let digitSize = height * 0.42

            ZStack {
                RoundedRectangle(cornerRadius: width * 0.12, style: .continuous)
                    .fill(amberColor.opacity(0.05))
                    .frame(width: width * 0.96, height: height * 0.9)
                    .position(x: width / 2, y: height / 2)

                RoundedRectangle(cornerRadius: width * 0.12, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1.5)
                    .frame(width: width * 0.96, height: height * 0.9)
                    .position(x: width / 2, y: height / 2)

                Text(digitString)
                    .font(.system(size: digitSize, weight: .semibold, design: .monospaced))
                    .minimumScaleFactor(0.3)
                    .lineLimit(1)
                    .foregroundStyle(amberColor)
                    .shadow(color: amberColor.opacity(0.85), radius: 10)
                    .shadow(color: amberColor.opacity(0.55), radius: 26)
                    .opacity(flickerOpacity)
                    .frame(width: width * 0.86)
                    .position(x: width / 2, y: height / 2)
            }
            .frame(width: width, height: height)
        }
        .onReceive(flickerTimer) { _ in
            withAnimation(.easeInOut(duration: 0.15)) {
                flickerOpacity = Double.random(in: 0.86...1.0)
            }
        }
    }

    private var digitString: String {
        "\(Int(currentTemperature.rounded()))°"
    }
}
