# Choose thermometer style

The user can switch which visual style the thermometer reading
renders as, and the choice persists across app launches.

## What it does

- A horizontal row of tappable style icons sits below the numeric
  readout (`ContentView.swift`, `stylePicker`). Each icon shows an
  SF Symbol + short label for one style.
- Swiping left or right anywhere on the thermometer graphic itself
  cycles through the styles in order, wrapping at the ends, as an
  alternative to tapping the picker row (`ContentView.swift`,
  `styleSwipeGesture`). A minimum drag distance and a
  horizontal-dominates-vertical check keep it from firing on
  accidental or vertical touches.
- Both the tap and the swipe select a style with an
  `.easeInOut(duration: 0.2)` animation.
- The selection is persisted via
  `@AppStorage("thermometerVisualStyle")`, so it survives app
  relaunch. Default: Classic.
- The picker/swipe only swap the visual during the data-loaded
  `.ready` phase. Loading, permission-denied, and error states
  always show the classic glass tube (dimmed for the latter two),
  regardless of the stored selection.
- Switching styles changes only which image is shown, never the
  data: the actual reading always comes from the shared numeric
  readout below. Only Retro's own graphic reflects the live
  temperature directly — the other five are fixed photos.

## Available styles

From `ThermometerVisualStyle.swift` (ground truth as of
2026-09-15 — six cases). All six are backed by a photoreal
reference image (external GPT-generated art — see
[`../../tech/stack.md`](../../tech/stack.md)), each rendered via
`Image("...Photo").resizable().aspectRatio(.fit)`, except Retro,
which composites individual digit-tube photos instead of one
static image.

1. **Classic** (`classicGlassTube`) — static photo of a classic
   glass tube thermometer, `ClassicPhoto`
   (`ThermometerView.swift`).
2. **Garden** (`ornamentalGardenTube`) — static photo of a
   copper/bronze-framed ornamental tube with fleur-de-lis end
   caps, `GardenPhoto` (`OrnamentalGardenTubeView.swift`).
3. **Galileo** (`galileoColumn`) — static photo of a Galileo
   thermometer column, `GalileoPhoto`
   (`GalileoColumnView.swift`).
4. **Retro** (`retroDigitalReadout`) — the one live style: a row
   of individual Nixie-tube digit photos (`NixieDigit0`–`9`,
   `NixieMinus`, plus a `NixieUnitC` °C faceplate tile) composed
   digit-by-digit from the actual current temperature, handling
   1-digit, 2-digit, and negative readings
   (`RetroDigitalReadoutView.swift`).
5. **Dial** (`dialGauge`) — static photo of an analog dial gauge,
   `DialPhoto` (`DialGaugeView.swift`).
6. **USSR** (`retroUSSR`) — static photo of a Soviet
   "Электроника 7"-style dot-matrix display, `USSRPhoto`
   (`RetroUSSRView.swift`).

## Art

Each reference photo came from an external GPT-based image
pipeline (sketch/brief → GPT static image → hand-integrated
`Assets.xcassets` imageset) — see
[`../../tech/stack.md`](../../tech/stack.md) for the pipeline
itself. Garden's brief specifically called for "patina,
fleur-de-lis caps, tube markings," preserved in the shipped
`GardenPhoto`.

## Constraints

- Does **not** introduce a settings screen or navigation — the
  picker is inline on the single screen. See
  [`../README.md#constraints`](../README.md#constraints).
- Doesn't add per-style data or configuration beyond the visual
  rendering itself.

## Related concepts

- [Thermometer Visual Style](../concepts/thermometer-visual-style.md)

## Related

- [Hide chrome](chrome-hide.md) — the swipe gesture still works
  while chrome is hidden, since it lives on the thermometer
  graphic itself.
- [Style guide — Interaction](../../ui-ux/style-guide.md#interaction)
- [Style guide — Color](../../ui-ux/style-guide.md#color)
