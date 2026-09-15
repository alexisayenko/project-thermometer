# Business

Audience, scope, monetization, and compliance posture —
decisions that apply to the project as a whole, not to a
specific product folder. For the product core idea and the
Concept / Feature / Screen vocabulary, see
[`../product/README.md`](../product/README.md). For cross-cutting
work-area axes (C1, C2, …), see [`../concerns.md`](../concerns.md).

## Audience

Personal project, single user (the author). Not designed for
anyone else.

## Scope (v1)

One screen: today's current temperature + today's high/low,
shown as one animated glass thermometer, current location only
(via `CoreLocation`). Nothing else — see
[Non-goals](#non-goals-v1). A settings layer (location override,
visual style, terrain backdrop) is deferred to v2+.

## Monetization

- **Model**: none — not monetized.
- **Free tier**: n/a.
- **Paid tier**: n/a.
- **Price**: n/a.

## Non-goals (v1)

Things deliberately out of scope. Each line defends an absence.

- No settings, history, forecast list, city search, or accounts.
- No monetization, analytics, or backend/server component.

## Open questions

- None right now — no business decisions pending for a personal
  project.

## Resolved

Historical decisions with dates — load-bearing for understanding
why the current shape is what it is. Don't delete; the trail is
the audit.

- No formal decision log kept yet — decisions so far are captured
  in [`../../CLAUDE.md`](../../CLAUDE.md) and
  [`../product/README.md`](../product/README.md) instead.

## File layout

Scaffolded files:

- [`compliance.md`](compliance.md) — externally-imposed
  obligations (licensing, regulation, attribution, data
  residency).
- [`budget.md`](budget.md) — running ledger of out-of-pocket
  project costs (one-time + recurring).

Common slots — extract on first real entry. See
[Section, file, folder](../README.md#section-file-folder).

- `legal.md` — terms, privacy, jurisdictional notes.
- `marketing.md` — store listings, campaign copy, launch notes.
