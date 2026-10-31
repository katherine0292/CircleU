# Practice reply/context and voice preview

- Recorded: 2026-10-27 10:32:39 +1100; Australia/Sydney
- Agent: Codex
- Status: browser prototype extended; actual native recording/model integration unchanged
- Base: 9967a10, codex/app-upgrade-plan; existing uncommitted work preserved

## Request and scope

Owner approved the branded Prepare/Refine screens and requested pasted reply / more context continuation, the current AI model explanation and voice input. Extended PracticeFlowReview in place with reply.js and a third screen plus clearly simulated voice dialog. Reused existing Pingu Friends and Listening artwork. No production Swift or assets changed. [Flow and AI source map](../design/brand-demo/practice-flow-02.md).

## Result and source evidence

Separate reply/context drafts; pending and failure state; guided options selected explicitly into editable Refine with Undo. Voice preview provides ready/listening/transcript review, denied/unavailable/interrupted states, append after review and cancel. No microphone, speech recogniser, storage or inference calls occur in this prototype.

Read GuestSuggestionEngine/GuestRootView, original CommunicationCoachEngine, legacy CloudReflectionEngine/ReflectionEngine and guest dictation source. Native guest code tries Apple's Foundation Models default with guided fallback. Original Practice is template-based. Legacy cloud reflection names gemini-1.5-flash but no runtime/service availability verified. Guest dictation requires on-device Speech and does not write audio files in that service. No provider recommendation or cloud switch made.

## Verification

- Browser observed independent reply/context drafts, empty context disabling action, pending response and simulated failure retaining text.
- Reply option and context option selections returned to editable Refine; Undo restored earlier wording.
- Final revision verified discards pending reply results after switching to empty context. Request invalidation is also wired to wording changes and leaving reply; not every timing permutation exercised.
- Voice Start/Stop produced fixture transcript; editing it then Use text appended to existing message. Denied state allowed typing with draft intact. Interrupted state retained fixture transcript for review; cancelling did not insert it. The unavailable state shares fallback handling but was not separately exercised.
- Captured voice-review-v2.png; final reply capture saved after completed options. Existing review.png remains historical two-screen evidence.
- node --check passed for both scripts; local HTML resource links resolved; git diff --check clean.
- One Playwright label lookup failed to find the selector; native browser AX setValue successfully selected the scenario. No product blocker inferred.
- No native/physical recording, AI inference, model availability, real permission dialog, browser clipboard or Xcode tests in this pass. Previous browser font-size tests do not qualify native accessibility. Real transcript errors/storage failures remain native integration work.

## Actual agent exchanges

None. No agent delegation. Voice-to-text with transcript review is Codex's recommendation; the owner has approved this prototype, not production cloud changes or release.

## Handoff

Review reply/context and the microphone preview at http://127.0.0.1:55988/PracticeFlowReview/. After design agreement, scope native integration against guest persistence and Speech boundaries. No commit/push/Figma write or external publishing performed. Remaining integration unassigned.
