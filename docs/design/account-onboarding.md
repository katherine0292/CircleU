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

## Account-provider discussion — 25 October

**Recommendation, not an approved implementation change.** The owner asked why the preview says Used Google? and whether Google, X or Facebook could be used.

Used Google? currently opens help, not Google authentication. The [legacy inventory](../engineering/legacy-data-inventory.md) records Email/Password and Google enabled in the inspected development Firebase project, while explicitly leaving shipped Google support unverified. The current production `FirebaseAuthService` adapter implements email/password. The isolated preview authenticates with no provider at all.

Proposed content change: rename the link **Account help**, retaining the explanation for people who used an earlier provider. Do not replace it with Continue with Google until the provider works and its identity/recovery mapping is verified.

Firebase documents [Google](https://firebase.google.com/docs/auth/ios/google-signin), [Facebook](https://firebase.google.com/docs/auth/ios/facebook-login) and [Twitter/X](https://firebase.google.com/docs/auth/ios/twitter-login) integration on Apple platforms. Their availability in Firebase does not mean CircleU has configured them. A future optional-account proposal should begin with Apple and Google if a concrete account benefit is approved; defer X/Facebook unless user research establishes demand. Each provider adds configuration, account-linking, cancellation and recovery cases. Preserve the existing account identity and verify ownership rather than inferring the same account from a matching email.

For social login used to establish/authenticate the primary app account, [Apple guideline 4.8](https://developer.apple.com/app-store/review/guidelines/) requires an equivalent privacy-preserving login option unless an exception applies. Plan Sign in with Apple alongside Google and verify the final service against that rule. Guest-first local use and optional legacy recovery remain the approved direction. No provider enablement, Firebase setting, social-login screen or production auth change was made in this review.

## Concise copy pass — 25 October

**Proposed for owner review on `codex/onboarding-content-trim`; not merged.** The owner asked for less on-screen text, keeping only what's necessary, with reference to popular apps. The pattern follows short Apple, Day One and Headspace sign-in/recovery screens: one heading, at most one short supporting line, one primary action and few secondary links. The system Back control replaces duplicate "Back to…" links. Branding, colours, fonts, layout, validation and genuine error/recovery messages are unchanged. This is prototype copy only.

| Screen | Before | After |
| --- | --- | --- |
| Log in | "Use your earlier CircleU account. Nothing imports automatically." | "Use your earlier CircleU account." |
| Log in fields | Labels plus placeholders "Email address" / "Password" | Labels only; accessibility labels kept |
| Log in links | Forgot password? · Used Google? · Privacy and data · Continue locally | Forgot password? · Privacy and data (Back returns to Welcome) |
| Couldn't log in | "…email, password or original login method…" · Reset password · Continue locally | "Check your email and password. Your entries are unchanged." · Forgot password? · Account help |
| Account help | Helper + "Used Google?" + "Keep your earlier app" cards + Continue locally | One helper + one "Used Google before?" card; Back to Log in |
| Checking | "Checking your earlier account and backup." | "Looking for your backup…" |
| Reset password | "We'll send a link to your earlier account's email." + Back to Log in + Privacy and data | "We'll email you a reset link." (Back control only) |
| Check your email | "Reset link" card + "Check spam, or request another link." | "If an account uses this email, a reset link is on its way. Check spam if you can't find it." |
| Password updated | Title "You're ready to log in" + card "Use your new password to log in. Nothing has been imported." | Title "Password updated" + "Log in with your new password." |
| Privacy and data | Four two-sentence cards; "Manage earlier CircleU data" | Four one-line cards (on this device, backups, export & delete, voice); "Earlier CircleU data" |
| Earlier data | Line + two cards; two primary buttons | "Log in to choose what to recover. Nothing imports automatically." · Log in · quiet "Continue without importing" |
| Opening | Two lines + Privacy and data + Back to welcome | One line + Privacy and data |
| Locked / read error | Longer reassurance + Back to welcome | "Unlock your iPhone, then try again. Nothing has changed." / "Your saved words couldn't be read. Nothing has been erased." |

Kept deliberately: "Continue locally" on offline, no-backup, backup-error and recovery-error states (a real exit when recovery fails); the expired/invalid-link "Back to Log in" (a reset link may open without a Log in screen behind it); the Privacy link on Log in (privacy information before entering details); "Nothing imports automatically" on Earlier data (an approved truthful-recovery rule).

Used Google? is removed from Log in. Account help is reachable only after a failed login. Google, Apple, X and Facebook login remain deferred proposals (see above); no provider was added.
