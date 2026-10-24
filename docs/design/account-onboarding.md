# Concise Welcome and optional accounts

24 October 2026. **Owner-approved:** guest-first local use, larger Pingu artwork, minimal copy, Get started and optional Log in. This supersedes the short-lived required-account proposal recorded in the [earlier log](../agent-collaboration-log/2026-10-24-200000-codex-account-onboarding-content.md).

## Screen and routes

- Welcome: CircleU wordmark, existing Pingu enlarged from 172pt to 260pt in the upper scene, live **Find your words** tagline without a full stop, then **Get started** and **Log in**. Keep Plus Jakarta Sans and the existing palette.
- Remove the repeated explanatory paragraph, storage banner, Privacy action and Used CircleU before? from Welcome. Keep native flexible spacing, readable controls and a scrolling fallback for larger text/short heights.
- Get started → local Opening fixture. Put the short device-storage explanation and Privacy and data access here, before meaningful input. Privacy retains detailed backup/export/voice and earlier-data information; Back/Done returns to its actual origin.
- Log in → native email/password form, password reset and explicit earlier-data recovery previews. No external Figma chooser. Keep Back, Privacy and local exits. All account/reset/import outcomes are simulated; see [native recovery](brand-demo/native-recovery.md).
- Do not add mandatory signup. Optional account creation can be revisited when a concrete account benefit exists; no cloud sync/backup is promised by login.

## Implementation and review

Scope: isolated `BrandOnboardingPreview.swift`, `BrandRecoveryPreview.swift`, existing Simulator host, renderer exports and supporting docs only. Production app, Firebase, signing, history and existing user data remain unchanged.

Check the SwiftPM build and normal/compact exports, then rebuild the existing isolated Simulator host. Review the selected iPhone 18 Pro Welcome and both routes. Larger-text review is recorded in [QA](../qa/native-onboarding-interaction-review-2026-10-24.md): Welcome inspected at accessibility1/5, Privacy/recovery scrolling and bottom actions reported working by the owner. Native login/reset/recovery previews are now present, with [separate verification](../qa/native-recovery-preview-2026-10-24.md). The owner also confirmed the new Log in and reset-request forms scroll and their controls are readable/reachable at accessibility5, including Forgot password?, Send reset link and Back. Selected software-keyboard routes and fixes are in the [keyboard/accessibility review](../qa/native-recovery-keyboard-accessibility-2026-10-24.md). Real auth/readiness, remaining keyboard/gesture coverage, Inspector warnings, short-height/landscape, VoiceOver and physical-device checks remain open; manual reports are separate from automated evidence.

Current artifacts: [Welcome](swiftui-previews/brand-08-welcome.png), [compact width](swiftui-previews/brand-08-welcome-compact.png), [comparison](swiftui-previews/brand-08-onboarding.png). Historical v06/v07 files stay unchanged.

Use the [content standard](content.md) for headings and actions. The [privacy plan](../product/privacy-storage-plan.md) and [transition plan](../superpowers/plans/2026-10-23-local-first-transition.md) govern actual data handling and legacy preservation; the production guest-local path is not implemented yet.
