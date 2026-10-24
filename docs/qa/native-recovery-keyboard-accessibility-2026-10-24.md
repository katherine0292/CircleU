# Native recovery keyboard and accessibility review

24 October 2026, Australia/Sydney. Base `22e1ff433c5c088dc4f1d67b1d1b277bb1fa9939`, `codex/journal-calendar-planning`; isolated preview changes in the working tree. Continues the [native recovery QA](native-recovery-preview-2026-10-24.md). Today and production services remain outside this task.

## Keyboard investigation and changes

On iPhone 18 Pro/iOS 27.0, focusing Email at accessibility5 opened the software keyboard while leaving the field below the visible area. Replacing ViewThatFits with a single ScrollView improved this but initially left part of the field covered. Stable field IDs and scrolling on focus/viewport changes alone were insufficient after the keyboard animation. Re-centering after the native keyboard-did-show notification made the focused field visible. A route change now resets the scroll container so a completed operation does not inherit a previous field offset and hide its heading.

The normal recovery host now inherits system text size; only explicit larger-text fixture flags override it. New password uses Next to reach confirmation; confirmation uses Done. Secondary-button minimum height and content shape now belong to the button label so the visible spacing is part of the hit region.

## Selected native checks

Destination: iPhone 18 Pro/iOS 27.0 Simulator, isolated bundle `com.circleu.prototype.motionsimulator`. These are software-key presses through Device Hub accessibility actions, not a physical VoiceOver walkthrough or automated finger swipes. Invented values were used; no real credentials or account requests.

| Check | Evidence |
| --- | --- |
| Largest-text Email focus | Focused field visible above the software keyboard after the timing correction |
| Email software input / Next | Software letter key changed Email; Next moved focus to Password |
| Login Done | Missing password produced inline validation; an invented password advanced to the simulated check/backup review and dismissed the keyboard |
| Secret entry | Software input appeared as a masked value in the secure field |
| Reset-request Done | Valid invented email advanced to the generic notice; keyboard dismissed |
| Normal-text navigation | Email Next moved to Password; Forgot password opened reset and dismissed the login keyboard |
| Normal-text reset validation / Back | Empty reset Done retained the form with Enter a valid email address; Back returned to login and dismissed the keyboard |
| New-password Next / Done at largest text | Next moved to visible confirmation; Done with a mismatch showed validation; correction and Done advanced through simulated updating to the completion state |

The final route-reset build was exercised through new-password Next → confirmation Done → updating → completion; the heading returned to the top and the keyboard dismissed. Back returned to Log in with secrets empty. [Native largest-text Email/keyboard capture](../design/swiftui-previews/brand-10-login-keyboard-largest-simulator.png) shows the focused field above the keyboard (1206 × 2622, 492,928 bytes).

## Build and render verification

The isolated direct-compiler Simulator host and SwiftPM render-previews product built successfully. The initial sandboxed host build failed because the preview macro plugin could not start its nested sandbox; the approved unsandboxed build succeeded. Rebuilt after the final renderer-only fallback. The renderer initially left the ScrollViewReader content blank; the existing renderingSnapshot path now lays out static content directly. After that correction, all four retained v09 core/password/error/compact artifacts were byte-identical to the regenerated files. The core board and native keyboard image were visually inspected; historical PNGs were preserved. Native keyboard journeys preceded the final renderer-only extraction; that extraction compiled for iOS and did not change the interactive container logic, but every journey was not repeated afterward.

```sh
bash Prototypes/CircleUVisualPrototype/scripts/build-motion-simulator.sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build \
  --package-path Prototypes/CircleUVisualPrototype \
  --scratch-path /tmp/circleu-visual-preview-build --product render-previews
/tmp/circleu-visual-preview-build/debug/render-previews /tmp/circleu-keyboard-render-corrected
```

Interactive swipe-to-dismiss, Mac hardware-keyboard routing, all intermediate text sizes, rotation and compact-height coverage remain open. Earlier owner-reported scrolling checks preceded these fixes and are not automatically reclassified as a post-change gesture test.

## Accessibility Inspector results

The Inspector was opened from Xcode and targeted the isolated Simulator process. This checks the accessibility representation, not actual VoiceOver speech/gestures.

- Before the button fix, normal-text Log in reported **4 Hit Region** warnings; one expanded detail measured a SwiftUI node at **126 × 18**.
- After the button fix, Log in reported **0 Hit Region**, **2 Contrast**, **13 Dynamic Type** warnings. Both contrast details reported **1.09** for `#F5FAFF` versus `#E8F0FC`; selecting one showed a Forgot password? thumbnail with blue text. The discrepancy remains unresolved; no palette replacement or clean-audit claim.
- Reset request after the button fix reported **9 Dynamic Type** warnings and no Hit Region or Contrast category in that run.
- Earlier forced-accessibility5 runs reported 5 Dynamic Type warnings on the notice, and 8 Dynamic Type plus one clipped UIKitTextField warning on login with an invented email. The latter may involve single-line field presentation; it is not dismissed as a confirmed false positive.
- Changing the Inspector text-size slider from its original value to maximum visibly enlarged the normal host's login text. The original slider value was restored. This demonstrates scaling but does not resolve every automated warning.

The native accessibility tree exposes the screen heading, Email field, secure Password field and named actions in source order. Spoken labels, duplicate announcements, error announcements, focus after progress/navigation and rotor behavior still need the physical test below.

## Xcode and physical VoiceOver walkthrough

Open the original checkout's `Prototypes/CircleUVisualPrototype` package in Xcode, then `Sources/CircleUVisualPrototype/BrandRecoveryPreview.swift`. Canvas has Recovery · Log in, Reset password, New password, Largest text and error specimens. Use Live mode for interaction. Xcode's Device Hub is the separate phone window for a running Simulator app; static PNGs cannot test keyboards.

The owner connected an **iPhone 11 Pro Max / iOS 26.6.1** and reported completing Xcode Apple-account sign-in. Initial CLI inspection found no valid signing identity. Canvas then listed the physical iPhone with **Developer Mode disabled**; the owner reported enabling it and restarting. The subsequent CLI check reported the phone unavailable, so reconnecting/unlocking and clearing any remaining phone prompt is pending. Physical preview launch and signing are not yet verified. No original CircleU installation/data was changed. This phone's UI checks do not establish the proposed model/device capability scope.

After the isolated preview is running on the physical phone, enable Settings → Accessibility → VoiceOver and check:

- Swipe right/left through the heading, Email, secure Password and actions. Each has a useful name and logical order; decorative art must not interrupt the flow.
- Double-tap a field; type invented values. Next reaches Password, Done validates/submits, and content can be reached with the keyboard present.
- Find and activate Forgot password?, Send reset link and Back. Check error text is discoverable/announced and focus stays usable after validation, progress, completion and return.
- Repeat new-password/confirmation and an error fixture, plus Privacy → Done. No focus trap; passwords must remain secure.
- Repeat at larger text and verify VoiceOver scrolling reaches every action. Record observed speech/focus problems separately from visual findings.

Apple distinguishes [Accessibility Inspector](https://developer.apple.com/documentation/accessibility/accessibility-inspector) from [testing assistive technologies on a physical device](https://developer.apple.com/documentation/accessibility/performing-accessibility-testing-for-your-app). [Local device development](https://developer.apple.com/documentation/xcode/running-your-app-on-simulated-or-physical-devices) requires signing; it does not require releasing the production app.

## Limits

Physical VoiceOver remains pending. No production authentication, reset mail/token handling, Firebase, storage migration, full-app XCTest/CI, release or Today work. No new mirrored unit tests were added for these reversible view/host corrections; verification uses the native reproduction, compilation, renderer and Inspector evidence above.
