# Practice wording feedback

27 October 2026 · Proposed design for a private beta · Planning only

## Decision and purpose

The owner wants AI feedback that improves typed or spoken wording, within the existing Prepare → Refine → Their reply flow. The owner accepted including **optional online processing of selected Practice text in the plan**, so personalised feedback can work on their iPhone 11 Pro Max. This does not approve deployment, billing, uploading personal messages or replacing the guest-first experience. Detailed choices below are recommendations for review.

CircleU should help a person express what they mean clearly, naturally and respectfully. It must preserve their facts, uncertainty, boundaries and voice. It must not make someone more agreeable at the expense of their intent.

Related: [MVP](../../product/mvp-definition.md), [native Practice plan](../plans/2026-10-27-native-practice-conversation.md), [backend assessment](../../engineering/competition-backend-readiness-2026-10-27.md), [content rules](../../design/screen-content-guidelines.md), [existing behaviour and tests](../../product/user-stories.md).

## Approaches considered

| Approach | Tradeoff | Decision |
| --- | --- | --- |
| On-device model only | Keeps inference local; supported hardware/runtime required. Older phones keep guided templates | Keep this capability, but it cannot supply personalised model feedback on the owner's phone |
| Optional online feedback, local core | Supports older phones; requires deliberate sharing, protected backend, provider qualification and cost controls | Owner chose to include this in planning |
| Required account and cloud conversation history | Adds account, sync and migration scope before the writing experience is validated | Defer |

Writing, recording and reviewing a transcript, editing, saving and reading conversations continue without online AI. No cloud backup, journal-wide analysis, audio upload, automated sending, simulated incoming replies, scores or personality judgements. Legacy Firebase recovery remains separate.

## Experience and concise content

1. **Prepare:** enter words or use Record → Stop → review transcript → Use text. Choose the existing scene and Soft/Balanced/Firm tone. Voice supplies editable text; this is not pronunciation, emotion or vocal-performance analysis.
2. **Refine:** replace the existing suggestion entry point with **Review my wording**. Keep the original words accessible. Save stays the sole filled primary button on the editor; the review action is secondary. Put less-used actions in the existing menu rather than adding a row of buttons.
3. **Choose processing:** offer **On this iPhone** when supported and **Online** when qualified/enabled. Unsupported on-device intelligence must say it is unavailable; guided prompts remain a separately labelled manual aid. Never silently switch to online after a local failure.
4. **Online review sheet:** heading **Review online**; summary **Only the text shown below will be shared**. Show the provider name and an inspectable, scrollable payload preview: current words, selected context and tone. Each context block can be removed. Primary **Send for feedback**; dismiss cancels. Repeat confirmation for every online request, including retries and tone changes. No persistent blanket consent in v1.
5. **Result sheet:** heading **Your wording**, at most two brief feedback points and one proposed rewrite. Visible source **Online suggestion · [provider]** or **On-device suggestion**. Supporting line **Check that it still sounds like you**. Primary **Use this wording**; secondary Edit suggestion; close rejects it. Original and suggested text are distinct. No score and no invented praise.
6. **Use:** changes only the current editor, with Undo available. It does not save, copy, send or append a conversation turn. Explicit Save persists through the existing store and revision checks. Copy remains independent.
7. **Their reply:** paste their actual reply and/or add context, then review the next draft. Retain the existing history and speaker labels. A prepared message is labelled **Prepared wording**, never assumed to have been sent. Missing reply/context leads to a useful question, not a fabricated response from the other person.

Empty-draft decision (proposed engineering default): the existing reply flow clears the next wording field. Do not require a fully written response before helping. If words are empty, show **What do you want to say next?** as a short current-turn intent field and label the action **Draft a reply**. This intent must be explicit for this turn; do not infer it from the other person's reply or silently reuse an earlier goal. With neither words nor intent, ask locally before any model call. Submit intent and selected context through the same confirmation and result flow. A generated reply is always a proposal, never a prediction of what either person will say.

Use existing Pingu art, rounded icons, Plus Jakarta Sans and guest colour tokens. One small thinking Pingu during loading is enough; honour Reduce Motion and keep status readable without motion. Do not introduce additional artwork as a dependency of this feature.

Static labels, explanations and errors follow the content rules. User text and generated proposed messages need a documented content-rule exception before implementation: they are editable content, not interface labels. Feedback bullets remain ≤100 characters each. Avoid truncating user text to fit a card; use accessible scrolling. No automatic inline spelling/highlight ranges in v1.

Example using invented text:

> Original: You never help with our project
>
> Feedback: “Never” may sound blaming. Try a specific request
>
> Rewrite: Could we agree on which parts of the project each of us will handle?

The rewrite must not invent deadlines, apologies, feelings or commitments. If a refusal is the user's intent, retain the refusal in every tone.

## Feedback contract

Add a dedicated injected `PracticeFeedbackProviding` boundary; do not route guest requests through the legacy cloud reflection engine. Keep the existing reflection and guided-prompt behaviour separate. Suggested type names are builder choices, not required renames.

Request v1:

- Version, random request ID, mode (`reviewWording` or `draftReply`), processing choice, English locale, selected tone, current draft, optional situation/goal, and explicitly selected conversation context. `draftReply` requires an explicit current-turn intent (maximum 500 scalar values); `reviewWording` requires nonblank words.
- Draft maximum 2,000 Unicode scalar values. Context maximum 4,000 scalar values in total, at most 8 blocks; encoded request maximum 32 KiB. Count with equivalent Swift/server rules. Never truncate silently: keep the editor content and ask the person to shorten the selection.
- Context blocks carry `preparedWording`, `theirReply` or `addedContext`. No automatic journal lookup. Include linked reflection material only if the person explicitly selects it from what they can inspect.
- Default online selection is current words (or the explicit current-turn intent for `draftReply`) plus optional situation/goal already entered for this Practice. History starts unselected; offer the latest prepared wording and pasted reply as selectable context. The preview must equal the actual submitted payload, except technical IDs and system instructions.

Typed result v1 is one of:

| Result | Payload / UI |
| --- | --- |
| Feedback | 0–2 feedback points, one rewrite, selected tone, source supplied by the trusted adapter |
| Clarification | One question ≤100 characters; return to editable context without losing words |
| Unable to help | A fixed, locally authored short message; keep manual editing |

Each feedback point has a category (clarity, grammar, tone or request) and ≤100 characters. Aim for a rewrite of ≤60 words for short inputs; allow up to 400 whitespace-delimited words and 2,400 scalar values when needed to preserve a longer draft's meaning. These are ceilings, not length targets. Never summarise away facts or boundaries to meet them: return clarification asking for a narrower intent if a complete rewrite cannot fit. No links, markup or tool calls. Validate schema, enum values, nonblank rewrite and hard lengths on both server and client. Reject malformed results without auto-repair calls or presenting raw model errors. The model cannot choose its own source badge. For `draftReply`, feedback may explain a wording choice but must not critique words the person never wrote.

Prompts treat pasted replies and all user text as data, not instructions. Preserve dialect and meaningful uncertainty; do not force formal English or insert apologies. Do not guess another person's feelings or intentions. Do not improve threats/coercion; where possible suggest a clear, non-threatening boundary instead. This is communication assistance, not mental-health diagnosis or crisis triage.

## State, cancellation and saving

Use explicit states: editing, confirming online, loading, feedback, clarification, unavailable and failed. At most one active request per editor. Freeze the exact input snapshot (mode, draft, current-turn intent, tone, context, conversation identity and revision) on submit. Every edit, tone/context/intent change, navigation away or newer request invalidates its result. Check snapshot and request generation again before displaying or applying a suggestion.

Cancel stops waiting and rejects late callbacks; do not promise it recalls data already sent. Backgrounding cancels the UI request and retains the original draft. A 20-second overall deadline includes provider work. On timeout/offline/provider rejection/invalid response, keep all text and offer an explicit retry through the confirmation sheet. No queued background upload and no automatic retry or provider switching.

Example error: **Couldn't review your wording. Your words are still here**. Offline: **You're offline. You can keep writing**. Changed input: **Your words changed. Review them again**. Quota: **Online feedback is unavailable for now. You can keep writing**.

Keep feedback and rejected suggestions in memory only. The accepted rewrite goes into the existing wording field; explicit Save uses the current conversation store. No persistence schema migration or durable feedback history is needed for v1. Original words, attributed turns, IDs, source links, export and deletion retain their current semantics. Provider/version/prompt metadata is used in invented-data evaluation, not added to personal journal records. App restart may lose an unaccepted suggestion, but never discard the existing draft through this feature.

## Proposed backend and privacy boundary

Recommended route: SwiftUI view → existing Practice ViewModel → injected feedback service → isolated Firebase callable function → qualified text-model provider. Reuse Firebase expertise, not the unverified legacy project or old hardcoded model configuration. A callable function is a proposal; no function deployment or live service was verified in this task.

Keep the optional online service lazily initialised after consent. Guest startup, local editing and local saving must not initialise Firebase for this feature. Use a separate configured Firebase app/project boundary from legacy account recovery; verify SDK configuration in implementation. Never put provider secrets in the iOS bundle. Server credentials belong in a secret manager with least privilege. Neither app nor server should send analytics events containing draft, reply, transcript or model content.

Private-beta access proposal (engineering default, subject to review): invite-only online access with a revocable, server-issued opaque installation grant. One-use enrollment codes are distributed to consenting testers; exchange requires valid App Check. The grant is stored in Keychain, its verifier hashed server-side, and no email or account is required. Reinstall/replacement requires a new invite if the grant is unavailable. Do not use a client-generated installation ID as an abuse boundary. Do not silently create Firebase anonymous accounts. App Check verifies app authenticity; it is not person identity or a complete rate limiter.

Enforce server-side grant validity, App Check, body limits, one in-flight request per grant, 5 requests/minute and 20/day/grant initially. Global requests/day and worst-case token reservation must be capped before provider dispatch according to the owner's eventual budget. Billing alerts alone are not spending limits. Atomic accounting, provider output caps and a server kill switch are beta gates. Debug attestation must never grant production access.

Deduplicate by grant + random request ID: reject a duplicate for 24 hours instead of reissuing model work. Keep no response cache or hash derived from private text. A timeout is counted as dispatched unless non-dispatch can be proven; explain this in tester support, not routine UI. A deliberate retry gets a new ID and may use another request allowance.

CircleU server content handling: request/response in memory for the request lifetime; no raw bodies in logs, traces, error reports, analytics or databases. Store only grant verifier/status and bounded quota/idempotency records (IDs, counts and expiry); logically expire request records after 24 hours and quota buckets after 48 hours, enforce expiry on reads and verify physical cleanup. Delete revoked grants and associated metadata within 7 days. Proposed retention is not a deployed claim. Provider retention is separate and must be disclosed accurately.

Before shipping, audit Welcome, Privacy and data, Settings, source badges and all “not uploaded” copy. Proposed summary: **Saved here. Online feedback shares selected text**. Expand with provider identity, selected payload, purpose, retention and cancellation limits. Local delete must not claim to erase already processed provider records. Consent applies to this request only and must remain reachable at maximum Dynamic Type with VoiceOver.

## Model selection and qualification

Current code uses Apple's Foundation Models when available, with guided fallback; there is no verified online provider for the guest build. The owner's speech-input confirmation does not establish on-device language-model support. Apple lists supported Apple Intelligence hardware separately from ordinary speech recognition.

Benchmark a currently supported stable **paid Gemini text model** as the first online candidate, plus an alternative qualified provider if quality/privacy/availability fails. Keep the adapter interchangeable; exact model ID, price, region and version must be verified at evaluation time. Do not copy the legacy Gemini 1.5 model ID or select a preview/latest alias for the beta. Compare on-device output on supported hardware as a separate route, not an interchangeable offline guarantee.

Use invented English scenarios only during qualification. Free-tier/product-improvement programmes and optional contribution/logging programmes are excluded for personal Practice content. Paid Gemini terms exclude product improvement but permit limited abuse-monitoring retention; they do not establish zero retention. If the owner requires guaranteed zero retention, qualify a suitable enterprise/provider arrangement before enabling online AI.

Gemini Developer API terms also restrict under-18 access. The existing MVP proposes adults 18+; that audience is not yet a settled release control. Verify provider eligibility and an adult-only beta recruitment/access policy before adopting this provider. If the app must serve under-18 users, reassess the provider and controls; do not silently change the app audience.

Primary sources checked 27 October 2026:

- [Apple Intelligence requirements](https://support.apple.com/en-au/121115): hardware/runtime eligibility.
- [Gemini API terms](https://ai.google.dev/gemini-api/terms): paid/unpaid data handling, age and region restrictions.
- [Gemini retention guidance](https://ai.google.dev/gemini-api/docs/zdr): product-improvement exclusions are distinct from retention.
- [Firebase callable App Check enforcement](https://firebase.google.com/docs/app-check/cloud-functions): attestation enforcement; additional authorisation and quota design still required.

## Delivery sequence and acceptance

These are proposed milestones, not implementation approval or completed tests.

| Phase | Deliverable | Exit evidence |
| --- | --- | --- |
| 1. Review the experience | Branded feedback, context confirmation, clarification and failure specimens using invented data | Owner reviews copy, rewrite behaviour and payload visibility; no cloud |
| 2. Qualify providers | Fixed synthetic dataset, prompt/result schema, eligible provider shortlist and cost/retention comparison | Exact model/version and terms documented; critical quality gates pass |
| 3. Local integration | Injected fixture provider, state machine, Use/Undo, accessible result sheet | Unit + affected UI tests; full unit/UI suites before merging guest changes |
| 4. Protected online slice | Isolated backend, attestation, beta grants, quotas, kill switch and consent | Owner-approved project, provider, audience policy and budget; security/integration tests; no legacy-data change |
| 5. Physical private beta | Invite-only use on owner's phone and supported on-device-model hardware | Real network, cancellation, keyboard, VoiceOver, largest text, reduced motion and offline checks |

Evaluation: at least 40 invented cases across university/work/friend/family/relationship contexts, all three tones, replies and context-only continuation, refusals, ambiguity, dialect/grammar, prompt injection and harmful requests. Run each twice. Record model/prompt versions, latency, usage and reviewer notes. Launch gate: zero observed invented facts/commitments, reversed boundaries, wrong-speaker rewrites or followed injected instructions; ≥90% useful and natural rewrites in human review; all failure cases preserve text. No claim that passing this finite set guarantees safe or correct output. Revise failures and rerun the full fixed set.

Behaviour tests: one request per explicit submit; no network before consent; payload equals preview; no audio/journal leakage; limits enforced on both ends; no cross-grant access; duplicate requests not recharged; quota/cost-cap races fail closed; malformed response safe; edits, tone/context/intent changes, Back, background and cancellation invalidate late results; Undo restores exact prior words; Save conflict preserves edits; copy never saves; drafts/history/export/deletion unaffected. Empty words and no current-turn intent must prompt locally without provider invocation; intent-only drafting must preserve attributed context. Include long drafts near the input ceiling in the meaning-preservation evaluation and test oversized output rejection. Test App Check/grant denial without provider invocation. Verify SDK/logging configuration and cleanup rather than assuming it.

Measure latency rather than promising instant feedback; target p95 ≤8 seconds for beta evaluation, with the 20-second deadline as the failure bound. Do not replace the current local route until its structured-result implementation passes its own tests.

## Open release decisions and builder discretion

Owner decisions before cloud activation: provider and retention acceptance, adult-beta eligibility policy, project ownership/billing and spending cap. These do not block offline specimens or implementation planning. Detailed design approval precedes product code; no secrets, billing changes or real-message uploads are authorised by this document.

Builder may choose file/type names, accessible sheet composition, server language and test tooling within existing project standards. Preserve existing feature folders, branding, original Practice flow and legacy data. Update user stories, content-rule exceptions and privacy documentation alongside any later implementation; do not mark proposed criteria as passing now.
