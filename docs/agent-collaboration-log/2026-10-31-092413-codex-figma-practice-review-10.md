# Practice review 10 — flow completion and Refine alternatives

- Recorded: 2026-10-31 09:24:13 +11:00; Australia/Sydney; verification continued in the same turn
- Agent / role: Codex / design and prototype review
- Status: scoped Figma review delivered; owner selection pending
- Base revision and branch: 9967a10, codex/app-upgrade-plan; uncommitted work preserved
- Related: [review 09 record](2026-10-31-083249-codex-figma-practice-and-credit-cap.md)

## Request and scope

Owner approved a polished Practice flow, two Refine alternatives and missing voice/Copy/reply/recovery interactions. Work was limited to a separate Figma page and `docs/design/figma-practice-review-10/`. No native feature, Firebase, account, model or release changes.

## Work and outcome

[Review 10](../design/figma-practice-review-10/README.md) adds editable brand-matched screens, preset recording/transcript correction, selected-text confirmation, two feedback layouts, separate Copy/Save outcomes, attributed replies and a second prepared message. Done/reopen retains the completed scenario. Failure starts and draft-departure choices are included. Prior screens remain intact. All illustrative conversation text is invented.

## Verification

- Final Figma structural read: 56 states, 155 valid links, 374 text layers, 148 component instances; Plus Jakarta Sans only; no detected top-level overflow or measurable UI-copy violations. Header y=50 and footer bottom y=816 throughout.
- Browser clicked the full recorded-input and two-message path, comparison view, Copy status, Save and reopening. Screenshots exported and inspected. Other branches structurally checked, not all manually exercised.
- First construction call rejected an unsupported overflow enum and reported safe retry. Changed it to the supported VERTICAL value; exactly one review 10 page exists. No failed partial page remains.
- `git diff --check` passed; no app build or runtime tests because app code was unchanged. Figma states do not establish live microphone, clipboard, AI, durability or accessibility.

## Discussion and decisions

Inter-agent exchanges: None. The owner approved the bounded prototype approach. Recommendation for review: A is more distinctive for the showcase; B makes original-versus-suggestion comparison more immediate. Final selection remains the owner's.

## Credit clarification

After the prior log's unverified balance statement, the Figma editor was checked and displayed 3,000 AI credits under the Education plan, resetting November 1. These are separate from the last reported 144 Weave credits. This task used direct Figma editing and submitted no paid generation request; no debit was returned by MCP. No Weave credits or plan upgrade were requested.

## Handoff

- Owner: Unassigned; user design review next.
- Choose A/B, then carry the selected style to Today/Journal under a new scoped review. Optional tone/context, voice append, more than two prepared messages and other documented fixed-scenario limits remain pending.
- No new native implementation approval inferred from this prototype.
