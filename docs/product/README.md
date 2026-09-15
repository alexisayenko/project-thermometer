# Product

Thermometer shows today's real outdoor temperature as one of six
photoreal thermometer styles the user can pick between (Classic,
Garden, Galileo, Retro, Dial, USSR) — swipe or tap to switch. Five
are static reference photos; Retro alone composites live digit
tubes to show the actual reading. The value is purely aesthetic: a
small daily ritual of checking the weather, not a utility for
planning around it — that tension (delight over feature count)
governs every scope decision.

It replaces the reflex of opening a cluttered weather app just to
see one number with something calmer and nicer to look at.

For the wider docs/ map and what-lives-where, see
[`../README.md`](../README.md).

## Folder map

The product subtree (full docs tree in
[`../README.md#subtree-map`](../README.md#subtree-map)):

```text
product/
├── README.md      # this file — core idea + product-section glossary
├── concepts/      # one file per domain noun — entry: concepts/README.md
└── features/      # one file per product capability — entry: features/README.md
```

## Glossary

Vocabulary for the product section. Domain words ("painting",
"garment", "palette") are *concept names* — they belong in
[`concepts/`](concepts/), not here.

The product taxonomy is a four-level chain — each level composes
the next. See [`../README.md#glossary`](../README.md#glossary)
for the cross-tree index.

- **Concept** — a *noun* in the product vocabulary — a stable
  thing the product reasons about, independent of any UI. One file
  per concept in [`concepts/`](concepts/). Covers data model,
  invariants, edge cases.
- **Feature** — a *verb* — the smallest unit that delivers value
  to the user. One file per feature in [`features/`](features/).
  A feature acts on one or more concepts.
- **Screen** — a *place* — a UI page where features get exposed.
  One file per screen in
  [`../ui-ux/screens/`](../ui-ux/screens/). A single feature can
  appear on multiple screens; a single screen hosts multiple
  features.
- **Journey** — a *sequence* — a path the user takes across
  multiple screens (onboarding, first-add → save, recovery flow).
  Journeys live in
  [`../ui-ux/journeys.md`](../ui-ux/journeys.md) (one section per
  journey, extracts to `journeys/` when they grow). A journey threads
  screens; defined and detailed in
  [`../ui-ux/README.md`](../ui-ux/README.md).
- **Constraint** — a self-imposed product limit ("we won't do X,
  even though we technically could"). Distinct from *compliance*
  (externally imposed; lives in
  [`../business/compliance.md`](../business/compliance.md)).

The chain in one line: **concept = noun, feature = verb,
screen = place, journey = sequence**. If you can phrase the spec
as "the user can [verb]", it's a feature. If it's "the thing
called [noun]", it's a concept. If it's "the page where the user
is when they do it", it's a screen. If it's "the path from one
page to the next", it's a journey.

For **Concerns** — the cross-cutting work-area axis used in task
frontmatter (orthogonal to product sections) — see
[`../concerns.md`](../concerns.md).

## Constraints

Self-imposed product limits — things we won't do even though we
technically could. Externally-imposed obligations (licensing,
compliance, attribution) live in
[`../business/compliance.md`](../business/compliance.md), not here.

- **Deliberately minimal, personal aesthetic project — not a
  utility with growth ambitions.** No settings *screen* or
  navigation, no history, forecast list, city search, accounts, or
  monetization. This is distinct from "no user-adjustable state at
  all": two persisted choices exist — thermometer visual style
  (see [`features/style-choose.md`](features/style-choose.md)) and
  the hide-chrome immersive toggle (see
  [`features/chrome-hide.md`](features/chrome-hide.md)) — both made
  inline on the single screen with no dedicated settings page.
- **Single current location only**, from `CoreLocation`. No
  manual location override yet — planned for a future settings
  layer (not built).
