# CircleU MVP definition and user flow

Updated 31 October 2026. Read the [product brief](overview.md) first. This register records approved direction and proposed detailed requirements; the [flow checklist](flow-status-checklist.md) owns delivery status and [user stories](user-stories.md) own acceptance/test coverage. Documentation or prototype approval does not approve a new native/cloud implementation or release.

Owner-approved direction: audience A; Today/Journal/Practice; circles/rewards later; original native proportions with new branding; guest-first local use with optional existing-account recovery; polished private beta first. Optional selected-text AI feedback and communication style are accepted for planning/prototyping. Their detailed native requirements remain proposed; live cloud activation is not approved. See the [Practice feedback design](../superpowers/specs/2026-10-27-practice-ai-feedback-design.md).

## Purpose and first use

CircleU helps university students and early-career adults process difficult everyday conversations, understand their feelings, and choose what to say or do next.

Proposed first-use promise: “Work through a difficult moment and find words that feel right to you.” The app should remain useful when someone only wants to write privately, without accepting an interpretation or taking an action.

Example: a student feels frustrated about a groupmate missing a deadline. They describe the situation, correct the app's interpretation, draft a clear request, and save it to revisit. Workplace feedback and setting a boundary are additional test scenarios, not separate feature suites.

## Decisions and proposed boundaries

| Item | Status | Consequence |
| --- | --- | --- |
| Students and early-career adults; reflection plus communication | Owner-approved | Prioritize real conversations over a general wellness dashboard |
| Circles later | Owner-approved | No social feed, invitations, posting or replies in the MVP journey |
| Future members-only student community | Owner-selected direction, 30 October; deferred | Wider experience sharing for students from any university; account required to read or participate; registration accepts any email, with no university-domain requirement or verified-student claim. See the [future Circles brief](overview.md#future-circles-direction--30-october). No change to guest core access or implementation approval |
| Today / Journal / Practice; rewards later | Owner-approved | Three main destinations, optional next steps inside entries, no separate rewards or quest dashboard |
| Research and planning before coding | Owner-approved | Update brief and acceptance criteria before each new implementation slice |
| Preparation-led demonstration; message first with optional guidance | Owner-approved, 30 October | Start with wording or voice; offer help for a blank start. No required reflection, profile or situation questionnaire. Detailed flow remains proposed in P9 |
| Original native layout/proportions as the visual baseline | Owner-approved, 24 October | Refine colors, concise content and accepted branding assets using the existing composition; detailed integration remains separate. See the [reuse review](../design/original-layout-reuse.md) |
| Adults 18+, English, iPhone for the first study/beta | Proposed | Narrow recruitment and evaluation; do not infer that all university students are adults |
| Polished private beta first | Owner-approved, 27 October | Validate the core experience; showcase artefacts do not establish beta readiness |
| Guest-first local use; optional existing-account login | Owner-approved, reaffirmed 24 October | Welcome offers Get started and Log in. No account required for local writing. Signup is deferred until a clear account benefit is specified; no new sync approval |
| Local core; no automatic CircleU backup | Owner-approved baseline | Retain manual/guided fallbacks. Optional online Practice feedback is a later planning amendment, not an enabled service |

The [privacy/storage and recovery plan](privacy-storage-plan.md) defines retention, export, linked deletion and migration boundaries. No CircleU-managed backup does not exclude OS device backups. A native guest implementation now exists behind the guest/review configuration; standard Release still follows the original account/Firebase app. Qualification of the complete transition remains open. Optional login must not cause automatic import or imply that old and new data are interchangeable. See [onboarding](../design/account-onboarding.md) and the [backend assessment](../engineering/competition-backend-readiness-2026-10-27.md).

Preserve legacy accounts and data. The [transition plan](../superpowers/plans/2026-10-23-local-first-transition.md) still gates network isolation, shipped-project mapping, migration and distribution. Source isolation tests do not establish all deployed/network behaviour.

## Native alignment approved — 31 October

The audit follow-up is approved for the guest review configuration: the accepted Today question picker and Journal cards/tags now have an implementation plan. Today questions guide writing without inserting or replacing words. Context (Study, Work, Friends, Family) and feeling (Calm, Worried, Overloaded, Happy, Sad, Frustrated) are independent, optional user choices. Existing entries keep nil tags; no feelings are inferred from wording or AI reflections. Tags persist locally, survive edits, appear in export/search and are removed with their entry. Cancel leaves tags unchanged; Done uses the entry revision and preserves choices after a failed save.

See [implementation and verification plan](../superpowers/plans/2026-10-31-audit-follow-up-native-alignment.md). The native guest/review slice is implemented with [bounded QA evidence](../qa/native-alignment-2026-10-31/README.md); this approval does not enable cloud services or change Release routing.

## MVP feature register

P0 means a baseline beta requirement, not a claim of completion. Existing capability must be verified and adapted where needed. P1 items can follow the first beta. Proposed extensions M09/M10 must not silently become release blockers before their scope is approved.

| ID | Priority / feature | Observable acceptance criteria |
| --- | --- | --- |
| M01 | P0 — Short introduction and privacy explanation | A first-time user understands the purpose, where their input goes and how to start. No account is required for local use. Welcome is concise; the data explanation is reachable before meaningful input, and earlier-account recovery remains optional. Microphone permission is requested only when chosen. |
| M02 | P0 — Describe a situation by text or voice | Text always works. Recording starts only after an explicit action and permission; stop is visible. The transcript is editable before reflection. Denied/unavailable speech offers text without losing the draft. |
| M03 | P0 — Review a grounded reflection | Separate the user's account from suggested interpretations. Offer a concise summary, tentative feeling/need and one useful question. Users can edit or reject interpretations and save without AI. Do not invent motives, diagnoses or verbatim quotes. |
| M04 | P0 — Practice what to say | Accept a situation, intended outcome and optional draft message. Retain the native tone-option baseline; the proposed M09 feedback replaces its presentation only after review. Wording stays editable with plain-language tone choices. Users can copy chosen wording; nothing is sent to another person. A reflection handoff previews the selected context and preserves its source link. |
| M05 | P0 — Choose an optional next step | The user can select, edit, postpone or skip one step. Saving a reflection must not automatically commit them to a quest. Completion is voluntary and reversible. |
| M06 | P0 — Save and revisit privately | Journal list, detail and basic text search make entries retrievable. Save once across repeated taps. Editing retains user changes. App relaunch restores saved entries and clearly identified drafts. Practice can be saved independently or linked to an entry. |
| M07 | P0 — Data control and reliable recovery states | Export and deletion cover reflections, practice and linked steps with explicit scope. Deleting an entry offers a clear choice for separately saved linked practice. App-managed sync/restore must not resurrect deleted records; restoring a historical OS backup can restore historical content and must be disclosed. Errors must not be presented as success. |
| M08 | P1 — Gentle follow-up | On a later visit, optionally ask how the conversation went. Allow dismiss or a short note. No mandatory streak, notification permission or reward loop. Can follow the first beta if capacity is tight. |
| M09 | Proposed extension — Practice feedback | Up to two grounded observations and one editable rewrite; preserve intent, boundaries and original words. Explicit Use/Undo, no auto-save/send, attributed actual replies, safe cancellation/stale-result handling and manual fallback. Optional online review shows the exact selected payload before each request. Stories P7/P8; no live provider implemented. |
| M10 | Proposed extension — Communication style | Optional self-selected English variety, wording style and length. Off initially, editable/clearable, explicitly selected per online request; no inferred demographics, background learning or journal rewriting. Native persistence/export/deletion details proposed in S9; browser preferences are volatile. |

## Main user flow

1. **Welcome → Get started → Today.** Optional Log in opens deliberate earlier-account recovery. Privacy details remain accessible; no account is required to write.
2. **Describe and save original words.** Type or explicitly choose speech. Review/edit before Save; failures keep the draft. Today dictation and Practice transcript review have different current interaction paths (T3 and P6); do not describe a separate Today review screen as implemented.
3. **Optional reflection after saving.** Review suggestions separately from the saved original, keep or reject them, and choose an optional next step. Saving original words is already a complete useful task.
4. **Optional Practice.** Start directly or explicitly carry context from an entry. Prepare → Refine → edit/Copy/Save. Save opens the actual conversation; Copy never sends or saves.
5. **Continue a conversation.** Add their actual reply and/or context as separately attributed turns. Preserve prior prepared wording and the source link; start the next wording draft empty. AI reply drafting without wording requires current-turn intent (proposed P7).
6. **Revisit in Journal/Practice.** Search or use the Journal calendar; reopen, edit and save the same item. Standalone conversations remain in Practice history.

### Edit and persistence rules

- Original text, accepted reflection and prepared messages are distinct. Changing one must not silently rewrite the others; mark old suggestions as based on earlier input.
- Save updates the same record with revision protection. Discard preserves the saved version; keeping a draft does not create a Journal entry. Copy is independent of Save.
- Current native criteria/tests exist for these behaviours (T1–T2, J4–J5, P1–P6). Refer to the story table for partial coverage and the flow register for outstanding device/release checks.
- Draft 02 Figma snapshots are historical prototype evidence, not global persistence. The newer browser feedback/style examples also do not implement storage or a real model.

### Direct practice route

30 October selected direction: Practice → type or speak wording → optional context/tone → review/edit wording → copy and/or save. Help me get started offers an optional intent-led route when there is no draft. This replaces the proposed situation-first entry sequence, not the current implementation. No journal entry is required. Linking to a reflection is explicit; no silent import of other private entries. Online review retains its selected-text confirmation. See the [short design](../superpowers/specs/2026-10-30-message-first-practice-design.md) and proposed P9 criteria. Multi-turn simulated conversations and screenshot interpretation remain later features.

### Approved navigation

The owner requested a cute Journal calendar on 24 October, without extra decorative icons in calendar cells. Native date retrieval now has J3/J6 criteria and test coverage. Keep it during visual refinement; locale/time-zone and device accessibility remain validation items. The [calendar preview](../design/brand-demo/journal-calendar.md) is historical design evidence, not the runtime status source.

Three tabs: **Today**, **Journal**, **Practice**. Today starts work and resumes drafts; Journal retrieves reflections/notes and linked practice; Practice owns standalone communication rehearsal and its history. Optional next steps are part of entries, not a competing quest feature. Place data controls and preferences in Settings. Keep Pingu as a gentle guide. Circles, rewards, points and badges are deferred.

## Screen states to include in the prototype

| State | Expected behavior |
| --- | --- |
| Empty journal / first visit | Show one relevant example and a start action, without fabricated history |
| Empty or very short input | Ask for optional context; do not fabricate a detailed interpretation |
| Microphone/speech denied or unavailable | Explain the affected capability and allow typing immediately |
| Recording interrupted or app backgrounded | Make recording state explicit; preserve available text and offer a safe resume/retry after device validation |
| AI unavailable, unsupported device or failed response | Keep the input; offer retry or clearly labeled guided prompts and save; never present templates as personalized AI analysis |
| Offline | Text capture, existing entries and local controls remain usable; identify any unavailable speech/model capability accurately |
| Close with unsaved changes | Offer keep draft, discard or continue; relaunch must not silently lose a retained draft |
| Repeated save / retry | One saved item per intentional save, with visible completion state |
| Edit after generation | Preserve the user's new text; mark old suggestions as based on an earlier version until regenerated |
| Delete / export error | Explain failure and retain an actionable state; never announce successful deletion prematurely |

## Design direction to validate

Use accepted modern Pingu illustrations, Plus Jakarta Sans and blue/ice brand resources while preserving original native proportions. Follow the [screen content guidelines](../design/screen-content-guidelines.md): concise headings, one primary action, purposeful icons and plain editable wording. Compact default text must still scale with Dynamic Type. Check VoiceOver, reduced motion, contrast and keyboard reachability.

Figma Draft 02 records earlier routes; it is not assumed to contain subsequent native/browser changes. The latest feedback prototype uses fixed examples; Today/Journal companion views omit capture/calendar features and cannot replace the native flows. Review against story IDs, not screenshot recency. Reuse existing tokens rather than creating another design system.

## Explicitly later

- Circles, community feeds, invitations, social reactions and moderation workflows.
- Elaborate points, streaks, badges, trend dashboards and recurring reminder campaigns.
- Cross-device content sync/backup remains deferred. Optional account creation is deferred until a clear benefit and data contract are specified; existing-account recovery remains in scope.
- Image/screenshot understanding, live conversation recording, multi-turn AI roleplay and automatic message sending.
- Broad provider selection or a general-purpose AI chat companion.

Scope exclusion is not a security repair: existing deployed circle access and backup/deletion risks remain tracked in the repository review until addressed or safely retired in a separate plan.

## Validation and release gates

Before each new implementation slice: reconcile the brief and story criteria, review the prototype and confirm the slice's scope. Discovery interviews, participant research and usefulness evaluation remain pending; prior authorised native work is not undone by that gate.

Before a private beta: verify every applicable P0 criterion on an agreed device/OS matrix; exercise offline use, permissions, model fallback, export/deletion and existing-data migration; verify the intended network boundary. Qualify the Release target separately from Debug/Guest Review. Any online AI requires the provider/privacy/budget gates in its design before activation. Simulator results do not establish physical speech, VoiceOver or on-device model availability.

Product signal: can people complete a task, correct a poor suggestion, find useful wording and accurately describe where information goes? Observe voluntary repeat use. Success thresholds and recruitment remain open; no fabricated confidence score or positive reaction substitutes for evidence.

Current evidence and next actions live in the [flow checklist](flow-status-checklist.md). The [device proposal](supported-devices.md) remains separate from actual device checks: the 27 October native Practice review records an iPhone 11 Pro Max voice check, not qualification of the full matrix. Legacy ownership/distribution, live model quality and beta readiness remain unresolved.
