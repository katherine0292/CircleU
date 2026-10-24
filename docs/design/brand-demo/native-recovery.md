# Native Log in, reset and recovery previews

24 October 2026. Owner-authorized **isolated prototype**, using Plus Jakarta Sans, existing CircleU logo and ice/blue/ink colors. Welcome now opens native Log in directly. No Firebase, credential verification, email delivery, real reset link, import, persistence or Today integration.

## Review

Open `Prototypes/CircleUVisualPrototype` in Xcode and select a **Recovery · …** preview in `BrandRecoveryPreview.swift`. The named previews use the onboarding parent so Back and local exits have destinations. Guest Get started remains available. Enter invented details only; the fields stay in process memory and secret fields clear on submission/exit.

- [Core screens](../swiftui-previews/brand-09-recovery.png)
- [Reset email, expired link and new password](../swiftui-previews/brand-09-password.png)
- [Login, reset and recovery errors](../swiftui-previews/brand-09-errors.png)
- [Compact-width login](../swiftui-previews/brand-09-login-compact.png)

These boards are macOS ImageRenderer output. Text fields and the selection switch use static SwiftUI representations because ImageRenderer cannot draw those native controls. The Simulator uses actual text/secure fields and a switch; PNGs do not establish input or keyboard behavior. Review notes stay outside depicted screens.

## Coverage and behavior

| Route | Native preview behavior |
| --- | --- |
| Log in | Email/password fields, inline invalid-email/missing-password messages, Privacy, reset, original-provider help and local exit |
| Password reset | Email request → cancellable progress → generic email notice; resend returns to the form, preserving email without confirming account existence |
| Reset link | Expired/invalid link → request another; new-password and confirmation fields → minimum/mismatch validation → updating → result or retryable failure |
| Earlier data | Account/backup check → explicit selection of one invented practice message; current edited reflection is kept |
| Recovery | Selected message → cancellable progress → result; failure preserves selection and allows review/retry or local exit |
| Errors | Wrong login, offline, reset request/update failure, failed backup check, completed no-backup check and failed recovery are separate fixtures |
| Back / Privacy | Email retained in the active flow. Secret fields clear on Back/exit. Privacy Done returns to the actual origin. Completed password change returns to Log in; completed recovery exits to Opening |

Progress lasts two seconds only to make the preview observable/cancellable. Route-scoped tasks cancel when leaving; no artificial delay is prescribed for production. In the default invented scenario, any syntactically plausible email plus nonempty password advances; this is not authentication. Reset-new-password previews use **9 characters**, matching the inspected legacy local signup rule (`password.count > 8`); actual provider policy still needs verification. Only full non-sensitive fixture names belong in launch arguments, never credentials.

New-password/expired-link fixtures represent arriving from an email link. They are chosen through Canvas or host arguments, not a fake “received email” button in the product. Real URL routing and token verification are out of scope. Google is help-only because provider/backend identity is unresolved. No new signup, remote account, live support destination or automatic sync is introduced.

## Reproduce in the existing Simulator host

Build with `bash Prototypes/CircleUVisualPrototype/scripts/build-motion-simulator.sh`, install the printed app bundle on the selected Simulator, and launch `com.circleu.prototype.motionsimulator` with one of these argument sets:

```text
--onboarding
--recovery --scenario offline
--recovery --scenario loginError
--recovery --scenario noBackup
--recovery --scenario backupError
--recovery --scenario resetError
--recovery --scenario recoveryError
--recovery --recovery-screen newPassword
--recovery --recovery-screen linkExpired
--recovery --recovery-screen linkInvalid
```

Add `--large-text` (accessibility1) or `--largest-text` (accessibility5). Restart only the isolated prototype between fixtures. Any `BrandRecoveryScreen` raw value is accepted after `--recovery-screen`; progress frames can be frozen with `advancesProgress: false` in a Canvas specimen. Scenario controls never appear in product UI. Local exits stop at the existing static Opening fixture, not Today.

## Evidence and remaining limits

The [recovery QA record](../../qa/native-recovery-preview-2026-10-24.md) separates inspected renders, Simulator button/input checks and manual gesture reports. The owner confirmed Log in → Forgot password? → Send reset link reachability → Back at accessibility5 on the selected iPhone 18 Pro; both forms scroll and their text, fields and controls are readable and reachable. Production auth/storage, actual mail/reset token handling, Google recovery, software-keyboard behavior, gesture coverage at other sizes, VoiceOver and physical hardware remain separate implementation/validation work. Earlier onboarding-panel evidence stays in the [onboarding QA record](../../qa/native-onboarding-interaction-review-2026-10-24.md).

Keyboard review: [checked behavior, audit warnings and physical VoiceOver steps](../../qa/native-recovery-keyboard-accessibility-2026-10-24.md). Native forms keep the focused field visible when the keyboard appears; new routes start at their heading. New password uses Next, confirmation uses Done. Secondary actions have at least 44pt of label hit area. The default Simulator recovery host inherits system text size; explicit larger-text flags remain fixed fixtures.
