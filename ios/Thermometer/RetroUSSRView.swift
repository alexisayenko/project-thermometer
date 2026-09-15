import SwiftUI

/// Style 6: Retro USSR. Phase 2: renders a static photoreal "Электроника 7"
/// dot-matrix display reference photo instead of the procedural wood-housing
/// + dot-matrix drawing. The digits no longer track the live reading, so the
/// temperature is communicated by the shared numeric readout below it.
struct RetroUSSRView: View {
    let currentTemperature: Double
    let scaleMin: Double
    let scaleMax: Double

    var body: some View {
        Image("USSRPhoto")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
