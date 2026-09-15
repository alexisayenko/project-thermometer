# Brand

Brand identity hasn't been defined — this is a personal hobby
project. The product name is simply "Thermometer" (bundle id
`com.isayenko.thermometer`); no logo, palette, or mark chosen
yet.

Folder-specific applications (favicon, web splash, social cards,
app icons, store screenshots) are derived from the mark and
live alongside the code that consumes them — under the relevant
code folder, not here.

For how brand applies to shipped UI (type scale, motion timings,
color-use rules, popup patterns, copy conventions), see
[`../ui-ux/style-guide.md`](../ui-ux/style-guide.md). This file
owns identity / spirit; the style guide operationalizes it.

## Section-local glossary

- **Mark** — the graphic-only identity element. Lives in this
  folder as the source of truth (e.g. `mark.svg` / `mark.png`)
  once chosen.
- **Wordmark** — text-only logo (the product's name set in a
  chosen typeface).
- **Logo** — full lockup of mark + wordmark.
- **Application** — the mark used inside another artifact (a
  favicon, an app icon, a splash screen). Lives with the
  platform that consumes it.
- **Variant** — alternate treatment of the same application
  (e.g. light/dark favicon).

## Current state

- **Name**: Locked — "Thermometer". Plain and literal, matching
  the single-purpose scope; never a contest between candidates.
- **Visual direction**: Not decided beyond the in-app temperature
  gradient (see
  [`../ui-ux/style-guide.md`](../ui-ux/style-guide.md)).
  - **Palette**: N/A — no dedicated brand palette; the
    temperature-color gradient is the only color system so far.
  - **Texture**: N/A — not decided.
  - **Typography**: N/A — system font (SF), no custom typeface
    chosen.
  - **Mark**: N/A — no app icon/mark designed yet;
    `Assets.xcassets/AppIcon.appiconset` is an empty XcodeGen
    placeholder with no images.
- **Domain**: N/A — no domain registered (native app, no web
  presence).
- **Wordmark / logo**: TBD — no logo designed.

## Where applications live

Cross-folder assets (mark sources, font licenses) live here.
Per-folder applications live with their code.

| Where it appears | Location |
| --- | --- |
| None yet | No visual applications designed (see Current state) |

## Names considered

Optional. Useful when the name is still in motion.

| Name | Verdict |
| --- | --- |
| N/A | "Thermometer" was chosen directly, never revisited |

## Open questions

- App icon / mark — not designed yet.
- No domain or brand palette beyond the in-app temperature
  gradient.
