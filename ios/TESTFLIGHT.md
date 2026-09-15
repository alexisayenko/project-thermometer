# Getting to TestFlight

Local signing is set up and a signed archive has been produced.
Done so far:

- Version numbers, app icon, unsigned Release build validated.
- `DEVELOPMENT_TEAM: L8C7TUQLBM` and `CODE_SIGN_STYLE: Automatic`
  set for the `Thermometer` target in `project.yml`.
- Signed Release archive built successfully at
  `ios/build/Thermometer.xcarchive`, signed with
  `Apple Development: Oleksandr Isayenko (35B859CSYN)`
  (Team L8C7TUQLBM). Not committed — `build/` is gitignored.
- `.ipa` export for App Store distribution was attempted
  (`xcodebuild -exportArchive`, method `app-store`) and failed
  with `No profiles for 'com.isayenko.thermometer' were found` —
  there's no App Store *distribution* provisioning profile yet.
  Automatic signing can create a **development** profile
  headlessly (that's what the archive used), but a distribution
  profile needs an App Store Connect app record and an Apple
  Distribution certificate, which Xcode normally creates for you
  interactively during the Organizer upload flow.

What's left (needs your own interactive steps in Xcode):

1. Make sure you have an active Apple Developer Program membership
   (~$99/year) — skip if you already do.
2. In App Store Connect (appstoreconnect.apple.com), create a new
   app record with bundle ID `com.isayenko.thermometer`, if it
   isn't offered to you automatically during the upload step below.
3. Open Xcode's **Window > Organizer**, select the archive at
   `ios/build/Thermometer.xcarchive` (or re-run **Product >
   Archive** from the project if you'd rather Xcode manage the
   whole thing), then click **Distribute App** >
   **TestFlight & App Store**. Xcode will create the Apple
   Distribution certificate and App Store provisioning profile for
   you as part of this flow, prompting for 2FA if needed.
4. Wait for Apple to finish processing the build (minutes to tens
   of minutes), then add yourself (and any testers) under
   **TestFlight** in App Store Connect to install it via the
   TestFlight app.
