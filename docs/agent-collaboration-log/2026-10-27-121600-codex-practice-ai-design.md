# Optional Practice AI feedback design

- Recorded: 2026-10-27 12:16 +11:00; Australia/Sydney
- Agent / role: Codex `/root`, planning and integration
- Base: `9967a10`, `codex/app-upgrade-plan`; uncommitted working-tree documentation
- Status: design ready for owner review; no implementation or cloud activation
- Previous: [initial AI planning](2026-10-27-120500-codex-practice-ai-planning.md)

## Request and decisions

Owner replied “ok” to including optional online processing of selected Practice text in the plan. This resolves the approach question in the preceding log, not provider, deployment, billing or real-data consent. Guest writing, reviewed voice input and local conversations remain core. Read current source, project/shared standards, MVP, content rules, relevant logs and provider documentation.

Created the [Practice feedback design](../superpowers/specs/2026-10-27-practice-ai-feedback-design.md) and linked it from the documentation index and MVP planning update. Proposed concise feedback, editable rewrite, explicit selected-text confirmation, attributed context, request invalidation, protected provider boundary, private-beta access/quotas and qualification gates. Paid Gemini is a candidate, not selected or configured; provider retention and age eligibility require verification before activation.

## Actual review exchange

Dispatched `/root/practice_ai_design_check` for the brainstorming skill's written-design builder check, read-only. Reviewer identified two material ambiguities: empty next-reply drafts after the existing flow clears wording, and preserving meaning when inputs exceed a rigid 60-word output ceiling.

Resolved as proposed engineering defaults: an explicit current-turn intent enables Draft a reply, while neither intent nor words prompts locally without inference; longer drafts may receive longer bounded rewrites rather than losing facts to a short target. Added validation/evaluation criteria and aligned consent snapshots. Reviewer reread the amendments and reported “Nothing important left.” This is a planning review, not code/security sign-off or owner approval of the detailed design.

## Evidence and limits

Checked official Apple hardware requirements, Gemini terms/retention guidance and Firebase callable App Check documentation; sources are linked in the design. No online service/deployed configuration was verified. Documentation relative links and whitespace were checked; no application tests or builds were run for this documentation-only work. No app code, credentials, model settings, Firebase resources or existing data changed. Existing dirty work preserved; no commit/push.

## Next

Owner can review the concrete design. Recommended first delivery milestone: branded feedback/context/error specimens with invented data, followed by provider qualification and fixture-backed integration. Implementation requires a separate authorised task; cloud activation additionally needs provider/retention acceptance, audience policy, project ownership and budget. No further agent assigned.
