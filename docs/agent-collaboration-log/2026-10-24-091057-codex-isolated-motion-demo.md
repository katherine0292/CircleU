# Isolated native motion demo

- Recorded: 2026-10-24 09:10:57 +1100; Australia/Sydney; final publishing checks continued in the same session.
- Agent / role: Codex coordinator; read-only reviewer `motion_demo_review`.
- Status: isolated demo implemented and checked on native macOS; owner motion review pending.
- Base revision and branch: `7ab6b80683dd3bc6e69543e82a8095c2f5d3c6f8`, `codex/journal-calendar-planning`; reused the suitable clean prototype branch.
- Related record: [full avatar collection](2026-10-24-075244-codex-pingu-full-collection.md).

## Request and scope

Owner explicitly approved the proposed small animation demo: gentle Pingu greeting, short screen transitions and Save/Copy feedback, with reduced-motion support and still writing screens. Approval covers the isolated preview, not main-app integration. Existing commit/push authorization applies; no merge or release.

## Work and outcome

[Demo instructions/evidence](../design/brand-demo/motion-demo.md) and [implementation plan](../superpowers/plans/2026-10-24-isolated-motion-demo.md) document the deliverable. Added `BrandMotionDemo` and a macOS executable/product to the existing package, plus a script building a disposable `/tmp/CircleU Motion Demo.app`. Reused current font/colors/Pingu and native SwiftUI; no new dependency, artwork, main-app import, Firebase, disk data, network or clipboard operations.

Two independent panels show normal/system-governed motion and forced reduction. A 500 ms native keyframe greeting has one 3° tilt and return; motion-off/inactive-scene selects still art. No timer, repeated animation or sleep task. Editors stay still; page/feedback transitions are brief. Fictional sample drafts are editable in process memory, retained through page navigation and resettable. Save/Copy only display completion cues, with a clear workbench disclosure. Edits invalidate stale cues and whitespace disables the relevant actions.

## Verification

- Before implementation, building `--product motion-demo` failed because the target did not exist, as expected. After implementation, `bash scripts/build-motion-demo.sh` succeeded and produced the review `.app`; a complete standalone `swift build --scratch-path /tmp/circleu-visual-preview-build` also passed. Builds used command-specific Xcode toolchain/module cache settings.
- Native CUA opened the `.app`, showing font/artwork and both panels. Checked reflection Save, edit invalidation, whitespace disabling, draft retention through Today navigation, independent message Save/Copy, message edit invalidation, blank-message disabling and actual typing in the always-reduced panel. Both Saved and Copied can coexist. Reset returns both to Today without changing the preview reduction setting.
- Replayed greeting and toggled forced reduction immediately afterward; replay became disabled and still branch selected. Exact 500 ms timing/interruption was not instrumented. Source establishes finite keyframes and disabled/inactive branches. Native app switching was exercised but did not independently establish inactive-scene interruption.
- Transient native accessibility query failures following updates resolved on settled reads/screenshots; no app change was made for that observation. One UI assertion expected separate Saved/Copied text nodes; inspecting the actual tree showed a combined node, and the corrected check passed. This was a check correction, not an app regression.
- Renderer rebuilt and completed all 48 existing exports with the actual font-family assertion. Every PNG remains byte-identical to base. Shell syntax, disposable app plist, 77 affected-document relative links, whitespace and absence of production-path diffs checked. Final log links/staged scope checked before publishing.
- Not run: production app, iPhone Simulator/device, live Canvas, real OS Reduce Motion toggling, VoiceOver announcements, Dynamic Type, low-power/performance/comfort or precise temporal instrumentation. The demo is reversible visual review code; proportionate evidence is native build/interaction checks rather than a unit suite mirroring view state. No claim of certified accessibility, local-only production behavior or CI.

## Discussion and decisions

Coordinator dispatched one focused read-only review against the scoped files and five review-focus conditions. Reviewer `motion_demo_review` reported no material findings: finite 500 ms greeting/no timer, motion-disable branches, draft retention, stale-feedback invalidation, empty-input disabling, independent memory-only feedback, labelled controls and correct app resource bundling. Reviewer ran shell/whitespace checks and inspected source/resources, not native interactions. It explicitly left exact timing, live system-setting changes, lifecycle and VoiceOver announcement behavior unverified; those limitations remain documented. No additional agents or external communications.

## Handoff

- Remaining work: owner review of native motion feel; independently validate accessibility/device/lifecycle behavior before any production integration.
- Owner: Unassigned for a future implementation task; no background work scheduled.
- Risks / unresolved questions: completion actions are simulations, not actual persistence/clipboard; a whole-image tilt is not a flipper/eyelid rig. Main-app animations and existing Firebase/data/recovery state remain untouched.
