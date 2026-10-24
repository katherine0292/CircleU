# iPhone-width motion prototype validation

- Recorded: 2026-10-24 16:06:01 +1100; Australia/Sydney.
- Agent / role: Codex coordinator; read-only source reviewer `iphone_motion_review`.
- Status: responsive prototype and Simulator launch/layout milestone complete; live iOS interactions pending.
- Base revision and branch: `73615ef68e6dcbbc3acc32040cb633ee8b6df0a4`, `codex/journal-calendar-planning`; initial tree clean, reused suitable branch.
- Related record: [original native motion demo](2026-10-24-091057-codex-isolated-motion-demo.md).

## Request and scope

Owner asked to continue the approved isolated motion demo. Scope is compact prototype validation using existing art/font, with continuing scoped commit/push authorization. No production integration, Firebase changes, Xcode project modification, migration, merge or release.

## Work and outcome

[Instructions and evidence](../design/brand-demo/motion-demo.md) and [validation plan](../superpowers/plans/2026-10-24-iphone-motion-validation.md) record the deliverable. Below 800 points the workbench displays one selected comparison; `AnyLayout` preserves panel identity/drafts across width changes. Hidden panels are disabled, excluded from hit testing/accessibility, clear existing editor focus and cannot animate. Added iOS keyboard Done and scroll dismissal; live iOS keyboard behavior remains unverified. Native Mac Preview menu offers 390-point compact and desktop windows.

A separate direct-compiler arm64 Simulator host reuses the same sources and only required bundled assets/font/license. It has its own prototype bundle ID and disposable `/tmp` output, with no `.pbxproj`, signing-team, package dependency or main-app change. Both packaging scripts ad-hoc sign their completed bundles. The existing Mac bundle failed signature verification before that correction; the final bundle passes.

## Verification

- `bash Prototypes/CircleUVisualPrototype/scripts/build-motion-simulator.sh`: final host builds/signs, Xcode 27.1/Swift 6.4, installed iPhoneSimulator27.1 SDK, arm64 iOS 17 Simulator compilation target. This does not validate iOS 17 runtime compatibility or change the product device scope.
- `swift build --package-path Prototypes/CircleUVisualPrototype --scratch-path /tmp/circleu-visual-preview-build` with command-specific Apple toolchain/module caches: complete standalone package passed. `bash .../scripts/build-motion-demo.sh` passed afterward. `codesign --verify --deep --strict --verbose` passed for both disposable bundles.
- Final host installed/launched with `simctl` on iPhone 18 Pro/iOS 27.0 and iPhone 17e/iOS 26.5. Unmodified launch captures are linked from the evidence document; dimensions 1206×2622 and 1170×2532. Visually checked actual font/art, compact selector and initial content horizontal fit. Lower controls are below fold; launch frames do not establish scrolling or animation.
- Native Mac compact checks exercised message Save/Copy feedback, separate comparison drafts, selected-panel-only accessibility content, focus clearing, reduced replay disabling, and expansion to desktop with retained draft/feedback. After the source-review fix/rebuild, rechecked compact message whitespace disabling, valid Save/Copy feedback and comparison focus clearing. Original reflection/replay/reset evidence remains historical, linked above, not a new iOS test.
- Some CUA actions returned transient AX errors; settled reads/screenshots confirmed resulting selected pages/controls. An earlier scroll/raise routing attempt returned noWindowsAvailable; subsequent editor inspection showed reachable lower actions. No success is inferred merely from invoking an action.
- Renderer completed all 48 exports with the actual font-family assertion; dimensions match historical output. Fresh Today and baseline were visually compared. All fresh PNGs differed in bytes/pixels despite unchanged static-catalog source; fresh output retained temporarily and historical PNGs restored to exact base bytes. No equivalence claim. Existing artwork and production paths preserved.
- Shell syntax, bundle plists/signatures, relative documentation links, image sizes, scoped diff and whitespace checked before commit. Final push/remote SHA checked during publication; no CI pass is claimed.
- Not run: main app or unit suite (isolated reversible preview has no behavior-test target), live iOS touch/keyboard/Done/scroll/rotation, physical devices, live Canvas, VoiceOver, Dynamic Type, real OS Reduce Motion changes, lifecycle interruption, precise timing/comfort/performance. CoreSimulator CLI works, but no Simulator GUI app could be resolved in this Xcode installation.

## Discussion and decisions

Coordinator requested a fresh read-only review from `iphone_motion_review` under the plan and requesting-code-review skill. Reviewer found that hiding with opacity/hit-testing/accessibility alone did not disable hidden keyboard actions; existing focus cleanup only cleared the current responder. Coordinator added `.disabled(!visible)`. Reviewer inspected the mitigation and reported no remaining material source findings, while explicitly leaving live UI/accessibility behavior unverified. Coordinator rebuilt both hosts and performed the final native checks above. Reviewer ran shell/whitespace checks, no builds/UI, and modified no files. No other agents or external communications.

## Handoff

- Remaining work: owner review of motion feel; live iOS keyboard/Done, scrolling, rotation and accessibility checks using a working Simulator GUI or physical device before production adoption.
- Owner: Unassigned; no background task scheduled.
- Risks / unresolved questions: Save/Copy are simulations; keyboard/VoiceOver support is not certified. All production Firebase/cloud/local-data and legacy recovery questions remain separate and unchanged.
