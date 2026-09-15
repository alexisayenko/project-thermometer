# CLAUDE.md

Fast-path context for Claude Code. Full human-oriented docs:
[docs/](docs/).

## Key principle

> The thermometer is a small daily aesthetic ritual, not a utility.

Every decision is weighed against atmosphere and delight, not
feature count or configurability. If a feature doesn't deepen the
moment of glancing at today's temperature, it gets cut — that's
why there's no settings, history, forecast list, city search,
accounts, or monetization.

## Product

Thermometer is a single-screen SwiftUI iOS app for one user (the
author). It shows today's real outdoor temperature as one
animated glass thermometer: liquid rises to the current reading
with a spring animation, colored on a continuous
blue → teal → amber → red gradient by temperature, with a glow
pulse and rising bubbles for a "living" feel, plus a numeric
readout, today's date, and today's high/low. No monetization —
it's a personal aesthetic project, not a product with growth
ambitions.

## Tech stack

SwiftUI, iOS 17.0+ deployment target. Current temperature and
today's forecast max/min come from Open-Meteo (free, no API key)
via `URLSession`; coordinates come from `CoreLocation`
(when-in-use permission). No backend or server component. The
Xcode project is generated via XcodeGen (`ios/project.yml` →
`ios/Thermometer.xcodeproj`, not hand-maintained — regenerate
with `xcodegen generate` after editing `project.yml`). As of
2026-09-15: builds clean for iOS Simulator
(`xcodebuild ... -sdk iphonesimulator build`) and was manually
verified running with live weather data; not yet run on a
physical device (needs the user's own Apple ID/signing team in
Xcode).

## Repo

[alexisayenko/project-thermometer](https://github.com/alexisayenko/project-thermometer)
(private). Remote is SSH:
`git@github.com:alexisayenko/project-thermometer.git`.

## Where to look for more

- [README.md](README.md) — repo entry point + structure
- [docs/README.md](docs/README.md) — docs subtree map
- [docs/tech/stack.md](docs/tech/stack.md) — stack picks + rationale
