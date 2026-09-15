# Choose thermometer style

The user can switch which visual style the thermometer reading
renders as, and the choice persists across app launches.

## What it does

- A horizontal row of tappable style icons sits below the numeric
  readout (`ContentView.swift`, `stylePicker`). Each icon shows an
  SF Symbol + short label for one style.
- Tapping a style selects it with an `.easeInOut(duration: 0.2)`
  animation.
- The selection is persisted via
  `@AppStorage("thermometerVisualStyle")`, so it survives app
  relaunch. Default: Classic.
- The picker only swaps the visual during the data-loaded `.ready`
  phase. Loading, permission-denied, and error states always show
  the classic glass tube (dimmed for the latter two), regardless
  of the stored selection.
- Every style consumes the same inputs — current temperature and
  today's dynamic min/max scale — so switching styles changes only
  presentation, never the data shown.

## Available styles

From `ThermometerVisualStyle.swift` (ground truth as of
2026-09-15 — six cases):

1. **Classic** (`classicGlassTube`) — the original animated glass
   tube: liquid fill on the shared temperature color ramp, with a
   glow pulse and rising bubbles (`ThermometerView.swift`).
2. **Garden** (`ornamentalGardenTube`) — the same liquid-fill
   mechanism as Classic, staged inside a copper/bronze frame with
   ornamental end caps (`OrnamentalGardenTubeView.swift`).
3. **Galileo** (`galileoColumn`) — five weighted spheres in a
   sealed glass column; each sphere's vertical position is driven
   by `currentTemp - sphere.calibrationTemp`, and the lowest
   floating sphere is the reading (`GalileoColumnView.swift`).
4. **Retro** (`retroDigitalReadout`) — a glowing Nixie/VFD-style
   amber numeral readout with a subtle flicker; no liquid or
   needle (`RetroDigitalReadoutView.swift`).
5. **Dial** (`dialGauge`) — an analog semicircular dial with tick
   marks across the dynamic scale and a spring-animated needle;
   the arc is filled with the shared color ramp
   (`DialGaugeView.swift`).
6. **USSR** (`retroUSSR`) — a Soviet dot-matrix-clock look: wood-
   grain housing, near-black glass panel, phosphor-green 5×7
   dot-matrix digits (`RetroUSSRView.swift`).

## Constraints

- Does **not** introduce a settings screen or navigation — the
  picker is inline on the single screen. See
  [`../README.md#constraints`](../README.md#constraints).
- Doesn't add per-style data or configuration beyond the visual
  rendering itself.

## Related concepts

- [Thermometer Visual Style](../concepts/thermometer-visual-style.md)

## Related

- [Style guide — Interaction](../../ui-ux/style-guide.md#interaction)
- [Style guide — Color](../../ui-ux/style-guide.md#color)
