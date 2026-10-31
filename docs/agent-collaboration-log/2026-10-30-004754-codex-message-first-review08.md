# Message-first browser review 08

- Recorded: 2026-10-30 00:47:54 +11:00; Australia/Sydney
- Agent / role: Codex / prototype implementation and browser verification
- Status: completed bounded browser iteration; native integration pending
- Base: `9967a10`, `codex/app-upgrade-plan`, existing linked worktree and dirty changes preserved; no commit/push
- Prior: [direction and short design](2026-10-30-001700-codex-message-first-direction.md)

## Request and scope

Owner approved the message-first flow design before updating the prototype. Wrote and executed the [bounded plan](../superpowers/plans/2026-10-30-message-first-prototype.md). Changed PracticeFeedbackReview HTML/CSS/feedback.js, screenshots and related docs. Existing native source, style-profile.js, asset originals and other prototypes unchanged this turn.

## Outcome

Initial blank writing surface; optional collapsed context/tone; Help me get started collects an outcome/context and returns without generation. Intent is labelled, editable and clearable. Consent/result distinguish intent from original wording. Review is primary, with separate Save/Copy actions; Use/Undo refresh blank-state controls. Clipboard status follows successful browser copying and is guarded against changed wording. Save remains volatile.

No microphone or durable conversation history was rebuilt in the browser. Existing native voice/history remain separate; this is partial P9 prototype evidence, not delivery of the complete native spec. Fixed output and no-upload boundaries remain disclosed. R04 remains open before transport.

## Verification

- Baseline observed in browser before editing: no guidance route; Save primary.
- Browser after edits: blank review/save disabled; guidance blank validation; Continue returns without generation; typed draft preserved on Back/Continue; exact intent/context/tone preview; intent-only result attribution; edited Use then Undo restores empty wording and disables Save; separate Wording updated, Copied. Not saved or sent., and Saved statuses.
- New request cancellation and service error preserve wording and invalidate prior Undo. Reply-intent validation, unchecked reply sharing, and separate reply clarification checked. Larger-text guidance Continue and Edit/Clear intent exercised.
- Standard blank/guidance layouts and larger-text guidance visually inspected; four screenshots saved in [README](../../Prototypes/CircleUVisualPrototype/PracticeFeedbackReview/README.md). No browser error logs reported at final check.
- `node --check` passed for both scripts; 88 unique IDs, literal script ID references and 14 resource paths checked. Changed Markdown link targets/whitespace and `git diff --check` checked.
- Preview server had stopped; restarted on loopback. Stale tab/old locator closure caused connection-error output; refreshed tab and locators restored verification. One Context and tone text locator omitted its Optional child text and timed out; source/DOM inspection and the exact summary locator then passed. Neither was treated as an app failure or hidden passing test.
- Not run: full native suites, physical keyboard/VoiceOver/swipes, actual provider quality, arbitrary timing races, durable save/reopen or real voice. No production readiness claim.

## Actual review exchange

Codex requested a scoped read-only review from `message_first_review`, comparing the three prototype files to pre-edit copies and the approved design. Reviewer reported one issue: ID specificity left Edit/Clear intent at 12px with Larger text. Codex reproduced 12px in browser, treated it as an accessibility issue to fix in this pass, added the override, and verified both at 20px. Reviewer reported no other concrete regressions; that was static evidence, independently supplemented by the browser checks above. No files were edited by the reviewer.

## Handoff

Owner review of review 08, then native implementation scope and any voice/history integration plan. Do not copy canned outputs into a real model pipeline. Preserve data/recovery gates and R04. Owner: Unassigned.
