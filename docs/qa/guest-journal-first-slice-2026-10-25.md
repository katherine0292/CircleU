# Guest journal first slice — QA, 25 October 2026

Scope: first-slice steps 2–4 (SwiftData guest store, hidden guest switch, Today → Write → Journal → edit), behind the Debug-only guest switch. The existing app and legacy data are excluded and unchanged. See the [plan](../superpowers/plans/2026-10-25-first-slice-typed-capture-local-journal.md).

## Physical phone: owner-reported

Destination: iPhone 11 Pro Max / iOS 26.6.1, separate Debug app **CircleU Guest Test** (`com.tuannm3812.circleu.guesttest`, compiled with `GUEST_JOURNAL_BUILD`), so the installed CircleU app and its data were untouched. Built from PR #12 at `6c81961` and installed by Claude with `devicectl`.

| Check | Result |
| --- | --- |
| Work through a moment → type → Save only my words → entry appears in Journal | Owner reported OK |
| Lock the phone, unlock | Owner reported OK |
| Close the app completely, reopen from the Home Screen → entry still in Journal | Owner reported OK |
| Open entry → Edit → change → Back → "Discard your changes?" with Keep editing / Discard | Owner reported OK |

Owner's reply: “all good, merge”. These are owner reports, not agent-observed screens. Not covered: Data Protection while locked (the device-only test hasn't run on the phone), VoiceOver, largest text.

## Simulator and automated

- `xcodebuild test` (CI signing config, Xcode 27.1, iPhone 17 / iOS 26.5): 148 passed, 1 device-only skipped.
- Out-of-repo XCUITest on iPhone 18 Pro / iOS 27.0 (`-CircleUGuestMode`): write → save → Journal → relaunch → edit → discard alert → keep editing → save → relaunch. Passed.
- `performAccessibilityAudit()` on Today, Write, Journal, Detail and Edit at default text size. Write-screen clipping was fixed. Remaining findings are on system controls only: the keyboard's suggestion slots, and the navigation-bar Edit and Back buttons.
- Codex review: five rounds; the final check found no blockers.

## Open

Brand font, largest-text and VoiceOver passes, the on-device Data Protection test, and release qualification.

## Brand polish follow-up (branch `codex/guest-brand-polish`)

- Plus Jakarta Sans is bundled under the SIL Open Font License, with `OFL-PlusJakartaSans.txt` shipped beside it, and registered at runtime for the guest screens only. All text uses Dynamic Type styles; navigation titles use the bold weight, scaled with `UIFontMetrics`.
- The approved preview colours (ink, blue, ice, muted) and the Today avatar illustration are used, plus brand buttons (filled and white, 54 pt). Decorative images are hidden from VoiceOver; the editors keep their labels.
- `performAccessibilityAudit()` on Today, Write, Journal, Detail and Edit at default and accessibility-extra-extra-extra-large text, run during the UI flow. Both passed. Remaining findings:
  - system controls: keyboard suggestion slots, and the navigation-bar Edit and Back buttons;
  - at the largest size: the intentional three-line cut-off of long entries in Journal, and a contrast reading on a row passing under the floating tab bar.
- **On-device encryption test passed** on the iPhone 11 Pro Max: `testRealDataProtectionOnDevice` confirmed `.completeUnlessOpen` on the store files. It ran under the separate test app ID `com.tuannm3812.circleu.guesttest.Circleu`, never the real app, and that temporary app was uninstalled afterwards.
