# Onboarding larger text, scrolling and recovery review

- Recorded: 2026-10-24 20:31:13 +1100; Australia/Sydney.
- Agent / role: Codex coordinator.
- Status: review completed for the requested phone/text fixtures; native recovery implementation remains pending.
- Base / branch: `a627ee4dab75361c947a9761d8dbcbf26265148b`, `codex/journal-calendar-planning`; starting tree clean.
- Related: [previous Welcome pass](2026-10-24-201046-codex-concise-guest-welcome.md), [current QA evidence/findings](../qa/native-onboarding-interaction-review-2026-10-24.md).

## Work and evidence

Owner asked to finish larger-text/scroll checks and review login recovery before Today. Inspected Welcome at accessibility1 on the existing iPhone 18 Pro/iOS 27.0 Simulator. Get started and Privacy buttons navigated; Privacy overflowed vertically as expected. Fresh native drag failed with noWindowsAvailable. Owner manually reported smooth Privacy scrolling, complete text, reachable Done and return to Opening.

Added only `--largest-text` to the isolated Simulator host, selecting accessibility5 without modifying system preferences. Host compiler/script build passed; installed/launched the fixture on the same device. Agent inspected wrapped Welcome with both controls visible and checked Log in/Back. Owner then reported successful scrolling and reachable bottom actions on Earlier data and Privacy at maximum text. These are manual reports, not automated gesture passes. A later agent snapshot remained Earlier data and did not independently capture those reported endpoints. Saved/inspected a native maximum-text Welcome capture and restored the normal-text host.

Read-only browser walkthrough confirmed Figma's account-method/check/review/conflict/explicit-import/completion/matching-message states, login failure/help, lookup failure and no-backup scenarios. Recorded native form/reset/help/provider and duplicate-chooser gaps in QA. No canvas edits, real credentials, backend calls, production/data changes, new artwork or Today work. Closed the temporary review tab; original design tab preserved.

## Verification and handoff

- Isolated host build/launch and screenshot inspection passed. Documentation links, PNG size and diff whitespace checked before commit. No new visual-implementation tests for the small fixture flag.
- Not run: full production tests/CI, actual authentication/import/deletion, every recovery branch, short-height/landscape, VoiceOver or physical hardware. No all-onboarding completion claim.
- Next: native login/reset/recovery form prototype with explicit validation/Back and the documented source/ownership safeguards; then decide readiness for Today. Owner: Unassigned.

## Discussion

None: no inter-agent exchanges. Owner provided the two manual gesture results. Published earlier logs remain unchanged; this entry supplies the new evidence and its limits.
