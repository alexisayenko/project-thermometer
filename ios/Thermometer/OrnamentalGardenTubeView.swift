import SwiftUI

/// Style 2: Ornamental Garden Tube. Phase 2: renders a static photoreal
/// reference photo instead of the procedural copper-frame + liquid-fill
/// drawing. The temperature is no longer reflected in this graphic — it's
/// communicated by the shared numeric readout below it.
struct OrnamentalGardenTubeView: View {
    let currentTemperature: Double
    let scaleMin: Double
    let scaleMax: Double

    var body: some View {
        Image("GardenPhoto")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
