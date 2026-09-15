# Milestones

Dated project events — launches, releases, public posts, evidence
artifacts. Newest first.

Starts as this flat file. Extracts to `milestones/` (with
`history.md` index + dated deep-dive files + evidence) when
events accumulate enough to warrant their own pages — see
[`README.md#section-file-folder`](README.md#section-file-folder).

## Events

- **2026-09-15** — Shipped to TestFlight: v1.0 (build 1), internal
  testing group ("Personal"), installed and verified on the
  author's own iPhone via the TestFlight app.
- **2026-09-15** — Photo-backed art integrated across all six
  visual styles (GPT-generated reference images wired in via
  `Assets.xcassets`), plus the hide-chrome immersive mode and the
  swipe-to-switch-style gesture. See
  [`product/features/style-choose.md`](product/features/style-choose.md)
  and
  [`product/features/chrome-hide.md`](product/features/chrome-hide.md).
- **2026-09-15** — Thermometer visual style picker shipped: users
  can switch between six visual styles — Classic, Garden, Galileo,
  Retro, Dial, and USSR — via a tap row on the single screen,
  persisted across launches. See
  [`product/features/style-choose.md`](product/features/style-choose.md).
- **2026-09-15** — MVP thermometer built and verified in
  Simulator — SwiftUI app (`ios/`) builds clean for iOS Simulator
  (`xcodebuild ... -sdk iphonesimulator build`) and was manually
  verified running with live Open-Meteo weather data. Not yet run
  on a physical device.
