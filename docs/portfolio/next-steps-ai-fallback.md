# Next steps: AI input check, fallback reason, acceptance table

Katherine's plan for three AI experience improvements, carried out on her Mac with Xcode.

## Goal

Three small changes that show product thinking in the AI flow, kept low in technical complexity. Each one is its own commit, with tests run in Xcode before committing. These are follow-up work dated November 2026; describe them as improvements after the migration, not as the original migration.

## 1. Don't ask the AI when there are too few words

- **Now:** the guest Journal sends any text to the suggestion engine (`Circleu/Features/GuestJournal/GuestReflectionReview.swift`, the `suggester.reflection(for:)` call). Three words still produce a full reflection card.
- **Change:** check the words first with the existing `TranscriptQuality.evaluate` (`Circleu/Engines/TranscriptQuality.swift`). When they aren't enough, don't call the engine; show one short prompt asking what happened and how it felt.
- **Rules:** on-screen text follows `docs/design/screen-content-guidelines.md`; `GuestCopyLintTests` must pass.
- **Tests:** in `CircleuTests/GuestSuggestionTests.swift` (or a new file), empty, filler-only and too-short text never reach the engine. Run the unit suite and the `CircleuUITests` scheme.

## 2. Say why the AI isn't being used

- **Now:** when Apple Intelligence can't be used, the guest label only says "Guided prompts, not a personal analysis" (`GuestSuggestionSource.label` in `Circleu/Services/GuestJournal/GuestSuggestionEngine.swift`). The reason is lost.
- **Change:** keep the reason (device not eligible, Apple Intelligence turned off, model still preparing) and show it in one plain line. The legacy wording to adapt is `AppleIntelligenceReflectionEngine.availabilityMessage` in `Circleu/Engines/ReflectionEngine.swift`; shorten it to the guideline limits.
- **Tests:** each reason maps to the expected line; the guided result is still returned.

## 3. Acceptance table for AI answers (docs only)

- A table of 15–20 invented examples (argument with a teammate, being interrupted, only swearing, only two words, very long text). For each: what a good answer contains and what must never appear (repeating swearing, diagnosis, vague next steps).
- File: `docs/qa/ai-acceptance-cases.md`. Never use real journal content.
- Optional later: turn a few rows into unit tests against `LocalReflectionEngine`.

## Done when

Each change is committed on a `codex/` branch with a log entry in `docs/agent-collaboration-log/`, says what was and wasn't tested (Simulator vs. physical iPhone with Apple Intelligence), and is offered to the team repository as a pull request for review.
