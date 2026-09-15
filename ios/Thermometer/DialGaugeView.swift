import SwiftUI

/// Style 5: Dial Gauge. Phase 2: renders a static photoreal analog-dial
/// reference photo instead of the procedural arc + needle drawing. The
/// needle no longer points at the live reading, so the temperature is
/// communicated by the shared numeric readout below it.
struct DialGaugeView: View {
    let currentTemperature: Double
    let scaleMin: Double
    let scaleMax: Double

    var body: some View {
        Image("DialPhoto")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
