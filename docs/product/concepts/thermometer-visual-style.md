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
- Five styles (Classic, Garden, Galileo, Dial, USSR) are static
  reference photos — they don't consume the temperature at all;
  the actual reading is shown via the shared numeric readout below
  the graphic. Retro is the exception: it composites the real
  current temperature digit-by-digit from individual tube photos.
  Switching styles changes only which graphic is shown, never
  where the real reading comes from.
- `TemperatureColor.color(for:)`/`LiquidColumnView.swift` (the
  original temperature-to-color ramp and animated liquid fill) are
  dead code as of 2026-09-15 — no live style references them since
  all six moved to fixed photos. See
  [style-guide.md#color](../../ui-ux/style-guide.md#color).
- Style selection only takes effect during the data-loaded
  `.ready` phase; loading/permission-denied/error phases always
  render the classic glass tube regardless of the stored
  selection.

## Related

- Feature: [Choose thermometer style](../features/style-choose.md)
- Style guide: [Interaction](../../ui-ux/style-guide.md#interaction),
  [Color](../../ui-ux/style-guide.md#color)
