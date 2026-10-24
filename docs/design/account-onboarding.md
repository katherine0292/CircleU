# Concise Welcome and optional accounts

24 October 2026. **Owner-approved:** guest-first local use, larger Pingu artwork, minimal copy, Get started and optional Log in. This supersedes the short-lived required-account proposal recorded in the [earlier log](../agent-collaboration-log/2026-10-24-200000-codex-account-onboarding-content.md).

## Screen and routes

- Welcome: CircleU wordmark, existing Pingu enlarged from 172pt to 260pt in the upper scene, live **Find your words** tagline without a full stop, then **Get started** and **Log in**. Keep Plus Jakarta Sans and the existing palette.
- Remove the repeated explanatory paragraph, storage banner, Privacy action and Used CircleU before? from Welcome. Keep native flexible spacing, readable controls and a scrolling fallback for larger text/short heights.
- Get started → local Opening fixture. Put the short device-storage explanation and Privacy and data access here, before meaningful input. Privacy retains detailed backup/export/voice and earlier-data information; Back/Done returns to its actual origin.
- Log in → existing earlier-data/recovery introduction. Its account-recovery link still opens the Figma flow. This specimen does not contain a native login form, real authentication or import. Preserve Continue without importing and Back.
- Do not add mandatory signup. Optional account creation can be revisited when a concrete account benefit exists; no cloud sync/backup is promised by login.

## Implementation and review

Scope: `BrandOnboardingPreview.swift`, renderer exports and supporting docs only. Production app, Firebase, signing, history and existing user data remain unchanged.

Check the SwiftPM build and normal/compact exports, then rebuild the existing isolated Simulator host. Review the selected iPhone 18 Pro Welcome and both routes. Native login/recovery, real readiness, short-height/larger-text scrolling and physical-device checks remain separate gaps; static images do not establish those results.

Current artifacts: [Welcome](swiftui-previews/brand-08-welcome.png), [compact width](swiftui-previews/brand-08-welcome-compact.png), [comparison](swiftui-previews/brand-08-onboarding.png). Historical v06/v07 files stay unchanged.

Use the [content standard](content.md) for headings and actions. The [privacy plan](../product/privacy-storage-plan.md) and [transition plan](../superpowers/plans/2026-10-23-local-first-transition.md) govern actual data handling and legacy preservation; the production guest-local path is not implemented yet.
