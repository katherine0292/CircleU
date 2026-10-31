# Practice AI feedback planning

- Recorded: 2026-10-27 12:05:00 +11:00; Australia/Sydney
- Agent / role: Codex `/root`, planning
- Status: proposal; model/data-processing approach awaiting owner choice
- Base: `9967a10`, `codex/app-upgrade-plan`; existing working-tree changes preserved
- Related: [native Practice implementation](2026-10-27-111230-codex-native-practice-conversation.md), [physical voice confirmation](2026-10-27-120120-codex-practice-phone-voice-confirmation.md)

## Request and findings

Owner wants a plan for AI feedback and improving typed/spoken wording in Practice. Read current GuestSuggestionEngine, native conversation plan, user stories, content rules, MVP boundaries and backend readiness. Current engine returns wording options, without a structured feedback contract. It attempts Apple's on-device model when available and otherwise uses guided templates. Speech success does not establish model availability. Owner's previously identified iPhone 11 Pro Max is outside Apple's supported Apple Intelligence hardware list.

Source checked: [Apple device requirements](https://support.apple.com/en-au/121115). No provider selected or deployed service verified.

## Proposal presented for discussion

Retain Prepare → Refine → Reply. Add opt-in Review my wording: a brief useful observation, one actionable improvement and one editable rewrite, with alternatives behind tone controls. Preserve meaning, factual uncertainty, boundaries and original words; no personality scores, guessed motives, fabricated replies or automatic sending. Voice enters the same flow only after transcript review. Conversation requests must distinguish prepared wording, pasted replies and added context; ask for missing context instead of inventing it.

Two approaches: continue on-device-only (supported hardware receives AI; older hardware keeps guided prompts), or retain local core features with explicit optional online AI for selected Practice content. Recommend evaluating the latter for actual AI on the owner's phone, subject to a new data-processing decision. Existing no-cloud direction remains in force until changed explicitly. No automatic fallback/upload.

Proposed work order: agree feedback examples and concise copy; compare approaches and choose privacy/provider direction; prototype compact feedback; implement typed result/provider boundary and stale-result/cancellation handling; benchmark invented conversations; qualify failure/offline/permission/accessibility behaviour. Online approach additionally needs a protected backend boundary, verified provider retention terms, abuse/cost limits and accurate privacy copy. No automatic journal-wide context or audio upload.

## Verification and handoff

Research/planning only. No app, Firebase, model settings, credentials, network data-processing route or release behaviour changed. No tests rerun; documentation whitespace check only. No inter-agent exchange. Next owner decision: whether optional online processing of selected Practice text belongs in the plan. Detailed approved design and implementation plan follow that choice; no claim that cloud AI is authorised.
