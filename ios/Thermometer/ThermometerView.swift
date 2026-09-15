import SwiftUI

/// Style 1: Classic Glass Tube. Phase 2: renders a static photoreal
/// reference photo instead of the procedural liquid column. The
/// temperature is no longer reflected in this graphic — it's communicated
/// by the shared numeric readout below it.
struct ThermometerView: View {
    let currentTemperature: Double?
    let scaleMin: Double
    let scaleMax: Double

    var body: some View {
        Image("ClassicPhoto")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
