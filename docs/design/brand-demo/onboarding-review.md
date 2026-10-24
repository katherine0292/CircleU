# Onboarding review — 24 October 2026

Status: local interactive design proposal, now extended with earlier-data choices, simulated storage gates and re-entry rules. The [focused onboarding review](../../qa/onboarding-flow-review-2026-10-24.md) records the new checks and remaining gates. Figma access was rechecked and still returned its Starter-plan MCP call limit; no canvas edits were made. This is not implemented onboarding, verified storage behavior or production approval.

## What to review now

Latest owner feedback selects the [original native composition](../original-layout-reuse.md) as the layout baseline. Carry the reviewed concise copy/artwork/palette into that structure in the next proposed specimen; the local HTML and earlier fixed-size boards remain comparison material. No native reskin has been applied yet.

The [24 October research follow-up](../onboarding-patterns-research-2026-10-24.md) supersedes the local copy below where noted: v3 uses **Find your words**, shorter privacy/earlier-data text, no repeated Today helper and finite Pingu greeting/navigation motion with a still alternative. The tables below retain the v2 review baseline; Figma/SwiftUI adoption is still pending.

Review the clickable first-use proposal in the conversation first. Check whether the purpose is clear, Get started reaches an empty Today only when the simulated storage result is Ready, Privacy returns to the originating screen, and earlier-data recovery can be reviewed or postponed. Screen selectors, Restart review, Reopen preview and Storage outcome are review controls outside the depicted app; they do not reset app data or test real storage.

- **Figma:** connected journeys, branches, editing/recovery and proposed screen structure. The existing [Draft 02](https://www.figma.com/design/RVLtfmIVcO8gNk5fam0Vjd?node-id=11-81) remains a wireframe.
- **PNGs:** visual composition, artwork, font, spacing and hierarchy. They do not establish interaction behavior.
- **Xcode/native prototype:** actual SwiftUI input, focus, motion, layout and accessibility behavior. Existing native Mac checks and Simulator launch frames are different evidence; see the [motion record](motion-demo.md).

## Current findings

- Draft 02 has two pages and remains in Inter with draft variables/styles. Plus Jakarta Sans is now available through the Figma font listing, but has not been applied there. The accepted illustrated branding lives in the standalone SwiftUI previews.
- The existing onboarding entry is [Privacy introduction `36:406`](https://www.figma.com/design/RVLtfmIVcO8gNk5fam0Vjd?node-id=36-406); its content primarily explains the planned data policy. It is not a concise introduction to the conversation/reflection purpose.
- The inspection found 95 exact standard “DRAFT 02 · Sample content and simulated actions” text labels, plus other planning notes. This count is not a count of all review-only text or screens; the broad frame predicate also matched guide frames. Do not replace the earlier 125-state inventory with that predicate's 132 matches.
- The production onboarding remains different: [Onboarding.swift](../../../Circleu/Features/Onboarding/Onboarding.swift) presents signup/signin and Skip; its [ViewModel](../../../Circleu/Features/Onboarding/OnboardingViewModel.swift) invokes backend-aware account operations. Neither Figma nor the new mockup changes that behavior.

## Proposed first use

One short welcome leads directly to an empty Today. Privacy is available before and after starting, rather than being another mandatory slide. No signup, name collection, notification prompt or microphone request is added to this proposal. Earlier data remains a separate explicit recovery route.

### Welcome

| Element | Copy / behavior |
| --- | --- |
| Brand | Existing CircleU logo and actual Plus Jakarta Sans |
| Illustration | Existing `Expansion01/PinguWelcomeV1.png`, still |
| Title | Find words that feel like you. |
| Purpose | Reflect on a difficult moment, or practise what to say. |
| Storage summary | **Saved on this device.** No CircleU sync. Deleting the app can lose your entries. |
| Privacy & data | Opens optional details; Back/Done returns to Welcome |
| Get started | Checks workspace readiness before Today; no fabricated saved history or resume card |
| Used CircleU before? | Opens a local explanation/choice before the existing recovery handoff `65:663`; offer Continue without importing; never clear or automatically import legacy data |

The storage copy depicts the approved guest-local direction, not current code. A real release must not use it until the transition/privacy plan's runtime and recovery requirements pass. Keep that implementation disclaimer outside the depicted phone during design review.

### Optional privacy details

- **On this device:** Your entries stay in this app. No signup, CircleU cloud AI or automatic sync. On-device suggestions are optional and depend on availability.
- **Recovery has limits:** Device backups may include app data. Recovery after losing your phone or deleting the app is not guaranteed.
- **You’re in control:** Export what you want to keep. Deleting an entry won’t remove copies you exported or data in existing device backups.
- **Voice is optional:** Start by typing. Voice permissions are requested only when you choose to record.
- Keep Manage earlier CircleU data. Back and Done return to the originating screen, including Today.

### First Today

“What’s on your mind?” with “Make sense of a moment. Choose what comes next.” Show Work through a moment, Practice a message and Today / Journal / Practice navigation. Existing Pingu-with-journal artwork is reused. No fake first-run entries, rewards, circles or resume-draft card.

The local proposal links onward to known Draft 02 nodes: Capture `11:101`, direct Practice context `11:108`, Journal `11:104`, Practice `11:107` and legacy recovery `65:663`. These are handoffs to existing wireframes, not newly branded or reverified branches. In particular, the existing Journal handoff has fictional history; an actual first-use Journal must be empty. The local proposal is not a second persistence implementation. Other screens were not refined during the focused onboarding pass.

## Earlier-data choice and safe opening

Used CircleU before? and Manage earlier CircleU data open the same local choice. Explain that nothing is imported automatically, earlier data is preserved, and old-account recovery may require internet/sign-in. Review earlier data hands off explicitly to the existing recovery wireframe; Continue without importing opens the separate workspace only after readiness succeeds. Back returns to the actual origin, including nested Privacy → Earlier data → Back → Privacy → Done → Welcome/Today/error.

The local proposal also includes Opening your space, Storage locked and Could not open storage. Their outcomes are chosen using the external review control; no disk read or asynchronous work is performed. Pending opening can be canceled; retry remains blocked when the chosen failure remains. A failed read never opens empty Today. Back to welcome always goes to Welcome, including after a previously completed introduction. Readiness must pass again before entering Today.

Reopen preview demonstrates the proposed routing contract: incomplete first use returns to Welcome; completed first use rechecks storage before Today. This is review-state simulation, not actual process-death/relaunch or saved-data recovery. Production must persist completion only after workspace readiness and required metadata writes succeed, and return existing data/drafts rather than initialize an empty store. Those implementation checks remain pending.

## UI copy cleanup rule

Remove Sample, Brand demo, Draft 02, preset-state instructions and simulated-action footers from depicted product screens. Keep node names, page notes and a reviewer-facing limitation outside those screens. Do not hide meaningful validation, missing capability, unsaved changes, save/copy failure, storage or recovery messages. Mockup actions must still be described accurately in the surrounding review context.

This rule is reflected in the new local first-use proposal only. Existing Figma and historical SwiftUI boards retain their labels until the actual cleanup is applied and checked. No claim of completed file-wide cleanup.

## Figma continuation

1. Resume in the existing file when MCP access is available; preserve Draft 01, Draft 02 and their recovery links.
2. Reuse or clone local button/card/tab components; complete the interrupted library/component discovery before creating replacements. No library-unavailability finding was established by the rate-limit response.
3. Reconcile only the needed foundations with the accepted brand values from [BrandDemo.swift](../../../Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/BrandDemo.swift): ink `#0D1421`, blue `#054FC9`, ice `#F5FAFF`, muted `#4F6077`, Plus Jakarta Sans. Do not mutate the draft collection globally without inspecting dependents.
4. Build editable Welcome, Privacy details and empty Today, with instance-based controls and discrete existing artwork. Put prototype/storage limitations on the review canvas outside the phone. Do not import a flattened screenshot as the UI.
5. Connect Get started through the readiness states, nested privacy return and earlier-data choice/recovery handoff. Cover cancel/retry and completed/incomplete re-entry without bypassing storage failures. Carry the accepted styling into the already planned core journeys incrementally; do not silently claim all recovery states have been rebranded.
6. Check fonts, wrapping, bounds, first-run history, reachable controls, actual prototype connections and screenshots before declaring the Figma update done.

## Swift architecture recommendation

The codebase already uses MVVM. [Project structure](../../engineering/project-structure.md) and [architecture](../../engineering/architecture.md) specify View → ViewModel → Store / Engine / Service → Model. `OnboardingViewModel` owns stage/validation/loading and account actions; `JournalViewModel` owns search and coordinates export/deletion. This is source evidence, not proof every existing view follows the boundaries.

Keep that feature-first structure. Use small SwiftUI views, visual-only `@State`, screen-level ViewModels for behavior, and injected stores/engines/services as persistence and integration boundaries. Prefer one source of truth for saved items rather than copying an entry into multiple independently mutable screen models. Apple describes observable models and that source-of-truth relationship in [Managing model data](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app/); MVVM naming itself is our project convention, not an Apple requirement.

Do not add a ViewModel to every static component or perform a blanket `ObservableObject`/`@StateObject` replacement. Evaluate `@Observable` when an authorized feature slice needs it, with actor ownership and meaningful behavior tests. The next production slice remains pending approval and the legacy/local-runtime feasibility work. No Swift refactor was made in this task.

## Evidence and limits

The local proposal uses derivative display renditions of existing transparent assets and the bundled font, leaving originals intact. Local Welcome → Privacy → Back/Done → Welcome and Welcome → Today were exercised in the browser; actual font loading, image loading and Today horizontal fit at approximately 390 points were inspected. These browser checks are not SwiftUI, iPhone, VoiceOver or real storage checks. External Figma handoff branches were not rerun. Owner feedback is still pending.

The focused follow-up checked nested earlier-data returns, deferral, simulated completed/incomplete re-entry, pending cancellation, locked/read-error retry and the failed-read back-route regression. See the [case-by-case evidence](../../qa/onboarding-flow-review-2026-10-24.md). No owner comprehension study, Figma migration or runtime storage implementation was completed.
