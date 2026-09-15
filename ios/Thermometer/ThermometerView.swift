import SwiftUI

/// Style 1: Classic Glass Tube. A thin wrapper around the shared liquid
/// column rendering — kept as its own type so call sites read the same as
/// before the style picker existed.
struct ThermometerView: View {
    let currentTemperature: Double?
    let scaleMin: Double
    let scaleMax: Double

    var body: some View {
        LiquidColumnView(currentTemperature: currentTemperature, scaleMin: scaleMin, scaleMax: scaleMax)
    }
}
