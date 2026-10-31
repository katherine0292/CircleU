# Native scene family: nine approved scenes, swappable by state

- Recorded: 2026-10-31 20:05 +11:00; Australia/Sydney.
- Agent / role: Claude Code, implementer.
- Status: implemented on `codex/scene-artwork-native`; suites and Codex pass recorded in the PR.
- Base: main `e0fed0b` (after PR 42). Related: [scene review 21](2026-10-31-165553-codex-approved-scenes-review-21.md), [ScreenScenes 07](../../Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/Resources/BrandArtwork/ScreenScenes07/README.md).

## Request and scope

Owner chose "artwork refresh" from the 31 October review: adopt the remaining approved scenes natively so screens can swap art the way the Figma Scene component does. No new illustration, no copy or flow change, no Firebase, signing or Release change.

## Work

- `GuestSceneArt` enum (nine cases, one 2:1 asset each) in `GuestPinguArt.swift`; `GuestScene` takes the enum, and `GuestSceneMessage` takes a scene instead of a raw name.
- Seven new imagesets copied unchanged from the ScreenScenes 06/07 masters; [provenance](../qa/scene-artwork-2026-10-31/artwork-provenance.json) records matching SHA-256 hashes.
- Placements: Journal empty state → Journal desk; reflection review sheet → Reflection garden; Bring in your earlier journal → Keepsake shelf; Practice start card → Practice studio. Today keeps Window pause / Voice corner by listening state through `GuestSceneArt.today(listening:)`. Refine workbench and Reply reading are bundled for the message-first Practice change; Welcome keeps its three approved full-bleed pages.
- Scenes remain decorative: `accessibilityHidden`, omitted at accessibility text sizes.

## Verification

`GuestSceneArtTests` (all nine bundled at 2:1, Today state mapping) written first and run with the Pingu art and copy-lint tests: 5 passed. Full unit and UI suite results are recorded in the PR. Simulator only; no physical-device check.

## Review

Codex (`gpt-6-astra`, read-only, Swift diff): no blockers. Suggestions, not applied here: UI coverage for the accessibility-size omission and VoiceOver semantics; a visual check of small-screen, keyboard and iPad layouts where width-proportional scenes replaced fixed-height art. Merged as PR 43 under the auto-merge rule (unit 278 pass; UI 26 pass across the rerun and the separately rerun Polish test).
