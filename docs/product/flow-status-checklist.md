# CircleU flow status and next actions

## Current follow-up — 31 October native alignment

The owner approved the audit sequence. Current guest/review source implements the accepted Today question picker and Journal date-grouped cards with optional context/feeling tags. V6 migration, save/error behavior and brand reuse are recorded in [native alignment QA](../qa/native-alignment-2026-10-31/README.md). That report is the authority for fresh test outcomes and remaining device checks. Earlier prototype-only notices below describe the state before this approval.

## Earlier prototype evidence

31 October F03 prompt exploration: [review 20](../design/figma-today-prompts-review-20/README.md) adds an optional curated-question sheet and non-destructive selection above writing. At that review, T1-P was prototype-only; the approved native replacement is now covered by T8–T10.

31 October visual follow-up: [Today review 18](../design/figma-today-layout-review-18/README.md) reuses scene artwork and groups writing, prompts and voice while preserving fixed footers. Player and geometry evidence only; native behavior and test status are unchanged.

31 October Today prototype evidence for F03/F04/F06/F07/F09: [review 17](../design/figma-today-flow-review-17/README.md) restores missing artwork, exposes draft resumption, preserves typed words when dictation is cancelled, and adds blank/writing/save/retry/discard reflection states with saved-entry reopening. Fixed fixture and session-state checks only; native implementation and test status are unchanged.

31 October prototype evidence for F08/F14/F15: [Journal review 16](../design/figma-journal-flow-review-16/README.md) repairs blank search, calendar counts, mismatched discard copy and editor tab exits. Player checks cover search/tag/edit return, selected-date return, empty day/month, one-to-two entry counts and calendar scrolling. Native status below is unchanged; no app tests were rerun.

Updated 31 October 2026. Read the [product brief](overview.md) first, then the [MVP register](mvp-definition.md) and [user stories](user-stories.md). This is the single current delivery-status register; earlier dated QA/logs remain historical evidence.

## Reading the status

- **Planned:** documented requirement; no implementation implied.
- **Prototyped:** a visual/interactive specimen exists. It may use fixtures and temporary state.
- **Native implemented:** source exists in the guest/review configuration, possibly uncommitted. It does not imply Release/TestFlight availability.
- **Verified:** use only for the specific behaviour, build/configuration and device recorded in evidence. A test name is not a fresh passing run, and no whole flow below is declared fully verified.

Except for the fresh audit/alignment reports above, verification summaries below are inherited from dated evidence. Detailed per-criterion test coverage lives in the stories, not duplicated here.

Evidence references:

- **Stories:** [native criterion/test inventory](user-stories.md). Partial checks are explicitly marked; a named test does not establish present working-tree status.
- **Native Practice QA:** [27 October review](../qa/native-practice-2026-10-27/README.md): unit run 266 passed / 1 skipped; affected UI checks across multiple runs, not a full UI-suite pass. Physical Record → Stop → Use text confirmed on iPhone 11 Pro Max; permission, append/edit and VoiceOver coverage remains bounded.
- **Onboarding QA:** [25 October review](../qa/native-onboarding-final-review-2026-10-25.md): isolated preview keyboard, largest-text and VoiceOver owner reports. Do not transfer that sign-off to every later guest screen.
- **Feedback prototype:** [browser review](../../Prototypes/CircleUVisualPrototype/PracticeFeedbackReview/README.md), [compact Refine](../agent-collaboration-log/2026-10-28-refine-prototype-focus.md), [communication style](../agent-collaboration-log/2026-10-29-communication-style-prototype.md). Fixed responses, no live AI; volatile style preferences.
- **Release boundary:** [backend assessment](../engineering/competition-backend-readiness-2026-10-27.md). Standard Release remains the original app; legacy Firebase mapping and recovery/distribution qualification remain open.

## Flow register

IDs F01–F22 are retained from the earlier checklist. F23/F24 cover the newer proposed extensions. “Native” below always means the guest/review implementation, never a release claim.

| Flow / requirement / stories | Implementation or prototype status | Verification evidence and limits | Next review / pending work |
| --- | --- | --- | --- |
| **F01 Welcome and optional Log in** · M01 · W1–W2 | Native guest entry; earlier onboarding specimens | Stories list welcome/navigation tests; isolated Onboarding QA is historical | Review current guest version at large text/VoiceOver; retain guest start and optional recovery |
| **F02 Privacy** · M01/M07 · S1 | Native guest summary/details | S1 UI test; storage protection is partly injected | Verify comprehension and backup limits; revise copy before any online feature |
| **F03 Today/navigation** · M02 · T1, T8–T10 | Native three-tab app, compact composer and non-destructive question guidance; window/voice scenes | T8–T10 alignment tests and screenshots; physical follow-up remains | Review native captures and test keyboard/VoiceOver on the target phone |
| **F04 Typed capture** · M02 · T1 | Native save and failure handling | Unit criteria cover save/failure/concurrent typing; UI coverage linked | Walk through keyboard, empty input and failed-save recovery on target devices |
| **F05 Voice** · M02 · T3–T5, P6 | Native Today dictation and separate Practice transcript review | Native Practice QA verifies a physical basic path; scripted/injected failures | Check denied/interrupted speech, transcript editing, append and VoiceOver physically; preserve typing |
| **F06 Reflection** · M03 · T6 | Native optional reflection after original save | Story tests cover suggestions/fallback with partial UI coverage | Review accepting/editing/rejecting suggestions and source labels; assess actual model quality separately |
| **F07 Original-words save** · M02/M03 · T1, T6 | Native save without reflection | Store tests and linked UI coverage | Confirm the primary route stays clear and useful with no model |
| **F08 Saved entry editing** · M06 · J4 | Native revision-aware edit, discard and reopen | Unit + UI tests, including discard; no full new device qualification | Review latest-entry reopening and stale/deleted-item recovery |
| **F09 Draft retention** · M06 · T2, P4–P5 | Native durable new-entry/practice drafts | Relaunch/round-trip unit tests; saved-message edits require explicit Save | Exercise process interruption and keep/discard meanings across both editors |
| **F10 Direct Practice** · M04 · P2, P5, P9 | Native message-first entry (31 Oct): words → optional intent guidance → Find your words (Use / Compare / Keep) → Your wording → saved conversation, actual reply/context continuation | P9 unit and UI tests; native Practice QA; scene/detail selection not fully automated | Review on the phone: guidance copy, result hierarchy, reply attribution; use F23 for online feedback |
| **F11 Linked Practice** · M04 · P1, P5 | Native explicit source link and conversation continuation | Unit/UI link/reopen tests; actual shared-context review still needed | Confirm correct source and independence of saved reflection/message edits |
| **F12 Edit / Copy / Save** · M04/M06 · P3 | Native independent actions, copy-status invalidation, edit/discard | Native Practice QA and named unit/UI tests | Check comprehensibility and accessibility on phone; no implication a message was sent |
| **F13 Optional next step** · M05 · T7 | Native suggested/editable step behaviour | Per-criterion tests in stories | Review skipping, editing and reversing completion without a quest/streak journey |
| **F14 Journal/search/detail** · M06 · J1–J2, J4, J6 | Native date-grouped cards, optional context/feeling tags, retrieval and editing | J7 V5→V6 migration/store tests and alignment UI coverage; physical spoken labels remain unverified | Review tag density and VoiceOver on the target phone |
| **F15 Calendar** · M06 · J3, J6 | Native month/day retrieval; not just static art | Calendar unit + UI tests; visual dot layout partly inspected | Check locale/time-zone boundaries, hit areas and VoiceOver; no extra calendar mascots |
| **F16 Practice history** · M04/M06 · P3, P5 | Native saved conversations and attributed turns | Native Practice QA; migration/export/search tests | Review long conversations, source tags and saved-versus-sent distinction |
| **F17 Stale suggestions** · M03/M04 · J4, P4; proposed P7 | Native source/revision protections; new feedback rules proposed | Current unit coverage does not verify future online races | Test edits/tone/context/style changes against late responses before new integration |
| **F18 Loading/validation/errors** · M01–M07; proposed M09 | Native representative errors; browser online fixtures | Criteria-specific tests; no claim every error/state is covered | Review each changed screen's empty/loading/cancel/failure path, never false success |
| **F19 Offline/protected storage** · M02/M06/M07 · T1–T5, J1, S1 | Native manual/guided fallback and store protection; Release gate open | Injected protection/capability tests; not complete device/network evidence | Verify locked-file behaviour, offline use and network boundaries on release candidate |
| **F20 Export/delete** · M07 · S2–S3, J5 | Native guest scope and linked-data choices | Store tests; share-sheet completion only partial | Physically complete export; check atomic failure and no resurrection; future style data in S9 |
| **F21 Earlier data/recovery** · M07 · W2, S5, S7; retained S6/R6 | Native explicit account route; local legacy scanner retained but unreachable | Fake-account/unit evidence; old shipped Firebase project not proven | Resolve ownership/project mapping and safe recovery distribution; preserve sources |
| **F22 Old-account deletion** · M07 · S8 | Native adapter/confirmation path | Unit/injected failure tests and partial UI; no blanket deployed guarantee | Verify exact cloud/shared-content scope, ownership and partial failures before release |
| **F23 Refine feedback + optional online request** · M09 · P7–P8 | Planned + browser prototype only; no live provider/native feedback extension | Fixed fixture interaction checks; no model-quality, native or network pass | Review concise feedback, editable rewrite, Use/Undo, payload and failures; approve native slice separately |
| **F24 Communication style** · M10 · S9 | Planned + browser prototype; preferences in memory only | Browser save/clear, unchecked sharing, formal/brief fixture and original-entry checks | Review optional settings and per-request sharing; decide durable/export/delete contract before native work |

M08 follow-up is P1 and deferred from the first beta unless selected. No new implemented follow-up flow is implied by F13's next-step behaviour.

Latest [Refine/style review follow-up](../design/refine-story-review-2026-10-29.md#resolution--browser-review-06): R01 clarification, R02 prior Undo and R03 saved-off style status are fixed and retested in browser review 06. Native integration/verification remains pending. R04 selected-payload separation remains required before transport.

Browser review 07 adds the existing Pingu scene, writing/source cards and outline navigation icons. Editor/result and larger-text clarification/style were inspected, and affected editing/navigation controls exercised. [Visual evidence](../../Prototypes/CircleUVisualPrototype/PracticeFeedbackReview/README.md). This updates F23/F24 presentation evidence only; native criteria remain pending.

## Next UI review order

30 October owner selection: lead the demonstration with preparation and message-first Practice, with optional guidance. Review the [short flow design](../superpowers/specs/2026-10-30-message-first-practice-design.md) and proposed P9 criteria before the next F10/F23 prototype iteration. This changes the review focus, not implementation status or default launch navigation. Review 07 does not yet implement this new entry route.

Follow-up: owner approved the short design; browser review 08 now demonstrates typed message-first entry and optional intent guidance, with partial P9 checks and [screenshots](../../Prototypes/CircleUVisualPrototype/PracticeFeedbackReview/README.md). 31 October: the native entry route now follows it (see F10 and P9); suggestions stay on-device or guided, so the "Review online" consent step is not built. Live feedback (F23) remains separate work.

1. **Refine (F23) and style (F24):** original wording, selected tone, useful concise feedback, editable rewrite and safe Use/Undo; distinguish manual work from optional online review. Validate the failure states against P7/P8/S9 before any native port.
2. **Today (F03–F07/F09):** preserve direct writing, draft resume and post-save reflection; refine hierarchy, Pingu art and copy using the current native layout.
3. **Journal (F08/F14/F15):** preserve calendar/search/editing; review activity icons and density without adding decoration to calendar cells.
4. **Conversation/history and Settings (F10–F12/F16/F20):** long reply threads, data controls and honest source/privacy labels.
5. **Beta qualification:** full guest unit/UI suites, physical accessibility/permissions, model capability/quality, legacy recovery and a deliberate Release configuration decision.

This is a review sequence, not permission to implement every proposed feature or activate cloud services.

## Checklist for every changed screen

- [ ] Brief updated first if purpose, scope or data handling changes; owner decisions and proposals labelled separately.
- [ ] M requirement, F flow and story criterion IDs linked in the task/change record.
- [ ] Happy path plus relevant empty, validation, loading/cancel, error, offline and stale states specified.
- [ ] Copy follows the content standard; existing branding/tokens reused; no duplicate primary actions.
- [ ] Keyboard, large text, VoiceOver and reduced motion requirements identified; actual checks labelled by environment.
- [ ] Prototype feedback recorded; retained native functionality explicitly accounted for.
- [ ] Authorised implementation and its tests linked; no invented passing tests or fixture-as-production claims.
- [ ] Flow status and dated agent log updated with evidence and a concrete remaining action.

## Release and research gates still open

[Practice review 08 session guide](../design/practice-usability-session-2026-10-30.md) is prepared for a small moderated batch: direct entry, optional guidance, Use/Copy/Save comprehension and same-session replies. Recruitment and participant sessions remain pending; browser fixtures cannot test real AI quality or durable history.

The owner confirmed poster and presentation slides only; no video is required and no deadline was supplied. Participant research and usefulness thresholds remain pending. Confirm audience age/language and the [device matrix](supported-devices.md). Preserve earlier users' data and finish the [transition plan](../superpowers/plans/2026-10-23-local-first-transition.md) gates. Figma, browser prototypes, guest Debug and standard Release are separate deliverables.
