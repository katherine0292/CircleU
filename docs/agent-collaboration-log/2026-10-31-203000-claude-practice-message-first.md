# Message-first Practice in native

- Recorded: 2026-10-31 20:30 +11:00; Australia/Sydney.
- Agent / role: Claude Code, implementer.
- Status: implemented on `codex/practice-message-first` (on top of the scene-artwork branch); suite and Codex results recorded in the PR.
- Related: [short design](../superpowers/specs/2026-10-30-message-first-practice-design.md), [Figma current prototype](https://www.figma.com/proto/rfknpmLIXsOxA7fHUQQMtR/CircleU-Design--from-Claude-canvas-?node-id=74-3&starting-point-node-id=74%3A3) frames `blank`, `filled`, `guide`, `intent`, `refineA/B`, `applied`.

## Request and scope

Owner chose "message-first Practice in native" from the 31 October review. Port the approved entry route while reusing the existing composer ViewModel, conversation store, drafts and suggestion engine. No live AI: suggestions remain on-device Apple Intelligence or guided prompts, so the prototype's "Review online" consent step is deliberately not built (P8/P9.4 stay open).

## Work

- `GuestPracticeComposerViewModel`: stages `prepare → guide → result → refine → reply`; `reviewWording()`, `findWordsFromIntent()` (blank start, result labelled as intent), `openGuidance()` / `continueGuidance()` (requests nothing), `suggestedWording` / `otherWordings` with the chosen tone first, `useSuggestedWording()`, `keepMyWording()`, `saveWithoutFeedback()` (plain save, no review history).
- `GuestPracticeMessageView`: "What would you like to say?" with the editor, Record, Help me get started, intent card and a folded "Context and tone"; "What do you want to happen?" guidance; "Find your words" with the Refine workbench scene, one suggested wording, source label, Compare with mine (mine or my intent beside the other tones) and Use / Keep; "Your wording" keeps Copy, Undo, Get a suggestion, Continue conversation and the pinned Save. Reply uses the Read and reply scene.
- Footer actions: Review wording (filled) or Find words from my intent, plus Save without feedback; Back from guidance or the result keeps words and intent.
- Tests: `GuestPracticeMessageFirstTests` (7 unit cases, written first; the save-without-feedback case first failed because the save created a conversation record, fixed by saving plainly) and `GuestPracticeMessageFirstUITests` (3 journeys). Existing Practice, suggestion and polish UI tests now reach "Your wording" through `reviewAndKeepWording`.
- Docs: P9 rows in the user stories now cite tests; flow checklist F10 updated.

## Verification

Focused unit run: `GuestPracticeMessageFirstTests` and `GuestPracticeViewModelTests` pass with the copy lint. Full unit and UI suites, and the Codex pass, are recorded in the PR. Simulator only; no physical keyboard, VoiceOver or speech check.

## Review

Codex (`gpt-6-astra`, read-only, Swift diff), first pass: three blockers. (1) Options from an earlier review stayed usable while a new review loaded or failed. (2) An Undo snapshot survived a newer review and could wipe hand edits. (3) The save refactor refreshed history only for new messages, so an edited conversation could reopen stale. Fixed in `3fb1085`: `startReview()` clears options, error and Undo before each request; `finishSave(wasNew:)` reloads history after every save and clears the kept draft only for new messages; two unit tests added. Second pass: all three resolved, no new regression, no blockers. Non-blocking notes kept for later: delayed-suggester tests (Keep during generation, Back/edit/re-review, failure after success), a loading-state assertion, and largest-text/VoiceOver coverage for guidance and the result footer.

## 1 November follow-up

The full unit run found an older test broken by the chosen-tone ordering (it had applied to Get a suggestion as well); the ordering now applies only on the result screen. A review let go with Keep my wording left "Making suggestions…" until the on-device model returned, so a dropped request now clears the waiting state at once. Codex's pass on that change found one more blocker, the same stuck state after Continue conversation; `dropPendingSuggestion()` now covers both. Final Codex pass (`d6bbb12`): no blockers. Non-blocking test gaps noted by Codex: overlapping replacement requests and late errors with a slow suggester.
