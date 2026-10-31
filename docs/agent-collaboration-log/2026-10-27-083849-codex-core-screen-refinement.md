# Native core screen refinement

- Recorded: 2026-10-27 08:38:49 +1100; Australia/Sydney
- Agent / role: Codex, implementer and coordinator
- Status: bounded native refinement implemented and reviewed; uncommitted
- Base: `9967a10`, `codex/app-upgrade-plan`; unrelated artwork and planning work preserved

## Request and scope

Owner asked to continue refining each screen after the landscape LinkedIn poster. Applied [the core-screen plan](../superpowers/plans/2026-10-27-core-screen-refinement.md) to Today, Journal/detail and Practice/home/editor. Preserved branding, native navigation, stores and Firebase boundaries. Supporting screens remain unchanged in this pass.

## Outcome

- Today: shallower scene and quieter nudge. Screenshot review reduced the initial 2.4:1 crop to 2.2:1 to preserve headroom.
- Journal: full-area ice background and compact inline entry date, with a full accessible timestamp on the secondary time.
- Practice: unified Pingu start card, decorative art omitted at accessibility text sizes, responsive suggestion width, pinned Save and visible editing failure feedback. Failed save dismisses keyboard focus and requests an accessibility announcement; words remain in the composer.
- Updated content guidelines and guest stories (102 criteria). Saved [12 unaltered native captures and gallery](../design/core-screen-review-2026-10-27/index.html), with per-image provenance/hashes. Opened local gallery on port 55987 and selected the running iPhone 17 / iOS 27.0 in Device Hub. Verified the native Today screen visually. No physical phone install, cloud operation, Figma write, commit, push or release.

## Verification

Command base: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild test -project Circleu.xcodeproj -destination 'platform=iOS Simulator,id=20743DB1-66DF-46E1-A234-9792A6606A4D' -derivedDataPath /tmp/circleu-quality-derived CODE_SIGNING_ALLOWED=NO PRODUCT_BUNDLE_PREFIX=com.circleu.quality`.

- New default Practice keyboard test failed against baseline: Save not hittable while typing with Situation/Goal expanded. Log `/tmp/circleu-ui-refine-red.log`.
- First focused run passed normal and AX5 bounds/save checks. Independent review identified that its initial TextEditor swipe did not prove outer-form motion.
- Full guest UI run: 22 tests, 19 passed, 1 live-Firebase skipped, 2 new scroll assertions failed because their gesture did not move form content. No existing-case failure. Result `Test-CircleuUITests-2026.10.27_08-19-17-+1100.xcresult`; log `/tmp/circleu-ui-refine-full.log`.
- Corrected the test to drag inside the visible region bounded by the navigation bar and pinned Save, rather than normalized scroll-view bounds. Both new tests then passed, asserting outer content movement, fixed Save, visible software keyboard, successful save and saved wording. Result `Test-CircleuUITests-2026.10.27_08-31-32-+1100.xcresult`; log `/tmp/circleu-ui-refine-final-focused.log`.
- After the final crop adjustment, all 3 Today UI tests passed, including largest text. Result `Test-CircleuUITests-2026.10.27_08-33-12-+1100.xcresult`; log `/tmp/circleu-ui-refine-today-final.log`.
- Final unit suite: 256 passed, exit 0. Result `Test-Circleu-2026.10.27_08-34-49-+1100.xcresult`; log `/tmp/circleu-ui-refine-unit-final.log`.
- Aggregate final coverage: 21 runnable UI cases passed across the full run and focused reruns; 1 intentionally skipped. Do not describe the earlier full run as wholly green.
- Visually inspected default Today, nudge with keyboard, empty Journal, entry detail, Practice home and largest-text keyboard captures; verified gallery display and PNG metadata/hashes. Documentation links and `git diff --check` checked.
- Not qualified: physical-device VoiceOver speech (including new failure announcement), real Firebase recovery, every compact device/text-size combination, live storage-failure UI, Release or TestFlight. Existing model failure tests do not certify error focus/announcement on a phone.

## Actual review exchange

Codex root requested source-only independent review from `core_ui_refinement_review`. Reviewer flagged editing save errors potentially offscreen after pinning Save and the TextEditor-scroll test ambiguity. Root moved errors next to Save, added focus dismissal/announcement and strengthened the gesture assertion. Reviewer rechecked with no remaining material source-level findings. Subsequent runtime evidence required adjusting only the test's gesture coordinates; no production workaround. Root owns executed test and visual evidence.

## Handoff

Owner visual review of [the native screens](../design/core-screen-refinement-2026-10-27.md). Remaining wider work is unchanged: hardware validation and further screen-specific design iterations, followed by separate release/backend qualification. No background agent remains working on this UI pass.
