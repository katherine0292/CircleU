# Project audit and fresh regression verification

- Recorded: 2026-10-31 17:20:46 +11:00; Australia/Sydney
- Agent / role: Codex / project auditor
- Status: completed audit; remediation remains proposed
- Base revision and branch: `9967a1057310c84e569c8ffecc434a3c7db905c9`, `codex/app-upgrade-plan`; substantial pre-existing uncommitted work retained
- Related record: [approved scenes review 21](2026-10-31-165553-codex-approved-scenes-review-21.md), [native Practice evidence](../qa/native-practice-2026-10-27/README.md)

## Request and scope

Owner requested another whole-project audit. Reviewed product/current scope, relevant architecture and guest services, legacy Firebase rules/recovery, AI decoding, build/release configuration, assets, current Figma structure, tests and showcase artifacts. No application implementation, Figma edit, cloud deployment, live-account data access or release was performed.

## Work and outcome

- Added [prioritised audit report](../qa/project-audit-2026-10-31/README.md), scoped Firebase rules JSON and machine-readable verification details; linked the audit from `docs/README.md` while preserving earlier edits.
- High-priority findings: malformed model output can trap both reflection decoders; Circle/post update predicates allow cross-user modifications; standard Release deliberately remains the original Firebase experience. Legacy recovery/build routing is still a release gate.
- Additional findings: duplicate model tones can duplicate SwiftUI IDs; legacy Gemini 1.5 Flash endpoint is retired according to Google's release notes; uncommitted integration, documentation drift, concurrency warnings and non-blocking accessibility audit retention need cleanup.
- Current Figma direct node-navigation targets resolve; six scene instances share dimensions. Latest visual changes are not native parity. No AI-credit spending operation was invoked.
- Recommend preserving/checkpointing current work, a bounded reliability/documentation cleanup, completing stale-reflection prototype behavior, then approved native Today/Journal alignment and showcase refresh. Future circles/cloud activation remain deferred.

## Verification

- Fresh `xcodebuild test`, scheme `Circleu`, Xcode 27.2 / iPhone 18 Pro Simulator iOS 27.0: **266 passed, 1 skipped, 0 failed**, exit 0. Physical data-protection check skipped.
- Fresh full `CircleuUITests` suite, same destination: **22 passed, 1 skipped, 0 failed**, exit 0. Opt-in live Firebase test skipped.
- Result summaries read from `/tmp/circleu-audit-20261031-unit.xcresult` and `/tmp/circleu-audit-20261031-ui.xcresult`. UI text-attachment export matched no `*.txt`; no clean accessibility-audit claim made.
- Asset manifest scan: 86 catalogs, no missing referenced or unassigned image/data files. Project/privacy plists validate. All 103 story test-method names found. Current documentation relative targets resolve; historical logs have 42 missing-target occurrences after normalisation.
- Figma page `74:2`: 7,263 descendants, 1,669 direct node-navigation actions, no missing direct destinations. Conditional branches/player regressions not fully audited.
- JSON, local report links and whitespace validated. Full simulator test results are not physical-device, live model, Firebase emulator/deployment or TestFlight qualification.

## Discussion and decisions

None. No other agent was spawned or messaged. Recommendations are audit outcomes, not approval to implement new features or change release routing.

## Handoff

- Remaining work: choose a bounded remediation batch from the audit; preserve pending native/design work before integration; keep legacy data/recovery intact.
- Owner: Unassigned.
- Risks: deployed rules and old TestFlight Firebase identity remain unverified; guest Release is not configured; live cloud AI is not approved; physical checks remain separate.
- No commit or push. Existing historical logs were not edited.
