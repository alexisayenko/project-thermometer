# Style guide

The in-project visual and interaction reference, plus the
platform style guides we hold ourselves to. Sets the standards
the product looks and behaves under.

For identity-level direction (palette, typography family, voice
tone, mark), see [`../brand/README.md`](../brand/README.md).
This guide *operationalizes* brand at the UI layer — the
brand-derived rules below (color use, type scale, motion, voice
& copy) should trace back to decisions there.

## External references

Platform-level guides we conform to. Defer to these unless we
have a documented reason to diverge — record divergences in
[In-project conventions](#in-project-conventions) below with
their rationale.

- iOS — [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines)
- Android — [Material Design 3](https://m3.material.io/)
- Web a11y — [WCAG 2.2](https://www.w3.org/WAI/standards-guidelines/wcag/)

## In-project conventions

Project-specific rules that go beyond — or deliberately override
— the platform defaults. Add as patterns crystallize; cite the
rationale per rule so future-us can revisit.

### Color

- The liquid fill color *is* the color system — there's no
  separate accent/destructive palette; single screen, no
  destructive actions exist. It's driven entirely by current
  temperature, interpolated across five stops (`ThermometerView.swift`,
  `TemperatureColor.color(for:)`): -20°C deep blue → 0°C blue →
  15°C teal-green → 25°C amber → 35°C red.
- As of 2026-09-15 this is no longer true in practice: all six
  thermometer visual styles now render a fixed photoreal reference
  image (`ThermometerView.swift`, `OrnamentalGardenTubeView.swift`,
  `GalileoColumnView.swift`, `DialGaugeView.swift`,
  `RetroUSSRView.swift`, `RetroDigitalReadoutView.swift`) — none of
  them derive color from the live temperature any more, including
  Galileo and Dial. `TemperatureColor.color(for:)` and the
  procedural `LiquidColumnView.swift` that used it still exist in
  the codebase but aren't wired into any current style; they're
  vestigial from before the photo-backed art landed. The live
  numeric readout text uses standard `.primary`/`.secondary`
  styling, not the temperature ramp.

### Typography

- Not yet decided beyond OS defaults — single-screen app, no
  navigation/interaction patterns exist yet.

### Motion

- As of 2026-09-15 the animated liquid fill, glow pulse, and rising
  bubbles described below are not visible in the shipped app: all
  six thermometer visual styles render a static photo (see
  [Color](#color)). The mechanism still exists in
  `LiquidColumnView.swift`, but that view isn't wired into any
  current style — kept here as a record of what it does in case it
  gets reused.
- Liquid fill: `spring(response: 1.15, dampingFraction: 0.78)`
  on temperature change.
- Glow pulse: `easeInOut(duration: 1.8).repeatForever(autoreverses: true)`.
- Rising bubbles: a `linear(duration: 2.4).repeatForever(autoreverses: false)`
  loop drives spawn timing; each bubble rises on its own
  `easeInOut(duration: bubble.duration)`.
- These are literal values inline in `LiquidColumnView.swift` — no
  shared duration constants defined yet.

### Interaction

- Style switching: a horizontal row of tappable style icons below
  the readout (`ContentView.swift`, `stylePicker`), or swiping
  left/right anywhere on the thermometer graphic itself
  (`styleSwipeGesture`, wraps at the ends). Both select a style
  with `.easeInOut(duration: 0.2)`; the choice persists across
  launches via `@AppStorage("thermometerVisualStyle")`. The
  picker/swipe only swap the visual during the data-loaded
  `.ready` phase; loading/permission-denied/error states always
  render the classic glass tube regardless of the stored
  selection.
- Hide chrome: an eye / eye-slash icon button (top-right) toggles
  hiding the header, numeric readout, and style picker together,
  animated with `.easeInOut(duration: 0.3)`; the thermometer
  graphic expands to fill most of the screen in their place. The
  choice persists via `@AppStorage("isTextHidden")`. See
  [`../product/features/chrome-hide.md`](../product/features/chrome-hide.md).
- Neither pattern introduces push/modal navigation — the app stays
  single-screen.

### Voice & copy

- Not yet decided beyond OS defaults — single-screen app, no
  navigation/interaction patterns exist yet.

## Open questions

- Phase 2: a settings layer (location override, terrain backdrop
  picker) — not designed yet. Thermometer visual style picker
  shipped inline instead (see [Interaction](#interaction)),
  without introducing a settings layer.
