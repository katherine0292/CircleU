# Supported devices and validation matrix

Status: recommended release scope, 23 October 2026; hardware validation pending. The owner approved guest-first local storage, confirmed a previous TestFlight release, and suggested testing on a latest-generation iPhone. An exact physical model/OS and availability have not been confirmed.

## Recommended scope

Target the new MVP at **iPhone, iOS 26.0 and later**, initially qualifying the iOS 26 and 27 families. English UI first. This reduces the OS combinations for a small beta and aligns the optional Foundation Models integration with its introduction in iOS 26. It is a scope choice, not a requirement imposed by local storage: retaining iOS 17 with manual fallbacks remains technically possible if the tester inventory justifies the additional support work.

| Capability | Recommended support contract |
| --- | --- |
| Core Today, Journal and Practice | Every iPhone supporting the selected OS, including iPhone 11 and SE (2nd generation). Typing, editing, saving, search, manual practice, export and deletion must not require AI or an account |
| On-device AI suggestions | Optional on eligible hardware, including iPhone 15 Pro/Pro Max and iPhone 16 models or later. Check actual Foundation Models availability, language, region, settings and model readiness every time; device name alone is insufficient |
| Voice input | Independent capability check. Require on-device recognition for the selected locale; if unavailable or permission denied, offer typing without losing text |
| iPad, Mac, Watch, Android and web | No new MVP experience promised. Preserve existing iPad users' recovery access during transition; investigate distribution constraints before changing device family |
| Future OS versions | Qualify before claiming support; an open-ended deployment target is not evidence of testing |

Apple lists iPhone 11 and SE (2nd generation) among compatible hardware for [iOS 26](https://support.apple.com/guide/iphone/iphone-models-compatible-with-ios-26-iphe3fa5df43/26/ios/26) and [iOS 27](https://support.apple.com/en-sg/guide/iphone/iphe3fa5df43/27/ios/27). The iPhone 15 and 15 Plus are examples of core-app devices without Apple Intelligence. Apple's [Intelligence requirements](https://support.apple.com/en-au/121115) define eligibility; the app must additionally check [Foundation Models availability](https://developer.apple.com/documentation/FoundationModels/generating-content-and-performing-tasks-with-foundation-models). No AI performance claim is established yet.

Use English content and evaluate Australian and US English speech locales where supported; do not silently use a remote recognizer to cover a missing locale. Apple's [on-device speech requirement](https://developer.apple.com/documentation/speech/sfspeechrecognitionrequest/requiresondevicerecognition) only applies when the recognizer reports support. Model assets may need an initial download; distinguish setup from offline generation.

## Preserve existing installs first

The project currently declares **iOS 17.0 and iPhone + iPad**. The [uploaded TestFlight 1.0 (1) metadata](../engineering/legacy-data-inventory.md) now confirms the same minimum iOS and device family; that build is expired. Keep those settings and the existing bundle identity for the proposed migration build. Do not raise the floor or remove account access before providing access/export/deletion for existing users. Six installs are reported, but tester device models/OS versions and remaining local copies are not known. Metadata also lists macOS 14.0 and visionOS 1.0 minimums; this does not prove installations or validated support there. New-MVP support and legacy-data recovery are separate release commitments. See the [transition plan](../superpowers/plans/2026-10-23-local-first-transition.md).

## Minimum validation matrix

All rows are **pending**, not certified. A single latest iPhone is a useful starting point, but cannot establish older-device behavior.

| Test target | Evidence required before a beta support claim |
| --- | --- |
| Latest available physical AI-capable iPhone, iOS 27 | Full reflection/practice journeys, microphone, offline inference, interrupted generation, model disabled/unavailable, lock/unlock, export/share, VoiceOver |
| Physical AI-capable iPhone on supported iOS 26 release | Same core and model contract on the older OS/model version; do not assume newer-model prompts behave identically |
| Physical non-AI iPhone, such as iPhone 11/13/15 or SE | Useful manual flow, voice availability/fallback, offline operation, memory pressure and responsiveness. Obtain access through an existing tester or borrowed device; no purchase assumed |
| Minimum OS 26.0 simulator, plus current 26/27 runtimes | Availability guards, persistence/migration tests and layout. If the declared minimum cannot be validated, resolve the supported floor before release |
| Compact SE-sized and large iPhone layouts | Keyboard visibility, scrolling, large Dynamic Type, dark mode, reduced motion and focus order; combine simulator layout checks with physical accessibility testing |
| Existing TestFlight install → migration build → MVP | Guest and account scopes, offline/expired login, interrupted import, edits/deletions, no duplicates or resurrected records. Include iOS 17 and iPad recovery if used by previous testers |

Record model, OS/build, app build, model availability, locale, scenario, result and evidence for each run. Never label a capability supported because only a mock or simulator passed. Existing Firebase QA checklists are templates, not evidence that previous releases passed.

## Toolchain and release gates

- Xcode **27.1 (27A9275)** was verified with a command-specific developer directory. No app build/test was run for this planning pass.
- CI currently selects Xcode 16.0 on `macos-15`; plan a verified runner/SDK/runtime combination before using CI as a release gate.
- The latest sandboxed simulator inventory attempt failed to connect to CoreSimulatorService. Earlier inventory is recorded in the discovery plan; available runtimes must be rechecked before testing.
- Freeze the OS floor after tester inventory and a bounded local-storage/model/speech feasibility spike. Record unsupported capabilities as fallbacks, not blockers to the core app.
- Release only after the matrix, legacy recovery route, privacy/network checks and P0 acceptance criteria pass. No minimum OS or project settings were changed by this document.
