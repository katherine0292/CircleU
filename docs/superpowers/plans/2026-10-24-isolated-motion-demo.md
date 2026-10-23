# Isolated Motion Demo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Review a finite Pingu greeting, screen transitions and Save/Copy feedback beside a reduced-motion version in a standalone native window.

**Architecture:** Extend only the existing visual prototype package with a public SwiftUI workbench and a macOS executable. Panels own fictional, process-memory sample state; no app imports, persistence, network or clipboard calls. Reuse existing brand resources and helpers.

**Tech Stack:** SwiftUI, existing Swift package, macOS native window, existing Plus Jakarta Sans and Pingu artwork. No new dependencies.

**Spec:** [Motion guideline](../../design/motion-guideline.md), plus owner approval of the small demo on 24 October 2026. Approval covers isolated execution, not production animation adoption. Coordinator executes inline on the suitable existing `codex/journal-calendar-planning` branch.

## Global constraints

- Keep the main app, Xcode project, assets, Firebase and data untouched.
- One finite greeting, under 600 ms; no perpetual movement, timer or fake blink.
- Writing screen stays still. Save/Copy are explicitly sample feedback; no actual storage or clipboard operation.
- System Reduce Motion always wins; forced comparison may reduce motion further, never re-enable it.
- Keep historical renders unchanged; live native interaction evidence is separate from static ImageRenderer evidence.

## Review focus

1. Changing reduced-motion preview while a greeting is active immediately yields a still pose.
2. Re-entry/backgrounding does not leave a decorative loop or repeated timer running.
3. Editing after Save/Copy invalidates stale completion feedback; empty input cannot show success.
4. Navigation retains sample drafts; editor focus/input is never gated by animation.
5. Both panels remain usable with motion disabled and expose labelled native controls.

## Task 1: Native workbench and launcher

**Files:** Create `Sources/CircleUVisualPrototype/BrandMotionDemo.swift`, `Sources/MotionDemo/CircleUMotionDemoApp.swift` and `scripts/build-motion-demo.sh` under `Prototypes/CircleUVisualPrototype/`; modify its `Package.swift`.

**Interfaces:** Public `BrandMotionDemo: View`; executable product `motion-demo`; script builds a disposable `.app` under `/tmp` and prints its location. No new production interface.

- [x] Confirm `swift build --scratch-path /tmp/circleu-visual-preview-build --product motion-demo` fails because that product is absent (checked before implementation).
- [x] Implement two independent panels: normal/system setting and forced reduced motion. A comparison toggle lets the first panel be forced still without overriding the OS. Use finite native keyframes for a ±3°-or-less greeting, about 500 ms, only while Today is visible and the scene active.
- [x] Add Today → writing / message transitions, labelled Save/Copy sample feedback, draft retention, empty-input disabling, reset and greeting replay. Keep sample disclosure outside the specimen.
- [x] Build product and `.app`; verify bundled font/artwork are available.

**Verification:** Standalone build must exit 0; native window must show both usable panels with no missing artwork. This reversible visual demo uses build and live interaction checks rather than a unit suite mirroring view state.

## Task 2: Runtime review, evidence and handoff

**Files:** Create `docs/design/brand-demo/motion-demo.md`, a dated agent record and any focused review evidence; update package README, design guideline/index and this plan. Use a screenshot only from the demo window.

- [x] Open the native window and check greeting/replay, both navigation routes, text editing, Save/Copy feedback, empty input, draft retention, forced reduced motion and reset.
- [x] Check active/inactive handling through source and live app switching; distinguish it from a device lifecycle test. Assess the OS reduced-motion path in source unless actually changed/tested.
- [x] Request one fresh read-only review of the scoped implementation against the five review-focus conditions; resolve material findings and repeat affected checks.
- [x] Document results/limitations, check relative links/whitespace and production-path diffs. Rebuild/render existing static package if shared resources or renderer are affected; no static render is animation evidence.
- [x] Commit/push explicit scoped files using the existing authorization, verify local/remote SHA; do not merge/release.

**Completion:** User can open and interact with the standalone demo; reports clearly identify simulated actions, native macOS evidence and remaining iPhone/accessibility/performance checks.

Completed as an isolated demo. See [native evidence and remaining checks](../../design/brand-demo/motion-demo.md) and the [dated work/review record](../../agent-collaboration-log/2026-10-24-091057-codex-isolated-motion-demo.md). The enclosing scoped commit/push publishes this milestone; no merge or release.
