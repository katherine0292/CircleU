# Repair original build and align the device viewer

- Recorded: 2026-10-24 18:09:26 +1100; Australia/Sydney.
- Agent / role: Codex coordinator.
- Status: original app builds and launches; 2 existing-suite assertions remain failing.
- Base revision / branch: `6ba477a5ce212b1b680c6a9908ca81436c3d4a29`, `codex/journal-calendar-planning`. Preserved three untracked Xcode handoff records from the preceding turns.
- Related: [failed original Run](2026-10-24-174356-codex-original-project-run-check.md), [repair evidence](../qa/simulator-build-repair-2026-10-24.md).

## Request and scope

Owner supplied the eight Xcode diagnostics and requested checking the issue and iPhone 17/18 simulation. Repaired the existing build/component compatibility and asset warnings needed to run the original app; no MVP implementation, redesign integration, backend, bundle/deployment-target or release change.

## Work and outcome

Fresh CLI build reproduced the missing reading/waving/thumbsUp enum members; subsequent compilation exposed calm/watering, and an all-call-site search found explorer. Added the six already-requested poses, existing asset selection and still treatment for complete illustrations. Existing idle/think/celebrate/pop animations retained. Visual launch exposed the misnamed PinguWaves abstract background; waving now deliberately falls back to the existing PinguMascot. Existing cropped/labelled legacy assets remain for later design review; no new art generated.

Moved three unused JPEG originals from image sets to the documented legacy artwork archive, retaining exact Git bytes and active PNG manifests. Updated one stale analytics-test fixture from private property assignment to the store's existing public replace operation; no store API/access change.

Located the graphical device viewer at Xcode's `Contents/Applications/DeviceHub.app`. The earlier search under `Contents/Developer/Applications/Simulator.app` was incomplete. Device Hub first showed the old motion demo on iPhone 17e/iOS 26.5 while the original app's Xcode target was iPhone 18 Pro/iOS 27.0. Selected the matching device; the original app is now visible there. Updated current device/motion documentation with this correction, without rewriting published work logs. The initial Device Hub tool call took several minutes; no unchanged poll loop or app-setting workaround was used.

## Verification

- Before/after `xcodebuild build`, original project/scheme, iPhone 18 Pro UUID `C7B63706-4D1C-4B7F-A161-8A2339D14E2B`: red missing-pose compile errors, then green. Final build after the waving correction passed. Reported three unassigned-child warnings removed; remaining analytics actor-isolation/AppIntents warnings documented.
- Asset moves compare equal to `git show HEAD:<old-path>`; selected image references exist. Original assets/history preserved.
- Existing full suite initially could not compile its stale fixture. After that fixture repair: 95 tests executed, 93 passed, 2 failed. Named failures and assertions are in the QA record: QA export character count 24 versus 23, and account reset name Friend versus empty. No green suite claim; these are outside the mascot change and were not altered to make verification green.
- Original app absent before selected-Simulator install. CLI launch returned a process; final Xcode-native Run reported Running Circleu on iPhone 18 Pro. Native Device Hub state showed original Welcome with PinguMascot, matching the corrected final screenshot. No sign-in, import, user-data deletion or backend validation performed.
- Device Hub and original app were kept available for review. iPhone 17 runtimes were inventoried only; no iPhone 17 launch/support claim. No physical-device, new-MVP, accessibility or full app-flow certification.
- Whitespace, relative links, final scoped diff and exact archive moves checked before publication. Scoped commit/push authorization continues from earlier owner direction; no CI pass claimed.

## Discussion and decisions

None. No agent/other-chat exchanges or external communications. Build compatibility repair is separate from authorizing planned features or new visual integration.

## Handoff

- Remaining: review the two failing test contracts; runtime diagnostics; existing mascot animation lifecycle; legacy asset crops; then separately agree prototype integration and phone-safe-area/navigation work.
- Owner: Unassigned. No background work scheduled.
- Risks: original app remains account/cloud capable. Working original onboarding is not the new guest-first design; Simulator launch is not a release/data-recovery guarantee.
