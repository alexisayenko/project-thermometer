import SwiftUI

/// Style 3: Galileo Column. Phase 2: renders a static photoreal Galileo
/// thermometer reference photo instead of the procedural sphere-stack
/// drawing. The spheres no longer reposition for the live reading, so the
/// temperature is communicated by the shared numeric readout below it.
struct GalileoColumnView: View {
    let currentTemperature: Double
    let scaleMin: Double
    let scaleMax: Double

    var body: some View {
        Image("GalileoPhoto")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
