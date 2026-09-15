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
author), display name "Thermo — Daily Ritual" (Xcode product/
target name stays "Thermometer"). It shows today's real outdoor
temperature via a numeric readout, today's date, and today's
high/low, plus a choice of six photoreal thermometer-style images
— Classic, Garden, Galileo, Retro, Dial, and USSR — picked via a
tap row below the readout or by swiping left/right on the
thermometer graphic itself, with the choice persisted across
launches. Five styles are static/decorative photos; Retro is a
live exception, compositing individual Nixie-tube digit photos to
show the actual current temperature digit-by-digit. An eye-icon
toggle hides the header/readout/picker chrome (also persisted) for
an immersive view where the thermometer graphic expands to fill
most of the screen. Still one screen, no settings navigation. No
monetization — it's a personal aesthetic project, not a product
with growth ambitions.

## Tech stack

SwiftUI, iOS 17.0+ deployment target, iPhone-only and
portrait-only (`TARGETED_DEVICE_FAMILY: "1"` — now formally
declared in `project.yml`, not just de facto). Current temperature
and today's forecast max/min come from Open-Meteo (free, no API
key) via `URLSession`; coordinates come from `CoreLocation`
(when-in-use permission). No backend or server component. The
Xcode project is generated via XcodeGen (`ios/project.yml` →
`ios/Thermometer.xcodeproj`, not hand-maintained — regenerate
with `xcodegen generate` after editing `project.yml`). Has a real
1024×1024 app icon, derived from the Classic thermometer photo.
As of 2026-09-15: deployed to TestFlight — v1.0 (build 1), live
via internal TestFlight testing, installed and verified on the
author's own iPhone.

## Repo

[alexisayenko/project-thermometer](https://github.com/alexisayenko/project-thermometer)
(private). Remote is SSH:
`git@github.com:alexisayenko/project-thermometer.git`.

## Where to look for more

- [README.md](README.md) — repo entry point + structure
- [docs/README.md](docs/README.md) — docs subtree map
- [docs/tech/stack.md](docs/tech/stack.md) — stack picks + rationale
