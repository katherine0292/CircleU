# Core-Journey Prototype Review Implementation Plan

> **For agentic workers:** Use `superpowers:executing-plans` for approved static-preview tasks. Use narrowly scoped subagents for independent review, not simultaneous edits to shared preview helpers. Steps use checkbox syntax. This is a proposed plan; implementation has not started.

**Goal:** Make one reflection journey, one practice journey and Journal retrieval ready for an evidence-based owner walkthrough.

**Architecture:** Extend the existing isolated SwiftUI preview library with immutable fixtures and reuse its brand helpers. Reuse documented Figma scenarios for navigation/recovery review, and record which observations are impossible in a static specimen. Keep all app, persistence, Firebase and release work outside this milestone.

**Tech Stack:** Existing SwiftUI/SwiftPM package, macOS ImageRenderer, repository Markdown and the existing Draft 02 flow reference. No new dependency or global tool configuration.

**Spec:** [Prototype review brief](../../design/prototype-review-brief.md), supplementing the [MVP definition](../../product/mvp-definition.md). Owner requested planning; execution and the proposed interaction rules need review before implementation.

**Following engineering work:** [Reuse/dependency map](../../engineering/mvp-reuse-map.md). Reuse existing code deliberately; guest runtime/storage contracts precede production screen integration.

## Global constraints

- Three destinations: Today / Journal / Practice. Circles and rewards deferred.
- Preserve original app assets, user data, Git history and the existing preview comparison boards.
- Static fixtures only; no app-store imports, auth, network, persistence or working clipboard claims.
- Keep accepted Pingu/Plus Jakarta Sans/palette and the icon-free calendar header.
- Every added screen has a visible sample/static label. Use 390 × 844 point individual specimens, rendered at 2× with explicit proposed size.
- No live Figma call is required to execute these visual tasks: use the documented node map and copy. Do not claim current Figma equivalence when a frame has not been inspected.
- No participant contact, backend access, app launch, deployment or release. Keep the owner's full-app check deferral in force.

## Review focus

1. Words-only save may be hidden by generated feedback: Task 1 must show it and Task 4 must observe whether it is found.
2. Standalone practice can accidentally appear linked: Task 2 labels context/source and observes Copy versus Save separately.
3. Empty day and failed read can look identical: Task 3 reviews that distinction and all-entry/search escape routes.
4. Save failure or source change can lose edits or lend authority to stale suggestions: Tasks 1–2 reuse explicit preserved-edit/stale states in the walkthrough.
5. Static screenshots can be mistaken for tested behavior: Task 4 marks unavailable operations and prohibits claiming unaided completion from moderator-controlled transitions.

## File map and ownership

| File | Responsibility / integration owner |
| --- | --- |
| New `Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/BrandJourneyPreview.swift` | Six immutable route specimens; one implementation owner |
| Existing `BrandDemo.swift`, `BrandFlowPreview.swift`, `EditorPreview.swift` in that source folder | Reuse actual font/color/artwork helpers and editor semantics; coordinator owns any shared-helper edits |
| Existing `JournalCalendarPreview.swift` | Add a multiple-entry fixture only after calendar behavior review; preserve current saved/empty specimens |
| Existing `Prototypes/CircleUVisualPrototype/Sources/RenderPreviews/main.swift` | Coordinator adds exact named exports and explicit individual sizes |
| Existing `docs/design/swiftui-previews/README.md` and package `README.md` | Evidence, output inventory and reproducible instructions |
| New `docs/design/prototype-review-results.md` | Empty observation table initially, then actual owner walkthrough results |
| Existing design brief and `docs/product/mvp-definition.md` | Resolve decisions without creating a competing feature register |

## Task 1 — Branded reflection route

**Produces:** public enum `BrandJourneyScreen: String, CaseIterable, Identifiable, Sendable` initially containing `capture`, `reflection`, `entry`; public view `BrandJourneyPreview(screen: BrandJourneyScreen)`. Task 2 extends the enum/view with the practice cases so each task compiles independently. Keep sample values inside the preview file.

- [ ] Reuse the invented group-deadline scenario and map Capture `11:101`, Reflection `11:102`, Entry `11:103` to the new specimens. Record copy changes as proposals.
- [ ] Show original words, editable interpretation affordance, Save reflection, words-only save and optional practice handoff in their proper screens. Entry contains the saved content and inline optional next step; no extra save-success destination.
- [ ] Add named Canvas previews and renderer files `brand-04-capture.png`, `brand-04-reflection.png`, `brand-04-entry.png` at the fixed size. Reuse the existing reflection editor for edit review.
- [ ] Build/render and visually inspect the individual outputs, including long paragraph wrapping and words-only action visibility. Static-only work uses compilation/visual checks; no mirrored unit tests.
- [ ] Commit the scoped source, exports, guide changes and a dated work record: `feat(prototype): complete branded reflection route`.

## Task 2 — Branded direct and linked practice review

**Consumes:** Task 1's enum/view and existing message editor. **Produces:** additional enum cases `practiceContext`, `wording`, `practiceDetail` and their specimens in the same preview file; retain one editing owner.

- [ ] Reuse New context `11:108`, Wording `11:110`, Practice detail `11:112`. Show intended outcome and one editable wording option; keep saving independent of copying.
- [ ] Add an explicit source-context variant for the linked route using `11:109`, `11:111`, `11:114` as documented references. Original/corrected context must be visibly distinct; do not import unrelated entries.
- [ ] Add named previews and exports `brand-04-practice-context.png`, `brand-04-wording.png`, `brand-04-practice-detail.png`. Reuse the branded message editor; do not duplicate it into another component system.
- [ ] Select existing Figma stale-source, keep/discard/continue and save-failure snapshots for the review guide, including preserved edits. These are representative review links, not newly working recovery functions.
- [ ] Build/render and inspect result/source labels and all Save/Copy/Discard affordances; record limits and commit `feat(prototype): complete branded practice route`.

## Task 3 — Resolve Journal date/search decisions

**Consumes:** existing `JournalCalendarPreview`, the brief's six calendar proposals and the list-only Journal comparison. **Produces:** documented accepted/deferred behavior plus one multiple-entry snapshot if approved.

- [ ] Review default date, entry-dot/count semantics, month-arrow selection, Today, All entries, global Search/return, future/empty dates and creation-for-today behavior with the owner. Record the outcome in the brief/MVP definition without claiming approval by implication.
- [ ] If accepted, add a multiple-entry fixture for 21 October 2026 with two invented entries; selected-date count must be 2 and the dot remains one. Preserve 24 October as the sample Today and keep existing exports stable.
- [ ] Keep failed-read review separate from empty-day review using Figma `36:437` and `36:411`; do not add an application-facing failure-simulation button.
- [ ] If visual source changes, build/render and inspect both original and new calendar specimens. Check date arithmetic independently. No runtime time-zone filtering or production hit-target claim.
- [ ] Commit accepted review/fixture changes with a precise scoped message, or record deferred decisions if no source change is authorized.

## Task 4 — Walkthrough and scope decision

**Files:** new `docs/design/prototype-review-results.md`, brief, affected design index and unique agent record.

- [ ] Create the brief's empty observation table. Mark all tasks “not run”; do not invent participant results.
- [ ] Conduct the five owner walkthrough tasks when the owner is available. Use Figma for represented navigation, static specimens for appearance, and explicitly mark operations that cannot be tested. Do not count preset state changes as real typing/save/restore evidence.
- [ ] Record findings, counterevidence and concrete changes. Address critical privacy/data-loss misunderstandings before calling the milestone ready. Do not equate favorable aesthetic feedback with validated usefulness or beta readiness.
- [ ] Decide whether an interactive prototype extension is required, or whether existing flow evidence is sufficient to define the first implementation slice. Scope the extension separately rather than silently building a second app.
- [ ] Record manual typed capture → versioned local save → Journal/detail → edit/reopen as the proposed first production slice, subject to feasibility/implementation approval. Reference the existing transition plan for legacy preservation, guest-runtime isolation and later release gates.
- [ ] Verify links, evidence labels and `git diff --check`; commit `docs(research): record prototype walkthrough findings` only after actual findings exist. An empty worksheet can be committed with a setup-oriented subject.

## Verification commands for an approved preview execution

From `Prototypes/CircleUVisualPrototype/`:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift build \
  --scratch-path /tmp/circleu-visual-preview-build --product render-previews
/tmp/circleu-visual-preview-build/debug/render-previews ../../docs/design/swiftui-previews
git diff --check
```

Expected: build and renderer exit 0, bundled font-family assertion passes, each individual export is 780 × 1688 pixels, no clipped/missing text/actions in individual or comparison images, and staged files contain only intended source/resources/docs. Canvas, Simulator and hardware evidence must be reported separately.

## Agent execution recommendation and handoff

Use one implementer for the shared preview source, font/color helpers and renderer. Product-flow and engineering/data reviewers may inspect independently and return findings without edits. Coordinator verifies findings, resolves conflicts and records real exchanges in a unique log. No reviewer may approve scope or publish on the owner's behalf.

This milestone is small and shares interfaces heavily: native execution with focused subagent reviews is preferable to a fresh implementer per screen. Keep production storage/legacy recovery implementation sequential behind its contracts. After the owner reviews this plan/brief, execute only the agreed preview tasks. The existing authorization to commit/push documentation does not authorize merging or releasing.
