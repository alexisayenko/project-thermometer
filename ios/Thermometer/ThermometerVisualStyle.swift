import Foundation

enum ThermometerVisualStyle: String, CaseIterable, Identifiable {
    case classicGlassTube
    case ornamentalGardenTube
    case galileoColumn
    case retroDigitalReadout
    case dialGauge
    case retroUSSR

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classicGlassTube: return "Classic"
        case .ornamentalGardenTube: return "Garden"
        case .galileoColumn: return "Galileo"
        case .retroDigitalReadout: return "Retro"
        case .dialGauge: return "Dial"
        case .retroUSSR: return "USSR"
        }
    }

    var symbolName: String {
        switch self {
        case .classicGlassTube: return "thermometer"
        case .ornamentalGardenTube: return "leaf.fill"
        case .galileoColumn: return "circle.grid.3x3.fill"
        case .retroDigitalReadout: return "textformat.123"
        case .dialGauge: return "gauge"
        case .retroUSSR: return "square.grid.3x3.fill"
        }
    }
}
