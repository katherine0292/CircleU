# CircleU native preview host

Status: Simulator build and selected navigation verified, 24 October 2026. The owner confirmed Log in opens on the physical iPhone (25 October update); selected on-phone keyboard, VoiceOver labels/error/Back and maximum-text regular-route checks passed by owner report; the owner explicitly confirmed all three New password checks work with VoiceOver and maximum text, and the separate Simulator checks also passed; broader accessibility coverage remains pending. ContentView is back on the normal Log in entry.

Open `CircleUPreviewHost.xcodeproj` in Xcode for a normal Run of the existing local `CircleUVisualPrototype` library. Close the standalone package window before adding/opening the same local dependency in this project; that resolved a disabled Add Package button during setup. The production Circleu project remains separate.

The app starts at Log in using `BrandOnboardingPreview(initialScreen: .logIn)`. Back returns to Welcome. Password reset and earlier-data routes use invented, process-memory fixtures; no authentication, email, network, import or persistence service is connected. Never enter real credentials.

The target settings are configured in Xcode: bundle `com.tuannm3812.circleu.preview`, display name **CircleU Preview**, iPhone only, iOS 17 minimum, Swift 6, automatic signing with the owner's Personal Team. The unused draft xcconfig was removed. These are preview-host settings, not a change to production device scope. Signing certificates/profiles and user state stay outside Git.

## Run and review

1. Select the CircleUPreviewHost scheme and your connected iPhone, then Run. The first signing operation may ask for the Mac/login keychain password; complete that protected system prompt directly on the Mac.
2. Use the physical phone for VoiceOver speech/gestures. Device Hub reported that screen sharing from this iOS 26.6.1 phone requires iOS 27; no phone upgrade is needed to perform the test directly on the phone.
3. Follow the [keyboard and VoiceOver checklist](../../../docs/qa/native-recovery-keyboard-accessibility-2026-10-24.md). For an otherwise unreachable reset-token/error specimen, select the existing named Canvas preview in `BrandRecoveryPreview.swift`, or temporarily select its existing `recoveryScreen` argument in ContentView for device review. Keep fixture configuration separate from product UI.

## Verification

`xcodebuild -showBuildSettings` confirmed the effective bundle, deployment, platform, family and language settings. An unsigned generic iOS Simulator build succeeded. The built app installed/launched on iPhone 18 Pro/iOS 27.0 Simulator; the accessibility tree showed Log in, Email, secure Password and named actions. Forgot password → Reset password → Back to Log in worked. The package's artwork/font resource bundle was present in the built app. This does not establish physical VoiceOver results.

The owner completed the Mac keychain prompt. On 25 October, device inventory confirmed the separate app installed. Launch was denied, and Xcode explicitly reported that the Developer App Certificate is not trusted. On the phone, open Settings → General → VPN & Device Management → Developer App and select your own signing account’s certificate to trust it, then open CircleU Preview. This allows locally signed apps from that account to run. The earlier on-device Canvas DeveloperToolsSupport failure remains unresolved; this normal-Run host is the fallback. The owner subsequently confirmed that the Log in screen appears on the physical phone. The owner also reported that Email Next → visible Password, login Done → Earlier data with keyboard dismissed, and reset Email Done → Check your email all work. The owner also reported VoiceOver reads labels/error and Back works, then confirmed maximum-text Welcome/Privacy/earlier-data reachability. The [25 October review](../../../docs/qa/native-onboarding-final-review-2026-10-25.md) tracks the New password results and broader Inspector/accessibility limits. On 25 October the temporary New password ContentView was restored to `BrandOnboardingPreview(initialScreen: .logIn)`. The Simulator rebuild showed Log in. The restored build was signed and installed on the phone, and, after the phone was unlocked, launched. The owner's phone screenshot shows Log in with empty Email and Password.

The generated project uses a synchronized source folder. Add source there rather than hand-editing project file references. It links only the library product, not the package's rendering/motion executables, and has no nested Git repository.
