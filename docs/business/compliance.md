# Compliance

Externally-imposed obligations on the project: licensing,
attribution, regulation, and other rules we have to follow
regardless of what we'd prefer. Self-imposed product limits live
as *constraints* inside the section they apply to — see
[`../product/README.md#constraints`](../product/README.md#constraints).

## Platform policy — location permission

- What the rule is: iOS requires a user-facing purpose string for
  `CoreLocation` "when-in-use" access.
- Where it comes from: Apple App Store Review Guidelines / iOS
  privacy requirements (`NSLocationWhenInUseUsageDescription`).
- How the project complies: usage description already set in
  `ios/project.yml` ("Used to show today's temperature where you
  are."), flows into the generated Info.plist.

## Other obligations (open)

- App Store distribution terms — not yet applicable, the app has
  only run in Simulator and isn't submitted anywhere.
- Open-Meteo API terms of use — confirm attribution / rate-limit
  requirements before any distribution wider than personal use.
