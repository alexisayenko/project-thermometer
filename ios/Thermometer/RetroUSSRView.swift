import SwiftUI

/// Hardcoded 5-column x 7-row dot-matrix glyphs, in the spirit of the
/// Soviet "Электроника 7" dot-matrix clock display. `#` = lit dot.
private enum DotMatrixFont {
    private static let rawGlyphs: [Character: [String]] = [
        "0": [".###.", "#...#", "#..##", "#.#.#", "##..#", "#...#", ".###."],
        "1": ["..#..", ".##..", "..#..", "..#..", "..#..", "..#..", ".###."],
        "2": [".###.", "#...#", "....#", "...#.", "..#..", ".#...", "#####"],
        "3": ["#####", "...#.", "..#..", "...#.", "....#", "#...#", ".###."],
        "4": ["...#.", "..##.", ".#.#.", "#..#.", "#####", "...#.", "...#."],
        "5": ["#####", "#....", "####.", "....#", "....#", "#...#", ".###."],
        "6": ["..##.", ".#...", "#....", "####.", "#...#", "#...#", ".###."],
        "7": ["#####", "....#", "...#.", "..#..", ".#...", ".#...", ".#..."],
        "8": [".###.", "#...#", "#...#", ".###.", "#...#", "#...#", ".###."],
        "9": [".###.", "#...#", "#...#", ".####", "....#", "...#.", ".##.."],
        "-": [".....", ".....", ".....", "#####", ".....", ".....", "....."],
        "°": [".##..", "#..#.", ".##..", ".....", ".....", ".....", "....."],
    ]

    private static let blank: [String] = Array(repeating: ".....", count: 7)

    static func pattern(for character: Character) -> [[Bool]] {
        (rawGlyphs[character] ?? blank).map { row in row.map { $0 == "#" } }
    }
}

/// One dot-matrix character: a 5x7 grid of small circles. Lit dots glow
/// phosphor-green; unlit dots stay dimly visible so the matrix pattern
/// reads even where a dot is off.
private struct DotMatrixGlyphView: View {
    let pattern: [[Bool]]
    let dotSize: CGFloat
    let spacing: CGFloat

    private let litColor = Color(red: 0.36, green: 1.0, blue: 0.46)
    private let unlitColor = Color(red: 0.09, green: 0.19, blue: 0.11)

    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<pattern.count, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<pattern[row].count, id: \.self) { column in
                        let isLit = pattern[row][column]
                        Circle()
                            .fill(isLit ? litColor : unlitColor)
                            .frame(width: dotSize, height: dotSize)
                            .shadow(color: isLit ? litColor.opacity(0.9) : .clear, radius: dotSize * 0.7)
                    }
                }
            }
        }
    }
}

/// Style 6: Retro USSR. Modeled on the Soviet "Электроника 7" dot-matrix
/// clock — a warm wood-grain housing, a near-black glass front panel, and
/// the current temperature rendered as glowing green dot-matrix digits.
struct RetroUSSRView: View {
    let currentTemperature: Double
    let scaleMin: Double
    let scaleMax: Double

    @State private var flickerOpacity: Double = 1.0
    private let flickerTimer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()

    private let woodGradient = LinearGradient(
        colors: [
            Color(red: 0.44, green: 0.26, blue: 0.11),
            Color(red: 0.66, green: 0.42, blue: 0.19),
            Color(red: 0.44, green: 0.26, blue: 0.11),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    private var digitCharacters: [Character] {
        Array("\(Int(currentTemperature.rounded()))°")
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let frameThickness = width * 0.09
            let innerPadding = width * 0.05
            let contentWidth = max(width - (frameThickness + innerPadding) * 2, 10)

            let dotSpacing: CGFloat = 2
            let interGlyphGap: CGFloat = 7
            let count = max(digitCharacters.count, 1)
            let totalGaps = CGFloat(count - 1) * interGlyphGap
            let totalInnerSpacing = CGFloat(count) * 4 * dotSpacing
            let dotSize = max((contentWidth - totalGaps - totalInnerSpacing) / CGFloat(count * 5), 2)

            ZStack {
                RoundedRectangle(cornerRadius: width * 0.10, style: .continuous)
                    .fill(woodGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: width * 0.10, style: .continuous)
                            .stroke(Color.black.opacity(0.25), lineWidth: 1)
                    )

                RoundedRectangle(cornerRadius: width * 0.07, style: .continuous)
                    .fill(Color(red: 0.03, green: 0.05, blue: 0.04))
                    .padding(frameThickness)

                HStack(spacing: interGlyphGap) {
                    ForEach(Array(digitCharacters.enumerated()), id: \.offset) { _, character in
                        DotMatrixGlyphView(
                            pattern: DotMatrixFont.pattern(for: character),
                            dotSize: dotSize,
                            spacing: dotSpacing
                        )
                    }
                }
                .opacity(flickerOpacity)
            }
            .frame(width: width, height: height)
        }
        .onReceive(flickerTimer) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                flickerOpacity = Double.random(in: 0.92...1.0)
            }
        }
    }
}
