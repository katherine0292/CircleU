# Audit close-out: Firestore ownership rules and the retired cloud path

- Recorded: 2026-11-04 18:30 +11:00; Australia/Sydney.
- Agent / role: Claude Code, implementer.
- Status: on `codex/audit-rules-and-cloud`; suite and Codex results in the PR.
- Related: [31 October audit](../qa/project-audit-2026-10-31/README.md) A02, A03, A11 and its 4 November follow-up.

## Request and scope

Owner accepted the recommendation to fix the rules in the repo without deploying, and to remove the Gemini path. No deployment, no new provider, no change to guest behaviour.

## Work

- `firestore.rules`: circle updates by non-creators limited to the caller's own membership/like/favorite entry (`diff().affectedKeys().hasOnly(...)` plus an "only my uid added or removed" check per array); post updates by non-authors limited to the caller's own like and one appended reply with `authorUserID == request.auth.uid`; creator/author cannot reassign ownership; `$(circleID)` interpolation fixed in the member lookup.
- `firestore-tests/rules.test.mjs`: seven emulator cases (own membership and like, blocked cross-user removals, blocked metadata and cover edits, creator rights without reassignment, own like and reply on a post, blocked forged or dropped replies, member-only post creation as oneself). Not run: the Firebase CLI is absent on this Mac.
- Removed `Circleu/Services/CloudReflectionEngine.swift` and `CircleuTests/CloudReflectionEngineTests.swift`; `ReflectionEngineFactory.makeDefault()` returns Apple Intelligence with a local fallback, or the local engine. No UI referenced the cloud setting.

## Verification

Test build succeeds. `ReflectionResponseDecoderTests`, `GuestSuggestionTests` and `AppStartupTests` pass (10). Full suites and the Codex pass are recorded in the PR. The rules were not compiled or run against the emulator here; the Firebase CLI needs installing first (`npm install -g firebase-tools`).
