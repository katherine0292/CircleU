# iPhone Motion Demo Validation Plan

> **For agentic workers:** Use superpowers:executing-plans for this scoped continuation. Owner requested continuation after the isolated demo; this remains prototype validation, not main-app integration.

**Goal:** Make the isolated motion workbench usable on iPhone widths and validate it in installed Simulators.

**Architecture:** Reuse the existing SwiftUI source. Switch the comparison layout at 800 points, preserving panel identity with `AnyLayout`; compact mode displays one selected panel. Add an isolated iOS Simulator host compiled with Apple's installed toolchain and a distinct bundle identity. No `.pbxproj`, signing team, production target or dependency changes.

**Spec:** [Motion guideline](../../design/motion-guideline.md) and [native demo scope](../../design/brand-demo/motion-demo.md).

## Constraints and review focus

- Preserve fictional drafts when switching comparisons or layout. Hide inactive panel from input/accessibility and disable its decorative movement.
- System Reduce Motion always wins. Editors stay still; Save/Copy remain simulated feedback with no persistence/network/clipboard.
- Support narrow widths without horizontal clipping; keyboard must be dismissible and controls reachable through scrolling.
- Use only installed Simulator runtimes. No physical-device or certified accessibility claim.
- Preserve the main app, its project/settings, existing assets and 48 historical renders.

## Task 1: Responsive workbench and isolated iOS host

- [x] Modify `Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/BrandMotionDemo.swift`: compact selection, width-aware panels, identity-preserving layout, inactive-panel gating and iOS keyboard dismissal.
- [x] Create `Prototypes/CircleUVisualPrototype/SimulatorHost/CircleUMotionSimulatorApp.swift` and `scripts/build-motion-simulator.sh`. Build only the required demo sources and copied reference resources into a disposable Simulator `.app`; use no Xcode-project modifications or production package services.
- [x] Build native macOS package/launcher and Simulator host; correct actual compiler errors before runtime checks.

## Task 2: Simulator checks and evidence

- [x] Install/launch final host on iPhone 18 Pro/iOS 27.0 and iPhone 17e/iOS 26.5; inspect initial layout captures. Native Mac compact checks exercise comparison/draft/feedback/resize behavior.
- [ ] Live iOS touch, scrolling, rotation, text editing/Done keyboard, Save/Copy, empty input, comparison retention and forced reduction: pending because Simulator GUI is not resolvable in this Xcode installation. CLI launch/layout does not establish interaction behavior.
- [x] Review source for system-reduction/inactive-scene handling and no hidden-panel motion; distinguish it from live OS/VoiceOver/device checks.
- [x] Obtain one focused source review and address material findings: disabled hidden-panel keyboard actions. Both hosts rebuild; catalog regeneration succeeds and original PNGs are preserved.
- [x] Complete final links (76 local targets), shell syntax, bundle signatures and production-path diff checks. All 48 historical PNGs match base exactly.
- [x] Document actual evidence and limitations, append dated log and prepare scoped publication to the existing branch under continuing authorization. Commit/push and remote-SHA verification are the final publishing actions; no merge or release.
