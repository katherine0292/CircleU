# Don't ask for a reflection when there are too few words

- Recorded: 2026-11-05 22:45:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (desktop app, Katherine's Mac), implementation
- Status: completed
- Base revision and branch: `codex/ai-input-check` from `origin/main` at `7347fb8` (Katherine's fork)
- Related record: item 1 of [next steps](../portfolio/next-steps-ai-fallback.md); [acceptance cases](../qa/ai-acceptance-cases.md); [previous entry](2026-11-05-221000-claude-ai-acceptance-cases.md)

## Request and scope

Katherine asked for items 1 and 2 of the AI next steps, each tested in her Xcode before committing, all commits in her name. This entry covers item 1. Files: `Circleu/Engines/TranscriptQuality.swift`, `Circleu/Features/GuestJournal/GuestReflectionReview.swift`, `CircleuTests/GuestReflectionInputCheckTests.swift` (new), `CircleuTests/GuestSuggestionTests.swift` (fixtures), `docs/product/user-stories.md` (T6.7), `docs/qa/ai-acceptance-cases.md` (follow-up note).

## Work and outcome

- New `TranscriptQuality.hasEnoughToReflect`: at least three words that aren't filler or swearing, or six characters of writing without spaces (Chinese, Japanese, Thai).
- The guest reflection review checks this before calling any engine. When there isn't enough, it shows "Too few words to reflect on. Add what happened and how it felt." and saves nothing; the words stay as written.
- Deviation from the handoff: it suggested `TranscriptQuality.evaluate`, whose bar (8 words and 32 characters) is meant for spoken transcripts. It would block ordinary typed entries such as "I felt stressed before the group meeting" (used by an existing UI test) and every Chinese entry. The new check reuses the same filler and swearing lists with a lower bar.
- Three existing unit tests used one- or two-word fixtures ("Words", "First words") for unrelated behaviour; they now use three words.

## Verification

- `xcodebuild test` (scheme Circleu, iPhone 17 Pro Simulator, separate derived data, `CODE_SIGNING_ALLOWED=NO`) for `GuestReflectionInputCheckTests`, `GuestSuggestionViewModelTests` and `GuestCopyLintTests`: 18 passed, 0 failed.
- Katherine's Xcode, unit suite (scheme Circleu, ⌘U, iPhone 17 Pro Simulator, iOS 26.5): 296 tests, 295 passed, 0 failed, 1 skipped (`testRealDataProtectionOnDevice`, physical device only).
- Katherine's Xcode, `CircleuUITests` (same Simulator): 30 tests, 26 passed, 3 failed, 1 skipped. None of the failures touch the reflection review:
  - `GuestVoiceTabsUITests.testTabsPracticeAndDictationDenied`: known; Simulators have no on-device speech (see [26 October](2026-10-26-173000-claude-fix-two-ui-tests.md)).
  - `GuestFindControlUITests.testSearchCalendarDraftExportAndDeleteAll` (line 49) and `GuestStatesUITests.testEmptyJournalPracticeAndCalendarDay` (line 133): both fail the same way on unchanged `origin/main` (`7347fb8`), rerun with `xcodebuild` on the same Simulator. Likely cause: the Mac and Simulator are set to Chinese (Macau), and the tests build the month and day labels they look for in that language while the app shows them in English. Not fixed here.
- Not run / limitations: no physical iPhone; Apple Intelligence not involved in this check.

## Discussion and decisions

None.

## Handoff

- Remaining work: item 2 (say why Apple Intelligence wasn't used); make the two calendar UI tests independent of the Simulator's language.
- Owner: Katherine
- Risks / unresolved questions: the three-word bar is a product guess; adjust `minimumReflectionWords` if real use shows it is too strict or too loose.
