# Today artwork and lower-layout correction

- Recorded: 2026-10-31 13:21:02 +11:00, Australia/Sydney
- Agent: Codex, prototype refinement and QA
- Branch/base: `codex/app-upgrade-plan`, `9967a10`; unrelated changes preserved
- Previous: [Today review 17](2026-10-31-130303-codex-today-flow-review-17.md)

Owner requested reuse of existing artwork, correction of microphone placement and improvement of the lower UI. Updated brief first. Reused Window pause and Voice corner scenes, grouped prompts/status and voice into the composer, preserved footer positions across six states. Replaced microphone instances after visual inspection exposed inherited scaling.

[Review 18](../design/figma-today-layout-review-18/README.md) contains screenshots, scripts and verification. Player checks passed for microphone/Stop, saving to Journal and writing-field interaction; inspected error layout and all six frames' geometry/reactions. Native behavior unchanged; no build, native tests, device check, commit or push. No credit-spending operation or image generation. No inter-agent exchanges.

Handoff: owner reviews Today, then connected Practice presentation. Stale-reflection prototype work from review 17 remains pending. Prototype evidence is not release qualification.
