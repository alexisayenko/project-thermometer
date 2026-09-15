# Stack

The v1 stack, with rationale per pick. See
[`README.md`](README.md) for the section frame.

- **SwiftUI**, iOS 17.0+ deployment target — the only client;
  native gives full control over the animation (spring fill, glow
  pulse, bubbles) a cross-platform framework would fight.
- **XcodeGen** (`ios/project.yml` → `ios/Thermometer.xcodeproj`)
  — the `.xcodeproj` is generated, not hand-maintained. Edit
  `project.yml` and run `xcodegen generate` from `ios/`; avoids
  Xcode's noisy, conflict-prone project-file diffs.
- **Open-Meteo** — current temperature + today's forecast max/min
  via `URLSession`. Free, no API key, no account — fits a
  personal project with no budget and no interest in managing
  credentials.
- **CoreLocation** (when-in-use permission) — coordinates for the
  weather lookup. Purpose string already set in
  `NSLocationWhenInUseUsageDescription` via `ios/project.yml`.
- **No backend** — the app talks to Open-Meteo directly from the
  client. Nothing to host, deploy, or pay for; matches the
  single-user, no-accounts scope in
  [`../product/README.md#constraints`](../product/README.md#constraints).
