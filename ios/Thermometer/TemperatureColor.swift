import SwiftUI
import UIKit

/// Smooth (non-stepped) temperature -> color mapping. Shared by every
/// thermometer visual style so cool/warm reads consistently across them.
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
