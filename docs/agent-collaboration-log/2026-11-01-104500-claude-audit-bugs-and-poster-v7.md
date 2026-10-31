# Audit bug fixes and poster refinement 07

- Recorded: 2026-11-01 10:45 +11:00; Australia/Sydney.
- Agent / role: Claude Code, implementer.
- Status: implemented on `codex/audit-bugs-and-poster`; suite and Codex results recorded in the PR.
- Related: [31 October audit](../qa/project-audit-2026-10-31/README.md), [poster 07](../design/showcase-2026-10-30/refinement-07/README.md).

## Request and scope

Owner asked to fix bugs and make the poster. Bugs taken from the audit's open code findings; the poster follows the audit's call for exact approved screen exports instead of generated mockups. Not touched: Firestore ownership rules (A02/A03, need emulator work and a deployment decision), the retired Gemini model (A11, needs a provider decision or removal of the legacy cloud path), release identity and legacy recovery.

## Work

- **A06**: `LocalFirstSuggestionEngine.validatedOptions` keeps only the three asked tones (case-insensitive), each once, non-empty and within 60 words, so option identity stays unique and oversized or off-contract model output falls back to guided prompts. `GuestWordingValidationTests` (3 cases).
- **A09**: the four app-code actor-isolation warnings (`GuestLegacyImport.source`, `GuestTodayPrompts.followUps`, the analytics logger, `FirebaseRuntime.canUseLiveFirebase`) marked `nonisolated`; two unused-value test warnings removed. Test-target isolation warnings remain for a scoped change.
- **Practice result footer**: Compare with mine moved inline under the suggestion, so the footer is two actions and the suggested wording is not hidden on an iPhone 18 Pro. The UI test scrolls Compare clear of the footer before tapping.
- **Showcase capture test** `GuestShowcaseCaptureUITests`: seeds three tagged Journal entries, captures Journal, Today and a Practice result with guided suggestions, for reuse whenever the poster or slides need fresh screens.
- **Poster v7**: HTML/CSS master rendered with headless Chrome to 2560 × 1440, same headline, quotes and lockup as v6, real screens in place of generated phones, footer "Screens from the app build, 1 November 2026". Provenance manifest with hashes. No editable PowerPoint: the earlier builder's tool is not available on this Mac.

## Verification

Focused unit run (validation, suggestion, copy-lint, message-first tests): 15 passed. Capture and message-first UI tests: 4 passed. Full suites and the Codex pass are recorded in the PR. Simulator only.

## Review and result

Full suites on the branch: unit 292 passed, 1 device-only skip; UI 30 run, 29 passed, 1 live-Firebase skip; 0 failures. Codex (`gpt-6-astra`, read-only): no blockers. Applied: tones trimmed with `.whitespacesAndNewlines`, with a test for exactly 60 words and an invalid option followed by a valid one. Left for later: injected defaults instead of `nonisolated(unsafe)` on `GuestLegacyImport.source`; large-text/VoiceOver coverage of inline Compare. Merged as PR 45 under the auto-merge rule.
