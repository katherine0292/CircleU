# CircleU product brief

## Native alignment approved — 31 October audit follow-up

The owner approved implementing the accepted Today and Journal designs after the full-project audit, with parser repair and data preservation first. This supersedes the prototype-only restriction below **for this bounded native guest/review slice**: optional question guidance, date-grouped Journal cards, explicit context/feeling tags, matching Codex artwork and accessibility checks. Context and feeling remain independent optional choices, never inferred. Selection changes do not rewrite original words; Done saves tags, Cancel does not. V5 data migrates with tags unset. See the [approved plan](../superpowers/plans/2026-10-31-audit-follow-up-native-alignment.md), [MVP rules](mvp-definition.md#native-alignment-approved--31-october) and T8–T10/J7 [stories](user-stories.md).

Cloud AI, sync, signup, circles, production recovery and guest Release enablement remain outside this approval. Poster and slides remain the showcase deliverables; no video or deadline was added.


31 October owner acceptance: the compact Today composer and optional question sheet are the current approved prototype direction. Artwork can be refreshed frequently within that layout. Set up interchangeable existing Codex scene components (Window pause default, Reflection garden alternative, Voice corner for recording) at the same 2:1 dimensions. This is an editor workflow, not automatic rotation during writing or approval for native implementation.

31 October prompt-picker prototype: owner approved trying the quiet question control as a bottom-sheet picker. Offer “What happened?”, “How did it make you feel?” and “What would you like to say next?”. Selection displays the question above the writing area; changing/dismissing it preserves existing words. Keep one compact footer row, existing artwork and fixed navigation. Curated questions, no AI call; Figma-only approval.

31 October Today layout follow-up: owner rejected the stacked prompt-chip and separate voice rows in review 18. Refine the existing Figma composer to one compact bottom row: a single quiet prompt/status on the left and microphone/Stop on the right. Preserve existing artwork, writing, Save and tab positions. This supersedes the review-18 visible Speak pill; native accessibility labels remain required if implemented. Prototype-only refinement, no feature or backend expansion.

31 October Today visual correction: owner requested fuller reuse of existing artwork, a properly organised microphone, and refinement of the lower UI. Prototype scope: reuse the approved Window pause scene; group writing, short prompts and a centred, labelled voice control into one composer; retain the fixed Save and tab positions. Preserve capture/draft/reflection reactions and existing typography/palette. No new artwork generation or native implementation.

31 October Today follow-up: owner approved the next prototype pass covering capture, drafts, save/retry and optional reflection. Reuse existing Codex artwork and phone layout. Reflection must begin with the person's own input, remain separate from original words, and remain visible when the entry is reopened. Figma AI credits may support prototype work if useful; no native/cloud implementation is implied.

31 October next-step scope: complete a Journal prototype quality pass across search, calendar, entry tags, editing and return navigation. Correct misleading states and preserve unsaved edits before advancing to Today review. This is Figma verification/repair, not approval for native feature changes.

31 October artwork correction: owner chose Codex-generated artwork as the consistent brand source. Standalone icons must be PNGs with real transparency, without baked-in blue background squares. Replace the Figma-generated emotion portraits in the current prototype with matching Codex artwork; retain originals as historical review evidence. Reserve Figma AI credits for prototype assistance, not illustration generation. No native behavior change is authorised by this asset correction.

31 October Journal visual review follow-up: owner requested more emotion artwork and clearer separation from conversation context. Prototype exploration uses labelled Pingu face portraits for six manually chosen feelings (Calm, Worried, Overloaded, Happy, Sad, Frustrated), retaining Study/Work/Friends/Family as context tags. Group history by date and keep writing dominant. This is visual-prototype/asset work only; no inferred emotions, native schema change or automatic classification. The extra three feelings and their placement remain review candidates.

Updated 30 October 2026, Australia/Sydney. **Start here before proposing a feature or refining a screen.** This is the current product brief; detailed scope lives in the [MVP definition](mvp-definition.md), behaviour in [user stories](user-stories.md), and delivery evidence in the [flow checklist](flow-status-checklist.md). This update reconciles owner decisions and prototypes; it does not authorise new native/cloud implementation or release.

## Who and why

CircleU helps university students and early-career adults reflect on difficult everyday conversations and practise what to say. A person may feel frustrated, unsure how to express a boundary, or unable to find words that sound like them. They should be able to write privately, revisit the moment and prepare a message without being judged or forced to accept advice.

Product promise: **Work through a difficult moment and find words that feel right to you.**

The first product delivery target is a polished private beta. The immediate showcase deliverables are a poster and presentation slides. On 30 October the owner explicitly removed video and confirmed there is no deadline for this work. Print dimensions and presentation duration remain flexible. A showcase preview is not evidence that a feature is ready for beta distribution.

**30 October immediate priority:** the owner redirected work to brand presentation and showcase materials, postponing further feature/community planning. Keep the private beta as the subsequent product milestone. Reuse the accepted brand and existing work; focus the presentation on the preparation-led journey. Circles remains future scope, and its age-policy question is unanswered, not implicitly approved. See the [showcase focus](../superpowers/plans/2026-10-27-app-upgrade-roadmap.md#showcase-focus--owner-update-30-october).

## Core experience

30 October owner decision: lead the first demonstration with **preparing for a difficult conversation**, using **message first with optional guidance**. Start by typing or speaking; offer Help me get started when someone has no wording. Context and tone are optional refinements, not mandatory preliminary forms. Today and Journal remain independent routes; this decision does not change the default launch tab. The [short flow design](../superpowers/specs/2026-10-30-message-first-practice-design.md) records the approved prototype flow; browser review 08 demonstrates typed entry and optional guidance, with native integration still pending.

**Today → write or speak → save original words → optional reflection → Journal.**

**Practice → Prepare → Refine → optional Their reply/context → Refine → saved conversation.**

A saved journal entry may explicitly supply context to Practice. Direct Practice needs no journal entry. Voice must retain an editable transcript and a typing fallback. Copy, Save and sending are different: CircleU never sends a message to the other person. Prepared wording is not proof it was sent.

| Destination | User job | Requirements / story families | UI boundary |
| --- | --- | --- | --- |
| Welcome / recovery | Start locally or deliberately recover an earlier account | M01, M07; W1–W2, S5, S7–S8 | Guest-first; optional Log in. No mandatory signup or automatic import |
| Today | Begin or resume a reflection with little effort | M02–M03, M05; T1–T10 | Preserve the existing capture/draft flow. One clear action, useful empty state and optional prompts |
| Journal / entry | Find, read, edit and control saved moments | M06–M07; J1–J6 | Keep calendar, search, dates and original words. Optional Pingu activity labels; no extra mascots in calendar cells |
| Practice / Refine | Prepare, improve and continue wording while retaining intent | M04, M09; P1–P8 | Original and suggested words distinct; editable wording, selected tone, explicit Use/Undo/Save, attributed history |
| Settings / style | Understand data handling and choose optional preferences | M07, M10; S1–S9 | Manage privacy, exports/deletion, Pingu and communication style without adding a fourth main destination |

M01–M10 refer to the [feature register](mvp-definition.md#mvp-feature-register). Story IDs refer to [user stories](user-stories.md); newly proposed stories are labelled as such.

## Refine requirements

### Journal tag review — 31 October

Owner requested a visual prototype with smaller default typography and illustrated tags beneath journal entries. The approved review scope is one optional activity (Study, Work, Friends or Family) and one optional feeling (Calm, Worried or Overloaded), both explicitly chosen, changed or removed by the person. An activity never implies a feeling. Reuse existing Pingu artwork with short labels; leave calendar cells unchanged. Saving words remains independent of tagging. See proposed J7 in [user stories](user-stories.md). This authorises a Figma review only; native schema, persistence, export and migration remain unimplemented for this proposal.

Follow-up approved for connected review 13: reduce the visible tag to 32px with a 44px tap target and connect Today, Journal and Practice within one Figma page. Prototype state should retain explicitly saved tags and edits while navigating; Cancel must discard tag-picker changes. Existing approved Practice and reply states remain the baseline. Figma AI may assist with interactions using available credits; this does not authorise subscription purchases, Weave spending, native implementation or live model integration.

- Preserve the original Practice flow and existing native proportions. Improve content, branding and editing rather than introducing duplicate steps.
- Proposed feedback: at most two useful observations and one editable rewrite in the selected Soft/Balanced/Firm tone. Explain wording, not the user's personality. No score, diagnosis, guessed motives or fabricated facts/commitments.
- Visual refinement uses a shallow existing Pingu scene on the editor, quiet reading/writing cards, consistent outline controls and available space for the text field. Keep navigation/actions anchored and avoid decorative filler.
- Normal body-size wording, concise headings, small purposeful Pingu artwork and rounded icons. Keep accessibility scaling; a compact default is not a fixed font size.
- Let users compare originals, edit the proposed text directly and choose when to apply it. Applying does not save or send. Undo must not silently replace newer manual edits.
- Keep prepared wording, their actual reply and added context separately attributed. For a proposed AI-drafted reply without a draft, ask for current-turn intent; do not infer it from what the other person wants.
- When more context is needed, preserve the current task: clarifying a first message must not turn it into a reply or introduce a received-message example.
- Keep manual writing, saving and reading useful without a model or network. A failed/cancelled request never loses the draft; an old response never overwrites newer input.

## Optional communication style

The owner approved exploring and prototyping preferences that help suggestions sound like the person. First increment: self-selected English variety, conversational/formal wording and brief/balanced length, managed in Settings and optionally included in a Practice request. Conversation tone overrides a general preference where they conflict.

Preferences are optional, editable and clearable. They never rewrite saved journal entries, change activity/mood labels, or alter original words. No age, ethnicity, gender, personality or communication ability is inferred from writing, names or accents. No background learning from journals, recordings or pasted replies.

Later candidates—not in the first increment—are user-approved writing examples and “Sounds like me / Too formal” feedback. Accepting a suggestion once must not silently create a durable preference. The model is not being retrained in the current prototype.

## Privacy and access decisions

Guest-first local core use remains the baseline. Earlier-account recovery is deliberate and separate from current writing. Preserve old accounts, data, bundle/history and recovery paths; narrowing the new experience is not permission to delete legacy resources.

The owner accepted planning and prototyping **optional online AI for selected Practice text**. No new live provider, deployment, billing, cloud sync or automatic upload has been approved by that choice. Proposed online confirmation shows the exact selected text/context/preferences, with preference sharing unchecked each time; audio and the whole journal are excluded. Provider eligibility, retention, project ownership, budget and accurate privacy copy must be settled before activation. See the [AI design](../superpowers/specs/2026-10-27-practice-ai-feedback-design.md).

Adult-only (18+), English-first recruitment and the final device/OS matrix remain qualification decisions. University enrolment does not establish age. Current source/target settings and actual installed-device evidence must be distinguished from proposed scope.

## What exists and what remains

- **Native guest implementation exists** behind the guest/review configuration: local writing/storage, Journal retrieval, optional local/guided suggestions and Practice. Native conversation/voice work has specific working-tree evidence in the [27 October review](../qa/native-practice-2026-10-27/README.md).
- **Feedback and communication style are browser prototypes**, using invented fixed responses and volatile preferences. Their [review README](../../Prototypes/CircleUVisualPrototype/PracticeFeedbackReview/README.md) identifies what was exercised. Today/Journal specimens there illustrate connections only; they omit existing capture/calendar functionality and must not replace it by accident.
- **The original app still contains Firebase/account/cloud paths.** Standard Release/TestFlight is not established as the guest beta. Legacy project mapping, ownership/recovery and distribution remain separate gates; see the [backend assessment](../engineering/competition-backend-readiness-2026-10-27.md).
- Browser checks, Simulator tests, physical-device reports and released behaviour are separate evidence. No overall “complete” status or completion percentage is implied.

## Out of scope for this pass

Circles/community, rewards/streaks, automatic sending, simulated AI roleplay, screenshot interpretation, background recording, automatic personal-profile learning, journal-wide AI and cross-device sync. Existing code for these features remains a legacy/recovery concern, not new product scope.

## Future Circles direction — 30 October

Owner-selected purpose: a wider community sharing experiences, for university students from any university. Access is **members-only for reading and participation**, rather than guest-readable posts or a UTS-only community. This narrows the future community audience, not the audience of the private core app.

Owner-selected registration: **any email address**, with no university-email domain requirement. Circles is aimed at students but membership must not be labelled verified student status. Email ownership verification is a recommended account safeguard, not a selected implementation requirement or proof of enrolment; its flow remains to be designed.

Circles remains deferred from the current private beta. Guest-first Today, Journal and Practice remain unchanged; community membership would be a separate account requirement. This decision does not authorise enabling signup, changing Firebase rules, migrating legacy content or adding a navigation tab. Existing Circles code and data must be preserved while the future experience is designed.

Proposals, not yet selected implementation scope: curated topics (University life, Friendships and belonging, Difficult conversations), Pingu avatars/display names, optional university affiliation, experience posts, supportive replies and saved posts. Journal/Practice content should only be shared through a separate, explicit publish preview. Members-only must not be described as confidential: other members can copy content.

Before a community prototype becomes an implementation plan, resolve email ownership verification, any additional eligibility rules, age policy, moderation ownership and capacity, reporting/blocking, content deletion/retention, and the legacy access transition. An account alone does not verify student status. Detailed community stories and UI remain to be defined; no community implementation or security validation is claimed.

## Success and review rules

A useful beta lets people finish a task, retain their meaning, correct or reject a suggestion, find their saved work and explain what was shared. Review with invented examples first; actual participant research, repeat-use evidence and success thresholds remain pending. A polished screenshot or a successful microphone check does not demonstrate AI quality.

For every UI change:

1. Identify its M feature, story/criterion IDs and F flow in the linked documents.
2. Update this brief first if the user problem, scope or data boundary changes; record owner decisions separately from engineering proposals.
3. Add or revise Given/When/Then criteria and required failure/accessibility states before changing the screen.
4. Review the prototype against those criteria and record feedback and unresolved gaps.
5. Implement only the authorised slice, then attach native tests/device evidence before advancing its verification status.

Use the [screen content guidelines](../design/screen-content-guidelines.md) for copy and the accepted Pingu/Plus Jakarta Sans/blue brand resources. Keep existing feature folders and View → ViewModel → Store/Engine/Service boundaries. No wholesale MVVM rewrite or new design-token system.

The [flow checklist](flow-status-checklist.md) is the single delivery-status register. User stories own acceptance/test coverage; this brief owns product intent. When they disagree, reconcile the documents instead of treating the newest screenshot as the requirement.

## Legacy context

Earlier CircleU explored voice reflection, AI summaries, tips, progress, Firebase backup and circles. That broader source is retained for compatibility and recovery. The [backend plan](../engineering/firebase-backend-plan.md), [transition plan](../superpowers/plans/2026-10-23-local-first-transition.md) and Git history preserve that context; it does not define the new three-destination MVP.
