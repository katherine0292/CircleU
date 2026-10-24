# CircleU MVP definition and user flow

Status: planning draft, 23 October 2026. Audience A, Today/Journal/Practice navigation, removing duplicated steps, deferring circles/rewards, and planning before coding are owner-approved. The latest 24 October decision reaffirms guest-first local storage with optional existing-account login; the intervening required-account proposal is superseded. Detailed interaction behavior and release gates remain proposals; this is not an approved implementation specification.

## Purpose and first use

CircleU helps university students and early-career adults process difficult everyday conversations, understand their feelings, and choose what to say or do next.

Proposed first-use promise: “Work through a difficult moment and find words that feel right to you.” The app should remain useful when someone only wants to write privately, without accepting an interpretation or taking an action.

Example: a student feels frustrated about a groupmate missing a deadline. They describe the situation, correct the app's interpretation, draft a clear request, and save it to revisit. Workplace feedback and setting a boundary are additional test scenarios, not separate feature suites.

## Decisions and proposed boundaries

| Item | Status | Consequence |
| --- | --- | --- |
| Students and early-career adults; reflection plus communication | Owner-approved | Prioritize real conversations over a general wellness dashboard |
| Circles later | Owner-approved | No social feed, invitations, posting or replies in the MVP journey |
| Today / Journal / Practice; rewards later | Owner-approved | Three main destinations, optional next steps inside entries, no separate rewards or quest dashboard |
| Research and planning before coding | Owner-approved | This milestone produces scope, research tasks and a prototype brief |
| Original native layout/proportions as the visual baseline | Owner-approved, 24 October | Refine colors, concise content and accepted branding assets using the existing composition; detailed integration remains separate. See the [reuse review](../design/original-layout-reuse.md) |
| Adults 18+, English, iPhone for the first study/beta | Proposed | Narrow recruitment and evaluation; do not infer that all university students are adults |
| Prototype validation, then a small private beta | Proposed | Test usefulness before investing in release infrastructure |
| Guest-first local use; optional existing-account login | Owner-approved, reaffirmed 24 October | Welcome offers Get started and Log in. No account required for local writing. Signup is deferred until a clear account benefit is specified; no new sync approval |
| No CircleU cloud AI or automatic CircleU backup in that initial beta | Owner-approved direction | Simplifies the initial data flow but limits model/device availability; needs a usable guided fallback |

The [privacy/storage and recovery plan](privacy-storage-plan.md) records the reaffirmed guest/local approach and specifies its retention, export, linked-deletion, backup and migration boundaries. “No cloud backup” here means no CircleU-managed backup/sync; OS device backups may still include user-created app data. The direction is approved, but not implemented. Explicit legacy-account recovery is still planned separately. Optional login must not trigger automatic import or imply that old and new identities/data are interchangeable. See the [account-onboarding brief](../design/account-onboarding.md).

The current app already has accounts, Firebase backup and circles. The proposed local experience does not exist just because its UI hides those features. The [transition plan](../superpowers/plans/2026-10-23-local-first-transition.md) defines network isolation, migration and existing-account recovery gates before making a local-only claim. Do not erase existing accounts or data as part of narrowing scope.

## MVP feature register

P0 means necessary for the proposed private beta, not necessarily a new feature to build from scratch. Existing capability must be verified and adapted where needed.

| ID | Priority / feature | Observable acceptance criteria |
| --- | --- | --- |
| M01 | P0 — Short introduction and privacy explanation | A first-time user understands the purpose, where their input goes and how to start. No account is required for local use. Welcome is concise; the data explanation is reachable before meaningful input, and earlier-account recovery remains optional. Microphone permission is requested only when chosen. |
| M02 | P0 — Describe a situation by text or voice | Text always works. Recording starts only after an explicit action and permission; stop is visible. The transcript is editable before reflection. Denied/unavailable speech offers text without losing the draft. |
| M03 | P0 — Review a grounded reflection | Separate the user's account from suggested interpretations. Offer a concise summary, tentative feeling/need and one useful question. Users can edit or reject interpretations and save without AI. Do not invent motives, diagnoses or verbatim quotes. |
| M04 | P0 — Practice what to say | Accept a situation, intended outcome and optional draft message. Offer up to three editable wording options with plain-language tone choices. Users can copy chosen wording; nothing is sent to another person. A reflection handoff previews the selected context and preserves its source link. |
| M05 | P0 — Choose an optional next step | The user can select, edit, postpone or skip one step. Saving a reflection must not automatically commit them to a quest. Completion is voluntary and reversible. |
| M06 | P0 — Save and revisit privately | Journal list, detail and basic text search make entries retrievable. Save once across repeated taps. Editing retains user changes. App relaunch restores saved entries and clearly identified drafts. Practice can be saved independently or linked to an entry. |
| M07 | P0 — Data control and reliable recovery states | Export and deletion cover reflections, practice and linked steps with explicit scope. Deleting an entry offers a clear choice for separately saved linked practice. App-managed sync/restore must not resurrect deleted records; restoring a historical OS backup can restore historical content and must be disclosed. Errors must not be presented as success. |
| M08 | P1 — Gentle follow-up | On a later visit, optionally ask how the conversation went. Allow dismiss or a short note. No mandatory streak, notification permission or reward loop. Can follow the first beta if capacity is tight. |

## Main user flow

1. **Welcome → local workspace → Today:** artwork-led Welcome offers Get started, with optional Log in for existing-account recovery. Local readiness, not authentication, gates the main experience. Today starts “Work through a moment” or “Practice a message.” Privacy/storage details remain reachable before meaningful input; drafts and previous data must be preserved.
2. **Describe:** type or record what happened. A small optional prompt asks what help they want: understand it, find words, or decide a next step. Avoid a long intake form.
3. **Review input:** typed text is reviewed and edited in the capture screen, without a duplicate review destination. Voice input retains a separate transcript review. Either route can save the original account without generated feedback.
4. **Reflect:** read and correct the suggested summary/interpretation. “Save reflection” completes a useful journey here. “Practice what to say” is optional.
5. **Practice, if chosen:** preview the situation being carried over; add a message draft and goal; review and edit wording. Copy is explicit. Save practice even if no wording is copied.
6. **Next step, if wanted:** choose a step, write a personal one or skip within the entry/result. Do not add a separate mandatory next-step screen.
7. **Saved detail / Journal:** saving opens the actual entry detail, with confirmation in context rather than a separate confirmation screen. Journal reopens that detail. Editing, export and deletion remain required; a later visit may offer optional follow-up.

Flow summary: Today → describe/edit typed input → reflection → saved entry detail. Voice adds a transcript check before reflection. The current Draft 02 optional branch starts from saved entry detail → Practice from this entry → review linked context → wording → entry with saved practice. Journal returns to the same saved entry rather than creating duplicate reflections.

### Edit behavior under review

- Reflection interpretation and original source text are distinct editing tasks. Saving a correction retains the original words and the exact accepted feeling/reflection. Saving only the user's words omits the generated interpretation.
- Save updates the current saved item; it must not create another entry on repeated taps. Discard leaves the previous saved version unchanged. Prototype editors use preset replacements; real input, validation and save-error recovery remain to be designed/tested.
- A standalone message remains standalone. A linked message keeps its source entry. Editing either linked reflection or message preserves the other; editing both in either order retains both changes.
- Copy is independent of Save and sends nothing. The edited message may be copied without saving; clipboard behavior is only simulated in Figma.
- Journal/Practice must reopen the actual latest saved version in the app. Draft 02 demonstrates this through matching scenario snapshots, not global persistence.
- Keeping a draft does not create a Journal entry. Discarding a draft must not erase saved history. Source-text changes after generation mark suggestions stale until reviewed/regenerated. Draft 02 now demonstrates a revised-source result and note-only save, each with matching history.

### Direct practice route

Today or Practice → situation and optional message → intended outcome/tone → editable suggestions → copy and/or save. No journal entry is required. Linking to a reflection is explicit; no silent import of other private entries. Multi-turn simulated conversations and screenshot interpretation are later features.

### Approved navigation

24 October 2026: the owner requested a cute calendar within Journal. The [calendar preview](../design/brand-demo/journal-calendar.md) explores date-based retrieval alongside Search, with saved-day and empty-day samples. This is an authorized visual prototype extension; runtime date filtering and interaction details remain proposals. It adds no streaks, rewards or new tab.

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

Use the existing Pingu identity, soft blue/lilac background, rounded typography and calm cards as a starting reference. These come from repository assets/screenshots. A [first Figma wireframe draft](../design/README.md) now exists; it is not an approved visual specification and records its typography substitution and incomplete states.

Proposed rules: one clear primary action per screen; plain labels; short editable suggestions; readable solid surfaces where transparency reduces contrast; support text scaling, VoiceOver, reduced motion and non-color-only state indicators. Check actual color contrast and layouts before freezing tokens. Keep supportive language adult and respectful; never reward disclosure volume or pressure a user to act.

Figma is connected to the owner's account and Draft 02 is available. Loading/cancel, representative validation/error states, linked-data controls and proposed data-policy onboarding are now present. The storage direction is now approved; participant feedback, unsupported-input limits and user-reviewed shared color/type/spacing/component definitions remain. Consolidating the two existing design systems follows this reference, rather than inventing a third.

## Explicitly later

- Circles, community feeds, invitations, social reactions and moderation workflows.
- Elaborate points, streaks, badges, trend dashboards and recurring reminder campaigns.
- Cross-device content sync/backup remains deferred. Optional account creation is deferred until a clear benefit and data contract are specified; existing-account recovery remains in scope.
- Image/screenshot understanding, live conversation recording, multi-turn AI roleplay and automatic message sending.
- Broad provider selection or a general-purpose AI chat companion.

Scope exclusion is not a security repair: existing deployed circle access and backup/deletion risks remain tracked in the repository review until addressed or safely retired in a separate plan.

## Validation and release gates

Before feature coding: review this scope and the transition plan, complete a first batch of discovery conversations, and test the main prototype. Storage direction is approved; implementation feasibility and legacy inventory remain open. See [research findings](research-findings.md) for prompts and scenarios.

Before a private beta: verify every P0 criterion on the supported device/OS matrix; exercise offline, permissions, fallback, export/deletion and existing-data migration; verify no unintended network transmission for the approved local-first direction. A working simulator build alone does not establish speech or AI availability on real devices.

Product signal: can people complete a real task, correct a poor suggestion, find useful wording and accurately describe where their information goes? Observe voluntary repeat use in a short pilot. Do not use generated confidence percentages, streak counts or positive interview reactions as evidence of product effectiveness.

Current prototype: CircleU — MVP Research & Prototype, MVP — Draft 02; see the design reference for links and remaining coverage. Open decisions: recruitment access; legacy recovery/distribution details; supported model/device/language validation; beta success thresholds. See the [device proposal](supported-devices.md); the owner suggested a latest-generation test phone but exact hardware is unverified. No implementation date is estimated until those choices and a build baseline are established.
