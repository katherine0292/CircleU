# Native Practice conversation

Approved scope: port the reviewed Prepare → Refine → Reply flow to the guest SwiftUI app, reuse Pingu branding, add real on-device dictation with transcript review, and open in Xcode for iPhone review. No cloud service, automatic sending or release change.

## Behaviour

- Prepare: original words, scene, tone and optional context. Continue opens Refine without generating or saving automatically.
- Refine: editable wording, opt-in local suggestions, Undo, Copy and explicit Save.
- Continue conversation: paste their reply and/or add context. Continue preserves the previous wording and attributed additions in a timeline, then opens a fresh reply draft. Nothing is labelled sent.
- Conversation history and metadata persist atomically with the existing practice record, revision and journal link. Existing records migrate without fabricated turns. Export and search include the timeline.
- New drafts retain conversation state. Edits to saved conversations require Save; Back confirms discarding changes.
- Record opens a review sheet. Request microphone/speech access only after Record. On-device recognition only; no audio files. Stop, edit, Use text appends to the selected field. Cancel and late callbacks never alter the field. Interruptions keep reviewable words.

## Execution ledger

- [x] Store V5 migration, conversation round-trip, revision/failure tests
- [x] Composer conversation, draft and suggestion-context tests
- [x] Dictation review state machine and cancellation/denial tests
- [x] Native branded Prepare / Refine / Reply / timeline / voice sheet
- [x] Unit and focused UI verification; review and fixes
- [x] Xcode/iPhone build setup; physical voice and accessibility checks recorded separately (pending owner)

Use the existing isolated worktree. Preserve legacy Firebase and unrelated changes. Update user stories and agent log with actual evidence. No commit or deployment requested.


## Verification ledger

- Initial feature tests failed at compile time on missing conversation/voice APIs, then the first five tests passed.
- Full unit suite after implementation: 262 passed, 1 existing skip. Additional context-only test reproduced a real wording failure; fixed using only the latest attributed additions. Final expanded unit suite: 266 passed, 1 skip.
- Fresh review by `/root/native_practice_review`: context-only acknowledgements and missing Stop in the scripted voice UI test. Both confirmed and fixed; no further concrete storage/cancellation defects reported. Static review does not certify device speech.
- UI conversation/voice, journal link/delete, normal/max-text pinned Save and suggestion checks passed. Edit/discard test corrected to use actual cursor-independent edited text; final UI rerun pending when this ledger entry was written.
- GuestReview build succeeded and installed in place. Xcode source/scheme/physical destination verified. Launch blocked by locked phone; owner asked to open Guest Test and check real dictation.
- No commit/push/merge. Full UI suite and physical speech/VoiceOver remain release gates.

Final focused UI rerun passed 3/3, giving 8 distinct affected UI passes across both runs. Full UI suite still required before merge. No further implementation edits after the verified device build, apart from project-file whitespace and tests/docs.

Owner confirmation, 27 October 12:01 +11:00: basic physical Record → Stop → Use text passed. This resolves the initial real-speech handoff; physical VoiceOver, interruption/cancellation and permission recovery remain unverified. See the follow-up agent log.
