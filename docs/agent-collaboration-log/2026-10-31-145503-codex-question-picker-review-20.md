# Optional Today question picker

- Recorded: 2026-10-31 14:55:03 +11:00, Australia/Sydney
- Agent: Codex; branch `codex/app-upgrade-plan`, base `9967a10`, uncommitted
- Prior: [review 19](2026-10-31-133726-codex-today-layout-review-19.md)

Owner approved the proposed curated-question sheet and asked to see the prototype. Updated brief first; added a shared overlay, three question choices, selected-question display and removal above writing. State is separate from entry text and reset on successful save/discard. Reused artwork/font/components and fixed navigation; no native scope expansion.

[Review 20](../design/figma-today-prompts-review-20/README.md) records IDs, screenshots and QA. Player checks covered all choices, change/remove preserving words, close, save and empty selection with Save disabled. Structural checks covered variable actions/bindings, fonts and editable layers. Native tests/device/VoiceOver not run. Initial variable scope failed with explicit safe rollback; corrected to ALL_SCOPES before retry. Centred inherited close glyph and fixed sheet corners after visual inspection.

No agent exchanges, credit-spending operation, commit or push. Handoff: owner review; native picker remains proposed, distinct from existing text-inserting chips and their tests. Prior stale-reflection gap remains pending.
