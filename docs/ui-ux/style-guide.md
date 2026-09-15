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
- This temperature ramp is still the shared base across all six
  thermometer visual styles, but several styles layer their own
  fixed chrome colors on top, not temperature-driven: Garden's
  copper/bronze frame (`OrnamentalGardenTubeView.swift`), Retro's
  amber Nixie-style glow (`RetroDigitalReadoutView.swift`), and
  USSR's wood-grain housing + phosphor-green dot matrix
  (`RetroUSSRView.swift`). Galileo and Dial still derive their
  coloring from `TemperatureColor.color(for:)` — Galileo per
  calibrated sphere (`GalileoColumnView.swift`), Dial across the
  arc/needle (`DialGaugeView.swift`).

### Typography

- Not yet decided beyond OS defaults — single-screen app, no
  navigation/interaction patterns exist yet.

### Motion

- Liquid fill: `spring(response: 1.15, dampingFraction: 0.78)`
  on temperature change.
- Glow pulse: `easeInOut(duration: 1.8).repeatForever(autoreverses: true)`.
- Rising bubbles: a `linear(duration: 2.4).repeatForever(autoreverses: false)`
  loop drives spawn timing; each bubble rises on its own
  `easeInOut(duration: bubble.duration)`.
- These are literal values inline in `ThermometerView.swift` — no
  shared duration constants defined yet.

### Interaction

- Style switching is the one interaction pattern so far: a
  horizontal row of tappable style icons below the readout
  (`ContentView.swift`, `stylePicker`). Tapping selects a style
  with `.easeInOut(duration: 0.2)`; the choice persists across
  launches via `@AppStorage("thermometerVisualStyle")`. This
  introduces no push/modal navigation — the app stays
  single-screen. The picker only swaps the visual during the
  data-loaded `.ready` phase; loading/permission-denied/error
  states always render the classic glass tube regardless of the
  stored selection.

### Voice & copy

- Not yet decided beyond OS defaults — single-screen app, no
  navigation/interaction patterns exist yet.

## Open questions

- Phase 2: a settings layer (location override, terrain backdrop
  picker) — not designed yet. Thermometer visual style picker
  shipped inline instead (see [Interaction](#interaction)),
  without introducing a settings layer.
