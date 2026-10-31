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
