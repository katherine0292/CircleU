# Circleu Documentation

This folder holds the current project knowledge the team should follow while building, testing, and presenting Circleu.

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

## Folder Map

- `product/`: what the app is, who it serves, and how the user flow works.
- `engineering/`: architecture, source ownership, domain language, backend boundaries, and technical decisions.
- `qa/`: repeatable manual checks for simulator and real-phone testing.
- `process/`: Git workflow, commit standards, branch rules, and collaboration norms.
- `archive/`: historical plans and specs. Archived files are reference material, not current instructions.

## Documentation Standard

Keep active docs short, current, and action-oriented. A current doc should answer what the team should do now; historical implementation notes belong in `archive/`.

When behavior, architecture, or process changes, update the matching active doc in the same commit. If a doc is important for new contributors, link it from this index and from the root `README.md`.
