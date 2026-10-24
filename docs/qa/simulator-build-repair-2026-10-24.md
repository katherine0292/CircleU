# Original app build and Simulator repair

24 October 2026. Scoped compatibility repair after the owner reported the original project's build diagnostics and confusion about the simulated phone. This does not integrate the new prototype, change deployment targets/bundle identity, or implement guest-local storage.

## Findings and repair

- The original root project is `Circleu.xcodeproj`, scheme **Circleu**. The isolated **CircleUVisualPrototype** package and its motion host are different review products in the same repository.
- The five red diagnostics in the supplied screenshot were Swift compiler failures, independent of choosing iPhone 17 or 18. Existing screens requested poses missing from `PinguMood`. A fresh CLI build reproduced them; further compilation exposed calm/watering, and source inspection also found explorer.
- [PinguGlassKit.swift](../../Circleu/Design/PinguGlassKit.swift) now recognizes all six existing pose requests and selects existing artwork. These whole illustrated poses stay still; original idle/think/celebrate/pop behavior is retained. The `PinguWaves` asset was visually checked and is an abstract background, so waving deliberately retains `PinguMascot` as a fallback. No new animation, generation or artwork replacement.
- Three unassigned JPEGs caused the yellow asset warnings. They were moved byte-for-byte to the [legacy artwork archive](../design/legacy-artwork/README.md), preserving Git history and the PNGs already selected by the image sets. No image recompression or data deletion.
- The existing test target initially failed to compile because `AnalyticsTrackerTests` assigned the private `QuestStore.quests` setter. Its fixture now uses the existing public `replaceAll(with:)` method. Production store access remains unchanged.

## Phone/viewer distinction

CLI inventory showed iPhone 18 Pro on iOS 27.0 (UUID `C7B63706-4D1C-4B7F-A161-8A2339D14E2B`), plus iPhone 17 profiles on iOS 26.5 and 27.0. These are virtual profiles, separate from any physical phone. Only the iPhone 18 Pro original-app launch is checked here.

This Xcode installation's graphical viewer is **Device Hub**, at `/Applications/Xcode.app/Contents/Applications/DeviceHub.app`; its bundle metadata identifies version 27.1. It initially displayed the older CircleU Motion Demo on iPhone 17e/iOS 26.5 while Xcode's original scheme targeted iPhone 18 Pro. Selecting the matching device fixes that review mismatch. Canvas previews, a running Simulator app and physical-device evidence remain different checks.

## Verification

Commands used command-specific `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` and normal developer-service access. No global developer-directory change.

1. `xcodebuild build -project Circleu.xcodeproj -scheme Circleu -destination 'platform=iOS Simulator,id=C7B63706-4D1C-4B7F-A161-8A2339D14E2B' -disableAutomaticPackageResolution` failed before the repair with the missing poses, then passed after reconciling all callers. The final build also passed after the waving fallback correction. No unassigned-child warnings remained. An existing analytics actor-isolation warning appeared during compilation; AppIntents metadata extraction was skipped because the app has no AppIntents dependency. Neither was silently treated as fixed.
2. Existing JPEG bytes were compared with `git show HEAD:<original-path>` after moving; all three were identical. Selected image-set file references resolve.
3. The original app was absent from the selected Simulator before installation. Installing and launching the built `edu.uts.tuannm3812.Circleu` returned a running process. Screenshot inspection showed the original account-based onboarding, separate from the new design. No sign-in, import, deletion or feature walkthrough performed. This is launch evidence, not full runtime validation.
   - Final native Xcode Run also reported **Running Circleu on iPhone 18 Pro**, cleared the earlier missing-pose errors and unassigned-asset warnings, and Device Hub exposed the corrected `PinguMascot` on Welcome. Runtime console diagnostics included Firebase initialization/swizzling and Simulator accessibility warnings; no backend-health or runtime-warning-free claim.
4. Full `xcodebuild test` on the same destination with `-parallel-testing-enabled NO`: **95 executed, 93 passed, 2 failed**. No successful-suite claim. Failures were:
   - `AnalyticsTrackerTests.testQAExportCopiedTracksWithPrivacySafeProperties`: expected character count 24; observed 23 for the test's literal text.
   - `BackendSessionStoreTests.testDeleteAccountPurgesCloudBackupDeletesAuthAndResetsAllLocalStores`: expected reset name Friend; observed an empty string.
5. The test command also logged unavailable `simctl` in a subprocess PATH and a Simulator audio-device warning. Command-specific CLI `simctl` inventory/install/launch worked. Their wider effects were not investigated in this visual/build repair. A discarded `xcodebuild -dry-run` check reported the option unsupported; it was not used as build evidence.

The two test failures are outside the mascot repair; their expected contracts need review separately. No account/deletion behavior was changed to satisfy them. Existing test fixtures include invented data; no real user records were used.

## Remaining checks

Review the existing asset crops/labels and the new accepted art separately before production branding adoption. Waving is a known static fallback. Older animations still need the lifecycle/Reduce Motion work recorded in the motion guideline. iPhone 17 launch, text scaling, VoiceOver, rotation, keyboard, real speech/model capability, cloud behavior and physical-device support remain unverified by this task. Keep previous TestFlight data/recovery protections intact.
