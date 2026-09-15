# Tech

Stack, infrastructure, and architectural decisions. The "how it
runs" layer — what's used to build and operate the product.
Product / business / UX live in their own sections.

## Common slots

Don't pre-create — extract on first real entry. See
[Section, file, folder](../README.md#section-file-folder).

- **`stack.md`** — the v1 stack: framework, hosting, storage,
  payments, language, etc., with rationale per pick.
- **`architecture.md`** — system overview, data flow, key
  components.
- **`decisions.md`** (or **`decisions/<slug>.md`** if a single
  decision warrants its own file) — ADRs. Substantive
  architectural decisions with date, alternatives considered,
  rationale. Don't delete superseded decisions — strikethrough
  and add the new one underneath.

## Open questions

- Physical-device signing/distribution — not yet set up; needs
  the user's own Apple ID / signing team in Xcode.
- Phase-2 nature-background images (terrain × climate/season ×
  time-of-day) — sourcing (e.g. AI image generation) and bundling
  approach not yet decided.
