# Say why Apple Intelligence isn't used

- Recorded: 2026-11-05 23:30:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (desktop app, Katherine's Mac), implementation
- Status: completed
- Base revision and branch: `codex/ai-fallback-reason` from `origin/main` at `2b2cf7a` (Katherine's fork)
- Related record: item 2 of [next steps](../portfolio/next-steps-ai-fallback.md); [item 1 entry](2026-11-05-224500-claude-ai-input-check.md)

## Request and scope

Katherine asked for item 2 of the AI next steps, tested in her Xcode before committing, in her name. Files: `Circleu/Services/GuestJournal/GuestSuggestionEngine.swift`, `Circleu/Features/GuestJournal/GuestReflectionReview.swift`, `Circleu/Features/GuestJournal/GuestPracticeScreens.swift`, `CircleuTests/GuestFallbackReasonTests.swift` (new), `docs/product/user-stories.md` (T6.8, P4.4).

## Work and outcome

- New `GuestFallbackReason`: this iPhone can't run Apple Intelligence; it's off in Settings; it's still getting ready; iOS older than 26; unavailable for another reason; asked but didn't answer. Each has one line of at most 60 characters, adapted from `AppleIntelligenceReflectionEngine.availabilityMessage`.
- `LocalFirstSuggestionEngine` reads the model status once per request, keeps the reason on guided reflections and wording suggestions, and still returns the guided result. The status check is injectable (`modelUnavailableReason`) so tests can pretend each state.
- The reflection review and both Practice suggestion areas show the reason under the existing source label, with an info icon. The stored `GuestSuggestionSource` values and saved reflections are unchanged.
- The guided-only UI-test mode shows no reason, so existing UI tests see the same screens.

## Verification

- `xcodebuild test` (scheme Circleu, iPhone 17 Pro Simulator, separate derived data, `CODE_SIGNING_ALLOWED=NO`) for `GuestFallbackReasonTests`, `GuestSuggestionViewModelTests`, `GuestConversationTests`, `GuestCopyLintTests` and `GuestReflectionInputCheckTests`: 30 passed, 0 failed.
- Katherine's Xcode, unit suite (scheme Circleu, ⌘U, iPhone 17 Pro Simulator, iOS 26.5): 300 tests, 299 passed, 0 failed, 1 skipped (`testRealDataProtectionOnDevice`, physical device only).
- Katherine's Xcode, `CircleuUITests`: 30 tests, 26 passed, 3 failed, 1 skipped. The same three failures as before this change and on unchanged `main` (dictation on Simulators; two calendar tests and the Simulator's Chinese language setting); see the [item 1 entry](2026-11-05-224500-claude-ai-input-check.md).
- Not run / limitations: the real Apple Intelligence states (device not eligible, turned off, model preparing) can only be seen on physical iPhones; the tests pretend them.

## Discussion and decisions

None.

## Handoff

- Remaining work: check on a physical iPhone with Apple Intelligence on and off; make the two calendar UI tests independent of the Simulator's language.
- Owner: Katherine
- Risks / unresolved questions: none known.
