# Thermometer Visual Style

The set of interchangeable visual renderings the current
temperature reading can be displayed as. Exactly one is active at
a time.

## Data model

- `ThermometerVisualStyle` (`ios/Thermometer/ThermometerVisualStyle.swift`):
  a `String`-backed, `CaseIterable`, `Identifiable` enum. Cases
  (ground truth as of 2026-09-15): `classicGlassTube`,
  `ornamentalGardenTube`, `galileoColumn`, `retroDigitalReadout`,
  `dialGauge`, `retroUSSR`.
- Each case carries a `displayName` (short label shown in the
  picker) and `symbolName` (SF Symbol shown in the picker).
- Persisted by raw string value via
  `@AppStorage("thermometerVisualStyle")` on `ContentView`;
  survives app relaunch. Default: `.classicGlassTube`.

## Invariants

- Exactly one style is selected at all times — the enum plus its
  `@AppStorage` default means there is no "none" state.
- Every style consumes the same two inputs: current temperature
  and today's dynamic min/max scale (computed once in
  `ContentView.scaleRange`). Switching styles changes only how the
  reading is drawn, never what data is shown.
- The temperature-to-color ramp (`TemperatureColor.color(for:)`)
  is the shared coloring base across styles; some styles layer
  additional fixed, non-temperature-driven chrome on top — see
  [style-guide.md#color](../../ui-ux/style-guide.md#color).
- Style selection only takes effect during the data-loaded
  `.ready` phase; loading/permission-denied/error phases always
  render the classic glass tube regardless of the stored
  selection.

## Related

- Feature: [Choose thermometer style](../features/style-choose.md)
- Style guide: [Interaction](../../ui-ux/style-guide.md#interaction),
  [Color](../../ui-ux/style-guide.md#color)
