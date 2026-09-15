import SwiftUI

/// Style 4: Retro Digital Readout. Phase 3: renders the live temperature as
/// a row of individual Nixie-tube photos (one glass tube per digit, plus a
/// minus tube when negative) followed by a small metal-faceplate °C unit
/// tile, instead of a single static decorative photo. Digit count is
/// derived from the value, so it scales from a bare single digit up through
/// a signed two-digit reading without any hardcoded slot count.
struct RetroDigitalReadoutView: View {
    let currentTemperature: Double
    let scaleMin: Double
    let scaleMax: Double

    /// All tube photos (digits and minus) share the same framing/composition
    /// at 1024x1536, so one aspect ratio describes every tube.
    private static let tubeAspectRatio: CGFloat = 1024.0 / 1536.0
    private static let tubeSpacingFraction: CGFloat = 0.06

    /// Ordered glyphs for the readout, e.g. -12 -> ["-", "1", "2"]. Rounds
    /// to the nearest whole degree to match the shared numeric readout in
    /// ContentView (`Int(value.rounded())`).
    private var digitGlyphs: [String] {
        let rounded = Int(currentTemperature.rounded())
        var glyphs = String(abs(rounded)).map { String($0) }
        if rounded < 0 {
            glyphs.insert("-", at: 0)
        }
        return glyphs
    }

    private func imageName(for glyph: String) -> String {
        glyph == "-" ? "NixieMinus" : "NixieDigit\(glyph)"
    }

    var body: some View {
        GeometryReader { geometry in
            let glyphs = digitGlyphs
            let tubeCount = CGFloat(glyphs.count)
            let spacingFraction = tubeCount > 1 ? Self.tubeSpacingFraction : 0
            let rowAspect = tubeCount * Self.tubeAspectRatio + max(tubeCount - 1, 0) * spacingFraction

            let tubeHeight = rowAspect > 0
                ? min(geometry.size.height, geometry.size.width / rowAspect)
                : 0
            let tubeWidth = tubeHeight * Self.tubeAspectRatio
            let spacing = tubeHeight * spacingFraction

            HStack(spacing: spacing) {
                ForEach(Array(glyphs.enumerated()), id: \.offset) { _, glyph in
                    Image(imageName(for: glyph))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: tubeWidth, height: tubeHeight)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Image("NixieUnitC")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: tubeHeight * 0.32)
                    .padding(.trailing, tubeWidth * 0.04)
                    .padding(.bottom, tubeHeight * 0.02)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
