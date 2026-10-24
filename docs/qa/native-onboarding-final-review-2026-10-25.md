# Onboarding preview review — 25 October 2026

Scope: the isolated CircleUVisualPrototype and native CircleU Preview host, before Today. Base `da83ddccfd959d8743026e36edfff7efa7d3d860` plus current documentation changes. Production authentication, Firebase, storage and release are excluded. Continues the [keyboard/accessibility record](native-recovery-keyboard-accessibility-2026-10-24.md).

## Physical phone: owner-reported observations

Destination: iPhone 11 Pro Max / iOS 26.6.1, separately signed CircleU Preview. These are owner reports, not agent-observed speech or screen sharing.

| Check | Result |
| --- | --- |
| Installed app opens Log in | Owner confirmed after device certificate trust |
| Email Next → Password | Owner confirmed Password remains visible above keyboard |
| Invented login Done | Earlier data appears and keyboard closes |
| Reset Email Done | Check your email appears |
| VoiceOver labels and error | Owner reported VoiceOver reads the labels and error; exact speech/transcript and announcement timing were not independently captured |
| VoiceOver Back | Owner reported Back works |
| Largest text + VoiceOver | Owner confirmed Welcome Get started/Log in, Privacy scrolling/Done, and Earlier data Continue without importing are readable/reachable; no reported focus trap |
| New password Next / mismatch / completion | Owner initially saw Log in despite Xcode Running status. Fresh explicit build/install/launch completed; owner confirmed New password is visible. The initial handback only recorded completion without a result. The owner has now explicitly answered **“All three work”** to the VoiceOver/maximum-text Next, mismatch and completion checks; all three passed by owner report |

The New password specimen was a temporary ContentView configuration for review, using existing fixture code; it has since been restored (see the gate below). Initial Xcode Running status did not prove the intended screen was delivered: the owner saw Log in. A fresh physical build in `/tmp/circleu-phone-password-review`, explicit install and launch succeeded, and the owner then confirmed New password appears. The earlier mismatch's precise cause was not established; it is not attributed to a source bug. No real password changes. Claude has restored the usual Log in entry point and installed that build; the owner's phone screenshot confirms it opens on Log in with empty fields. The phone's text-size and VoiceOver preferences can be restored by the owner after review.

## New password fixture: Simulator evidence (Claude, 25 October)

Destination: iPhone 18 Pro / iOS 27.0 Simulator, CircleU Preview host only (bundle `com.tuannm3812.circleu.preview`), built from the temporary `BrandOnboardingPreview(initialScreen: .logIn, recoveryScreen: .newPassword)` ContentView with `CODE_SIGNING_ALLOWED=NO`. The original Circleu target was not built or run.

The Simulator MCP integration was unavailable (command-line tools selected) and the owner declined screen-control access, so the checks were driven by a throwaway XCUITest bundle outside the repository that attaches to the installed host by bundle identifier. Invented passwords only; nothing was committed from that runner.

| Check | Simulator result |
| --- | --- |
| Invented New password → keyboard **next** | Confirm password receives keyboard focus and is hittable; its frame (y 410–432 pt) sits above the software keyboard (top 590 pt) |
| Mismatched confirmation → keyboard **Done** | “The passwords don’t match.” appears with an alert icon; focus stays in Confirm password and the keyboard remains; title and entered New password are retained |
| Correct the confirmation → **Done** | Updating progress, then Password updated; keyboard dismissed and the error is gone |
| Password updated → Log in | Log in returns with Email and Password showing only their placeholders (empty) and no keyboard |

`xcodebuild test` reported `TEST SUCCEEDED` (1 test). Screenshots stayed in local scratch storage. Limits: this is Simulator evidence only. It does not show VoiceOver speech or announcement timing, maximum text size or the physical keyboard; the owner subsequently confirmed all three physical VoiceOver/maximum-text checks passed; that is separate owner-reported evidence, not evidence from this Simulator runner. No source fix was needed and no branding/layout changed.

## Additional native Simulator checks

Destination: iPhone 18 Pro / iOS 27.0. The normal host completed Welcome → Get started → Opening → Privacy → Manage earlier CircleU data → Continue without importing → Opening. Opening remains a static review endpoint and never implies storage readiness or automatically enters Today.

Rebuilt the existing direct-compiler Simulator host from current package source, installed only its separate bundle and selected existing recovery fixtures via launch arguments:

```sh
bash Prototypes/CircleUVisualPrototype/scripts/build-motion-simulator.sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl install <simulator-id> '/tmp/CircleU Motion Simulator.app'
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl launch --terminate-running-process <simulator-id> com.circleu.prototype.motionsimulator --recovery --recovery-screen linkExpired
```

| Fixture / action | Observed result through Device Hub accessibility actions |
| --- | --- |
| Expired link → Request new link | Reset password form opens |
| Invalid link → Back to Log in | Log in opens with empty fields |
| Backup check failed → Retry check | Checking appears, then returns to failed-backup explanation; never reports empty/success |
| Backup check failed → Continue locally | Static Opening endpoint appears |

Earlier [native recovery checks](native-recovery-preview-2026-10-24.md) cover reset cancellation, offline failures, selection preservation and representative validation. Those were not all repeated today. These fixture transitions do not verify email delivery, reset tokens, real connectivity or preserved backend data.

## Inspector findings remain open

The previous Inspector audit's Dynamic Type/contrast findings are retained in the linked keyboard record. A new Inspector window had no target selected; its target picker exposed no selectable app through the available UI connection, so no fresh audit result is claimed.

Source-token contrast calculations on the unchanged colors yielded ink/ice 17.56:1, blue/ice 6.74:1, muted/ice 6.11:1, muted/white 6.42:1 and white/blue 7.07:1. The reported ice `#F5FAFF` versus `#E8F0FC` pair reproduces 1.09:1 mathematically. This narrows the discrepancy but does not establish which rendered element the audit measured, dismiss the findings or qualify every appearance. No palette, font or artwork changes.

## Gate before Today review

- [x] Record selected physical keyboard, VoiceOver labels/error/Back and maximum-text route checks.
- [x] Check expired/invalid-link and failed-backup exits natively in Simulator.
- [x] Exercise New password Next / mismatch / completion in Simulator (Claude, above). Simulator evidence only.
- [x] Physical New password result: owner explicitly confirmed all three requested checks work with VoiceOver and maximum text (Next/visible confirmation, spoken/correctable mismatch, matching completion/keyboard dismissal/empty Password on Log in).
- [x] Restore the `BrandOnboardingPreview(initialScreen: .logIn)` entry point; Simulator rebuild/launch shows Log in.
- [x] Physical normal-entry confirmation: the restored build was signed and installed on the iPhone. The first launch was refused while the phone was locked. After unlock, `devicectl` launched it, and the owner sent a phone screenshot showing Log in with empty Email and Password placeholders (25 October, 08:17 local). Owner-supplied screenshot; the image is not stored in Git.

Unresolved Inspector warnings, rotation/compact-height, all text sizes, hardware keyboard and real Reduce Motion/lifecycle checks remain explicit accessibility/implementation follow-ups. Finishing this bounded owner walkthrough does not clear those gates or approve production feature coding. Today work would remain prototype review only.

## Automated accessibility audit after the copy trim (Claude, 25 October)

Branch `codex/onboarding-content-trim`. Destination: iPhone 18 Pro / iOS 27.0 Simulator, CircleU Preview host. The host now accepts review-only launch arguments (`--screen`, `--recovery-screen`, `--scenario`), so every fixture opens without editing ContentView. An out-of-repo XCUITest runner called `XCUIApplication.performAccessibilityAudit()` (all audit types) on 26 states: Welcome, Opening, Privacy, Earlier data, Locked, Read error and 18 Log in/reset/recovery fixtures. It ran once at the default text size and once with the Simulator set to accessibility-extra-extra-extra-large, then restored.

| Finding | Result |
| --- | --- |
| Hit area too small: Welcome Log in, Opening/Privacy/Earlier data quiet links | **Fixed.** The onboarding `quietButton` now puts its 44 pt frame and content shape inside the button label, matching the recovery `secondary` links. No findings remain at either size |
| Contrast | **None** on the CircleU Preview host at either size. A first run on the direct-compiled motion Simulator host reported contrast failures on text that calculates at 6–17:1, but they didn't reproduce on the review host, so they are treated as a host rendering/sampling artifact rather than a palette issue |
| Old 1.09:1 `#F5FAFF` vs `#E8F0FC` | `#E8F0FC` matches the brand blue at about 5–6% opacity over ice, and it isn't defined anywhere in the source. The Inspector most likely compared the background with a faint blue highlight or anti-aliased tint around Forgot password?, not the text. Not reproduced; no palette change |
| Dynamic Type unsupported: “CircleU” wordmark | Remains on every screen with the wordmark (21 states, both sizes). It is the fixed-size logo lockup; all other text scales (largest-size screenshot checked). Recorded as a deliberate logo exception for owner review, not changed |

Limits: automated audits don't replace VoiceOver speech/gesture testing. **A full manual VoiceOver pass is deferred until before release**; selected owner-reported VoiceOver checks above remain the only physical evidence.
