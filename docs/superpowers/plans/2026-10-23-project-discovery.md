# CircleU Discovery and Planning Plan

> **For agentic workers:** Use superpowers:executing-plans for an approved execution phase. This plan covers discovery and documentation; product-code changes require their own agreed scope. Steps use checkbox syntax for tracking.

**Goal:** Establish evidence-backed product scope, design references and a reproducible development baseline before feature implementation.

**Architecture:** Preserve the current feature-based SwiftUI structure during discovery. Maintain one feature inventory, one evolving product brief and linked design references. Resolve high-impact product decisions before splitting engineering work into implementation plans.

**Tech Stack:** Existing SwiftUI app, XCTest, Firebase, Xcode, GitHub and Figma for prototype review.

**Spec:** The owner's approval of the [project review](../../project-review-2026-10-23.md) and explicit request to begin with planning/research. Audience options are in the [discovery brief](../../product/discovery-brief.md).

## Constraints

- Start with planning and research; do not treat all existing features as committed release scope.
- Use the owner's Figma account, as explicitly requested. The previously connected account is not approved for this work.
- Preserve existing source, Git history, signing configuration and backend data.
- Keep findings, proposals and user-approved decisions clearly distinguished.
- Do not contact research participants or change remote repository settings without authorization.

## Review focus

- An attractive prototype can describe functionality that is not implemented: trace each feature to source and verification evidence.
- Private-journal language can hide public circle access: validate visibility with stranger/member/owner scenarios in a later engineering plan.
- Backup can restore deleted content: keep deletion/restore behavior explicit in release acceptance criteria.
- One machine's configuration can conceal fresh-checkout failures: validate both local and clean-checkout setup before declaring CI ready.
- A working connector may be signed into the wrong account: verify identity and target-file access before reading prototypes.

## Task 1 — Verify development and ownership baseline

**Evidence:** Local Git configuration, GitHub repository/branch metadata, Xcode command output and simulator inventory.

- [x] Confirm repository owner and active GitHub identity. Both are `tuannm3812`; API reports admin/push access, public visibility and `fork: false`.
- [x] Confirm local origin is `https://github.com/tuannm3812/CircleU.git` and local `main` matches live remote commit `2f28966f446a86a47ca0879d33e961af252a0856`.
- [x] Confirm local Git name/email and HTTPS credential helper are configured. GitHub CLI authentication succeeds outside the sandbox with keychain access.
- [x] Inspect protection state: `main` is unprotected and the ruleset list is empty. This observation does not change repository settings.
- [x] Verify Xcode 27.1 (27A9275), Swift compiler 6.4, iOS SDK 27.1 and a passing first-launch check. The earlier license blocker is no longer present.
- [x] Verify available iOS 26.5 simulator devices, including iPhone 17 Pro. Simulator inventory required access outside the sandbox.
- [x] Confirm local signing and production Firebase configuration files now exist and are ignored by Git. Their presence does not prove service ownership or configuration validity.
- [ ] Set the system's selected developer directory to Xcode if the owner wants plain `xcodebuild` commands to work. It still points to `/Library/Developer/CommandLineTools`; command-specific `DEVELOPER_DIR` works now.
- [ ] Run a simulator build and tests in a dedicated setup-validation task, recording the command, commit, configuration and result. No successful application build/test is claimed here.

Command-specific checks used:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -version
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -checkFirstLaunchStatus
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -showsdks
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun swift --version
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcrun simctl list -j
```

Optional system-wide selection, requiring administrator authorization:

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

Git recommendations for implementation: work on `codex/<topic>` branches, use small commits and pull requests, and require the verified CI check on `main` once reliable. No new repository, transfer, remote rewrite or history rewrite is needed. Two obsolete worktree registrations were identified by dry-run only; cleanup is optional and was not performed.

## Task 2 — Establish the product hypothesis

**Files:** Update `docs/product/discovery-brief.md`; refer to the existing review rather than duplicating its full inventory.

- [x] Record the owner's research-first intent and distinguish it from audience approval.
- [x] Offer three audience/problem statements and explain tradeoffs.
- [x] Research relevant patterns using primary product sources; record source URLs and access date.
- [x] Record the owner's selected audience A and decision to defer circles; continue research/planning before coding.
- [x] Draft the primary journey, provisional MVP features and acceptance criteria in `docs/product/mvp-definition.md`.
- [x] Record approval of guest-first local storage and the previous TestFlight release; see the [transition plan](2026-10-23-local-first-transition.md).
- [ ] Confirm the proposed prototype-validation milestone and remaining detailed beta scope; validate storage/model feasibility and legacy recovery.

Check: every priority has a user problem, a reason and evidence to collect; untested assumptions are labeled.

## Task 3 — Connect the approved design source

**Files:** Add `docs/design/README.md` only after a real design source is available; link from `docs/README.md`.

- [x] Check current Figma identity and detect that it is not the intended account.
- [x] Owner reconnects Figma with the requested account through interactive authorization; verified as `tuannm3812@gmail.com`.
- [x] Verify identity and file access. The owner had no existing file and requested a fresh start; created and edited the new research prototype, linked in `docs/design/README.md`.
- [x] Create a first draft with 12 editable screens, two main routes, recovery states and reusable controls; record incomplete states and the Inter font substitution.
- [ ] Inventory screens, component variants, tokens and prototype paths; identify current versus aspirational behavior.
- [ ] Record approved design references and disagreements with code as explicit decisions or backlog items.

Check: no design guideline claims authority without an approved file/version; include failure and empty states in the screen map.

## Task 4 — Gather user evidence and select release scope

**Files:** Update the discovery brief, `docs/product/research-findings.md` and `docs/product/mvp-definition.md`. Promote the MVP draft to an agreed release scope after validation rather than creating a competing feature register.

- [x] Record primary-source desk research, implications and a proposed interview/prototype study. Explicitly distinguish it from participant evidence.

- [ ] Agree recruitment and conduct a first small batch of discovery conversations. Obtain authorization before any outreach.
- [ ] Summarize anonymized evidence and revise the hypothesis when needed.
- [ ] Test one complete prototype journey; record task completion, misunderstandings and usefulness.
- [ ] Select must-have/later/excluded features and write observable acceptance criteria.
- [ ] Include authorization, deletion/restore, account switching and privacy comprehension in release gates.

Check: feature decisions trace to evidence or a clearly identified owner decision; competitor features alone are not evidence of user demand.

## Task 5 — Prepare implementation plans

**Files:** Reconcile `docs/product/overview.md`, `docs/product/app-flow.md` and relevant engineering docs once scope is approved; add separate implementation plans under this directory.

- [ ] Create a setup/CI plan using fresh build results.
- [ ] Create a data-lifecycle/access-control plan using the selected product privacy model.
- [ ] Create a design-consolidation plan using the approved Figma reference.
- [ ] Create a focused core-journey improvement plan using research results.

Check: each plan has exact files, acceptance tests, dependencies and a clear boundary. This discovery plan does not authorize implementing unspecified product features.
