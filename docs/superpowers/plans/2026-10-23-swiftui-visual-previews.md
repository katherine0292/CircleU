# SwiftUI Visual Previews Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans for this small preview-only task. Steps use checkboxes. The user explicitly approved Figma plus static SwiftUI previews; application runtime/migration work stays deferred.

**Goal:** Review Today, Journal and Practice from Draft 02 in Xcode and exported SwiftUI renders using invented content.

**Architecture:** An independent, dependency-free Swift package under `Prototypes/CircleUVisualPrototype/` contains immutable sample screens, shared draft components and Xcode previews. A macOS ImageRenderer utility exports review PNGs without launching the Circleu app. The existing app target, startup and Firebase configuration are untouched.

**Tech Stack:** SwiftUI, Swift Package Manager, Xcode 27.1; iOS 17/macOS 14 preview-library platforms are harness compatibility, not a new application support policy.

**Spec:** User confirmation in this chat plus [Draft 02 reference](../../design/README.md), Figma frames `11:100`, `11:104`, `11:107`.

## Constraints and review focus

- Static visual scope only: no persisted state, networking, authentication, cloud initialization or simulated working Save actions. The Figma prototype remains the interactive flow reference.
- Use exact draft copy/colors/radii. Existing native rounded system typography replaces Figma's documented Inter fallback; document this comparison difference. Do not draw a fake operating-system status bar.
- Keep draft-only assets inside this package, not a new production design system. Existing glass components cannot express the current flat research draft accurately.
- Three screen previews plus a side-by-side gallery, compact-width visual check and explicit preview labels. Generated images are design renders, not app/Simulator screenshots.
- Preserve the dirty checkout; new preview files are isolated by directory and have no dependency on the app target. No branch switch, commit or push.

## Task 1 — Gallery and sample screens

**Files:** `Prototypes/CircleUVisualPrototype/Package.swift`, `Sources/CircleUVisualPrototype/{PrototypeScreen,PrototypeViews,PreviewGallery}.swift`, bundled color assets.

- [x] Read all three high-fidelity Figma contexts and screenshots; inspect existing native tokens and preview side effects.
- [x] Add immutable sample content, reusable cards/actions/tab representations and named color resources.
- [x] Add named Xcode previews; keep static action affordances noninteractive and labelled as visual-only outside the screen.
- [x] Compile the standalone library. No full app build or production tests are needed for static preview content.

## Task 2 — Render, review and handoff

**Files:** `Sources/RenderPreviews/main.swift`, package `README.md`, `docs/design/swiftui-previews/`, documentation indexes and agent log.

- [x] Build/run only the isolated render utility; export Today/Journal/Practice and a contact sheet at known dimensions.
- [x] Visually inspect renders against Figma, fix layout issues and inspect a compact render. Do not claim iOS/device behavior from the macOS renderer.
- [x] Open the package in Xcode, verify its visible state where available, and explain how to use Canvas previews. If Canvas cannot run, preserve the compiled gallery and report the exact limitation.
- [x] Verify manifest/resources, image dimensions, docs links and `git diff --check`; record outcomes. No mirrored implementation unit tests for this low-impact static UI task.

## Outcome — 23 October 2026

Standalone package build and five PNG exports passed. Standard 390 × 844 and compact-width 320 × 844 boards were visually inspected. The first ImageRenderer output omitted ScrollView content; direct static layout fixed this and the images were regenerated. Xcode package opening was attempted, but repeated native UI timeouts prevented confirming Canvas. Instructions and the compiled renders are available; no full app or Simulator run occurred. See the [work record](../../agent-collaboration-log/2026-10-23-200300-codex-swiftui-previews.md).
