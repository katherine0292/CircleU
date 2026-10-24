# Circleu Documentation

This folder holds the current project knowledge the team should follow while building, testing, and presenting Circleu.

## Contributor and agent entry points

- [Project coding standards](0_coding_standards.md): Swift/iOS adaptations of the shared master standard, verification and data-preservation rules.
- [Agent instructions](../AGENTS.md): concise starting context; `CLAUDE.md` imports the same source.
- [Agent collaboration log](agent-collaboration-log/README.md): dated work records, review discussions, decisions and handoffs; includes a labelled retrospective of the planning so far.

## Start Here

1. [Product overview](product/overview.md)
2. [Product website](index.html)
3. [App flow](product/app-flow.md)
4. [Demo transcript](product/demo-transcript.md)
5. [TestFlight description](product/testflight-description.md)
6. [App snapshots](product/snapshots/README.md)
7. [Project structure](engineering/project-structure.md)
8. [Architecture](engineering/architecture.md)
9. [Domain models](engineering/domain-models.md)
10. [Backend boundaries](engineering/backend-boundaries.md)
11. [Backend roadmap](engineering/backend-roadmap.md)
12. [Firebase backend plan](engineering/firebase-backend-plan.md)
13. [CloudKit data model](engineering/cloudkit-data-model.md)
14. [Phone test checklist](qa/phone-test-checklist.md)
15. [TestFlight Firebase checklist](qa/testflight-firebase-checklist.md)
16. [Git workflow](process/git-workflow.md)
17. [Team standards](process/team-standards.md)

## Project Reviews

- [Flow and delivery checklist](product/flow-status-checklist.md): all MVP journeys, prepared artifacts, pending prototype work and separate production/device/release gates.
- [Next prototype-review milestone](superpowers/plans/2026-10-24-prototype-review-milestone.md): proposed reflection/practice/retrieval review tasks, reuse boundaries and scoped subagent roles.
- [Core-journey review brief](design/prototype-review-brief.md): missing branded route specimens, calendar interaction proposals and five neutral walkthrough tasks.
- [Branded core journeys](design/brand-demo/core-journeys.md): capture/reflection/detail, direct Practice and changed-source context specimens.
- [Lighter copy and rounded icons](design/brand-demo/lighter-icon-journeys.md): latest owner-requested refinement with compact tags and icon-supported actions.
- [Pingu and illustrated asset library](design/brand-demo/asset-library.md): reusable transparent artwork, pose/icon uses and generation provenance.
- [Pingu activity collection](design/brand-demo/pingu-activities.md): five additional action poses, stored originals and static catalog.
- [Full 21-avatar Pingu collection](design/brand-demo/pingu-collection.md): twelve further activities inspired by the owner's reference sheet, with all originals and provenance.
- [Motion guideline](design/motion-guideline.md): proposed production rules, existing-source findings and Reduce Motion alternatives.
- [Isolated native motion demo](design/brand-demo/motion-demo.md): owner-approved greeting/transitions/feedback comparison, compact/desktop instructions, native Mac interaction evidence and separate iPhone Simulator launch captures; iOS touch/keyboard checks pending, main app unchanged.
- [Prototype walkthrough worksheet](design/prototype-review-results.md): prepared tasks and pending calendar decisions; no participant results yet.
- [MVP reuse and dependency map](engineering/mvp-reuse-map.md): existing code to retain/adapt and the safe order toward a manual local vertical slice.

- [23 October 2026 project inventory and improvement review](project-review-2026-10-23.md): source-backed feature/design inventory, documentation gaps, and proposed priorities. This is a dated review, not an approved implementation plan.
- [Discovery brief](product/discovery-brief.md): selected audience A, circles deferred, and the research-first direction.
- [MVP definition and user flow](product/mvp-definition.md): proposed features, acceptance criteria, navigation and failure states; detailed scope awaits review.
- [Privacy, storage and recovery plan](product/privacy-storage-plan.md): approved guest/local direction, backup/export limits, retention/deletion rules and recovery acceptance criteria. Not yet implemented.
- [Supported devices](product/supported-devices.md): proposed iPhone/iOS scope, optional AI and physical-device validation matrix.
- [Local-first transition plan](superpowers/plans/2026-10-23-local-first-transition.md): staged legacy TestFlight recovery, Firebase isolation, migration and retirement gates.
- [Legacy release and Firebase inventory](engineering/legacy-data-inventory.md): live Dev/Prod findings, current build mapping and unresolved TestFlight evidence.
- [Legacy data-format catalog](engineering/legacy-data-format.md): current/historical JSON and Firestore shapes, ownership ambiguity, attachments and decoding risks.
- [Personal Apple account release plan](product/personal-account-release-plan.md): transfer eligibility, recommended UTS recovery bridge and explicit import into a personal app; route not yet selected.
- [Previous-data recovery prototype](design/legacy-recovery-flow.md): device migration, previous-account recovery, import/export and separate cloud-deletion scenarios.
- [Figma prototype and design reference](design/README.md): Draft 02 with approved Today/Journal/Practice structure, shorter routes, entry details and known prototype limitations.
- [SwiftUI visual previews](design/swiftui-previews/README.md): static Today/Journal/Practice comparison and Xcode package, using sample data; no app runtime or Firebase access.
- [Branding guideline — demo draft](design/branding-guideline.md): modern Pingu-inspired logo/avatar/icons, font shortlist and open visual choices.
- [Brand demo 01](design/brand-demo/README.md): coordinated artwork, actual Plus Jakarta Sans specimens and a static Today application.
- [Brand demo 02](design/brand-demo/flow-previews.md): accepted branding across Today, Journal, Practice and both editing previews.
- [Journal calendar — brand demo 03](design/brand-demo/journal-calendar.md): Pingu-styled monthly browsing with saved-day and empty-day specimens.
- [Research findings and validation plan](product/research-findings.md): primary-source desk research, repository implications, interview questions and prototype tasks. No user study has been conducted yet.
- [Discovery and planning plan](superpowers/plans/2026-10-23-project-discovery.md): verified Xcode/Git baseline and the steps toward an agreed product and design scope.

## Folder Map

- `product/`: what the app is, who it serves, and how the user flow works.
- `engineering/`: architecture, source ownership, domain language, backend boundaries, and technical decisions.
- `qa/`: repeatable manual checks for simulator and real-phone testing.
- `process/`: Git workflow, commit standards, branch rules, and collaboration norms.
- `archive/`: historical plans and specs. Archived files are reference material, not current instructions.

## Documentation Standard

Keep active docs short, current, and action-oriented. A current doc should answer what the team should do now; historical implementation notes belong in `archive/`.

When behavior, architecture, or process changes, update the matching active doc in the same commit. If a doc is important for new contributors, link it from this index and from the root `README.md`.
