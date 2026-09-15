# Hide chrome

The user can hide the header, numeric readout, and style picker to
see the thermometer graphic alone, immersive and filling most of
the screen.

## What it does

- An eye / eye-slash icon button, top-right of the screen, toggles
  the state (`ContentView.swift`, `isTextHidden`), animated with
  `.easeInOut(duration: 0.3)`.
- Hiding removes the date header, the numeric readout, **and** the
  style picker together — not just header/readout. The freed
  vertical space goes to the thermometer graphic.
- The thermometer's sizing (`thermometerSize(in:immersive:)`) drops
  its normal aspect-ratio ceiling in this state and instead grows
  to claim most of the available height — code comments target the
  *visible* photo content reaching roughly 90% of screen height —
  bottom-anchored so the extra height spills upward into the top
  clearance rather than being centered.
- The choice persists across launches via
  `@AppStorage("isTextHidden")`. Default: chrome visible (`false`).
- Swiping left/right to change style (see
  [`style-choose.md`](style-choose.md)) still works while chrome is
  hidden — that gesture lives on the thermometer graphic itself,
  which stays on screen in both states.

## Constraints

- Does **not** introduce a settings screen or navigation — a single
  icon toggle on the existing screen. See
  [`../README.md#constraints`](../README.md#constraints).

## Related

- [Choose thermometer style](style-choose.md)
- [Style guide — Interaction](../../ui-ux/style-guide.md#interaction)
