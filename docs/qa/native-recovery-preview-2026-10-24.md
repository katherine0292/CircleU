# Native account-preview verification

24 October 2026. Starting revision `dcaf53ad42b33873f560bd4bb482602ac6f2bf03`, clean `codex/journal-calendar-planning`. Scope: isolated previews only; [screen coverage and commands](../design/brand-demo/native-recovery.md). No real credentials, provider calls, reset emails, imports or user-data changes.

## Build and visual checks

SwiftPM `render-previews` and the existing direct-compiler Simulator host built successfully. Renderer generated all 22 recovery-state fixtures, compact login and three boards; the retained core/password/error boards and compact login were visually inspected. The initial macOS native-control renders contained unsupported-control markers; renderer-only static field/switch representations replaced them. Simulator screenshots confirmed actual native controls.

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build \
  --package-path Prototypes/CircleUVisualPrototype \
  --scratch-path /tmp/circleu-visual-preview-build --product render-previews
/tmp/circleu-visual-preview-build/debug/render-previews /tmp/circleu-recovery09-complete
bash Prototypes/CircleUVisualPrototype/scripts/build-motion-simulator.sh
```

Installed/launched only `com.circleu.prototype.motionsimulator` on **iPhone 18 Pro / iOS 27.0**, UUID `C7B63706-4D1C-4B7F-A161-8A2339D14E2B`. Normal onboarding opens native Log in, not Figma. Host arguments select invented error/link states outside the product UI.

## Native interaction results

| Case | Observed result |
| --- | --- |
| Welcome → Log in | Native email/secure-password fields and branded form appeared |
| Empty login submit | Inline valid-email explanation; form retained |
| Valid invented email, missing password | Inline Enter your password |
| Privacy → Done | Returned to login with invented email retained |
| Forgot password | Native reset request retained the email |
| Reset request → notice → Back to Log in | Generic If an account uses this email notice, email retained, password empty |
| Invented login → backup review | Cancellable checking state then native selection; no real authentication |
| Recover with no selection | Inline Choose a message to recover |
| Select message → recover → Done | Simulated result kept reflection/cloud copy distinct; Done reached static Opening, never Today |
| Malformed domain after review fix | `alex@example..com` rejected before request |
| Offline reset request after review fix | Retryable request error, no email-success state |
| Cancel reset request | Returned to form with email; later observation stayed on form, no late fixture transition |
| New password too short / mismatch | Minimum-length and mismatch explanations; fields retained for correction |
| Offline password update after review fix | Retryable update error, no password-updated state |
| Recovery failure → Review selection | Invented selection remained on; local exit available |

Happy-path form/selection checks preceded the offline/domain corrections; corrected error routes and cancellation were exercised on the rebuilt host. Password-update success, invalid/expired link and additional error states were source/render-reviewed; not every fixture's full tap journey was repeated. Device Hub accessibility value-setting verified input/state changes; it does not prove software-keyboard or swipe behavior.

## Independent source review and resolution

`/root/native_recovery_review` reviewed uncommitted source read-only under the requesting-code-review skill. No critical issue found. One important issue: offline reset/update could report success. Fixed all reset/update/recovery operation mappings for offline and checked both reset/update failures natively. Two minor issues also fixed: recovery now honors `--large-text`, and empty/invalid domain labels are rejected. No reviewer build/UI/test claims were adopted as independent runtime evidence. The review was not repeated after fixes.

The coordinator also made completed password-update Back return to login, and completed recovery Back leave the flow; completed operations should not reopen their forms. Route-scoped tasks cancel on exit. The two-second delay is only for observing/cancelling fixture progress.

## Limits

No production authentication, mail delivery, URL/token validation, Google flow, storage/migration, data preservation guarantee or full-app XCTest/CI run. Real keyboard submit/avoidance, new-form gestures at all sizes, VoiceOver, compact-height/landscape and hardware remain unverified. Earlier manual larger-text scrolling reports apply to the previous panels, not automatically to these forms. No Today work or production integration is inferred from this preview completion.
