# Claude → Codex: review the 25 October merges

- Recorded: 2026-10-25 15:29:00 +1100; Australia/Sydney.
- Agent / role: Claude, outgoing implementer; Codex requested as reviewer by the owner.
- Status: review handoff requested by owner; Codex receipt/acceptance not confirmed.
- Base revision / branch: main `c30deed` (all work below is merged). This entry lands through its own small PR.
- Successor: Codex, as requested by owner. No agent has been spawned or messaged by this record.
- Related: [Codex → Claude onboarding handoff](2026-10-25-014452-codex-to-claude-onboarding-handoff.md), [onboarding review](../qa/native-onboarding-final-review-2026-10-25.md), [flow checklist](../product/flow-status-checklist.md).

## Request and boundaries

The owner asked for Codex to review Claude's work from 25 October. This is a review request: record findings and proposed fixes in your own dated log entry. Don't change merged history; propose fixes as new PRs only with owner approval. Product boundaries are unchanged: guest-first local use, Today / Journal / Practice, circles/rewards deferred, no new providers, no production feature work until the owner approves a first-slice plan.

## What merged

| PR | Merge | Scope |
| --- | --- | --- |
| [#1](https://github.com/tuannm3812/CircleU/pull/1) | `81ed9af` | Planning milestone fast-forward from `codex/journal-calendar-planning` (38 commits: standards, MVP docs, isolated prototype, CircleUPreviewHost). Merged while CI was failing for a reason that predated it |
| [#3](https://github.com/tuannm3812/CircleU/pull/3) | `6c7a6d9` | CI repair, plus a production guard: `CircleStore` creates `FirebaseCircleService` only when Firebase is configured. Two test expectation updates |
| [#2](https://github.com/tuannm3812/CircleU/pull/2) | `dd100c5` | Onboarding/recovery preview copy trim, full-width Welcome Log in, quiet-link hit areas, host fixture launch arguments, accessibility audit records |
| [#4](https://github.com/tuannm3812/CircleU/pull/4) | `c30deed` | Today/Journal/Practice preview board copy trim, review labels moved to captions, tab-name hub headings, host `--board` argument, Today walkthrough script |

## Review priorities

1. **Production guard (only app-code change):** [CircleStore.swift](../../Circleu/Stores/CircleStore.swift). `firebase` is now `FirebaseCircleService?`, built only when `FirebaseRuntime.canUseLiveFirebase`; every call site uses `firebase?.`. Check:
   - Whether any circle flow assumed remote persistence and now silently stays local when unconfigured.
   - Whether a store created before `FirebaseRuntime.configureIfAvailable()` could end up nil although Firebase configures later. The app configures in `CircleuApp.init` before `ContentView` creates the store.
   - Whether other `Firestore.firestore()` / `Auth.auth()` paths need the same guard. They looked gated by `FirebaseRuntime` factories, but this was not exhaustively traced.
2. **CI workflow:** [ci.yml](../../.github/workflows/ci.yml) runs on `macos-26`, selects the newest `/Applications/Xcode_*.app`, generates `Config/Signing.xcconfig` from the example with placeholder `com.circleu.ci`, picks an available iPhone simulator via a Python snippet and builds with `CODE_SIGNING_ALLOWED=NO`. Check robustness (no Xcode match, runtime naming changes) and that nothing secret or real is introduced.
3. **Test changes and owner decisions:**
   - `AnalyticsTrackerTests` expects 23 characters ("Short QA Export Content" is 23).
   - `BackendSessionStoreTests` expects a blank `displayName` after account deletion. The owner chose blank over "Friend", and app code is unchanged.
   - Confirm both are expectation fixes, not masking app bugs.
4. **Prototype/copy work** (`Prototypes/CircleUVisualPrototype`):
   - The copy table in [account-onboarding.md](../design/account-onboarding.md#concise-copy-pass--25-october) and the [Today applied changes](../design/today-walkthrough-script-2026-10-25.md#applied-on-codextoday-copy-trim).
   - `quietButton` hit-area fix and `primaryButton(filled:)`.
   - Host `ContentView` launch arguments (`--screen`, `--recovery-screen`, `--scenario`, `--board`). Check that the normal launch still starts at Log in.
   - Check the copy against the [content standard](../design/content.md), especially truthful data/privacy wording on the shorter Privacy cards.

## Owner decisions recorded on 25 October

- Physical New password checks: "All three work" (recorded by Codex in `7d8f428`). The restored Log in entry was confirmed by the owner's phone screenshot.
- Merge to main approved; CI fix approved to merge once green.
- Export test 23; blank name after account deletion.
- Logo text stays fixed-size: an accepted audit exception.
- "Used Google?" stays off Log in; Account help appears only after a failed login; Google/Apple sign-in deferred.
- Review labels move out of phone screens into captions; Journal/Practice hubs use the tab names.
- Welcome Log in is a full-width white secondary button, the same size as Get started.
- PR #2 and PR #4 approved after the owner's phone check ("looks good, merge").

## Evidence: Simulator versus phone

- **Simulator** (iPhone 18 Pro / iOS 27.0, CircleU Preview host): an out-of-repo XCUITest runner covered every onboarding/recovery route and error scenario. `performAccessibilityAudit()` ran on 26 states at default and largest text (only the logo finding remained) and on 9 Today boards (only the expected Dynamic Type findings on fixed-size specimens). Screenshots of the trimmed screens are in the PR descriptions and renders.
- **Full app:** `xcodebuild test` of `Circleu` with the CI config locally passed 95 tests (Xcode 27.1, iPhone 17 / iOS 26.5); GitHub CI passed on PRs #2–#4 and on main after #3.
- **Phone** (iPhone 11 Pro Max / iOS 26.6.1): owner-reported only. New password checks, the restored Log in screenshot and the final "looks good" on the trimmed onboarding. No agent-observed phone screen.

## Open items

- A full manual VoiceOver pass is deferred until before release (owner agreement). Rotation/compact height, intermediate sizes and hardware keyboard are also still open.
- The logo Dynamic Type exception is accepted.
- The Today walkthrough has not run.

## Next owner step

The 15-minute Today walkthrough using the [script](../design/today-walkthrough-script-2026-10-25.md). Afterwards: a first-slice implementation plan (typed capture → local save → Journal → edit) for owner approval. No production feature work before that.

## Discussion and verification of this handoff

Actual inter-agent exchanges: **None.** Writing this record does not deliver it to Codex. Links and `git diff --check` were checked when it was written; no new build or test was run for this entry.
