# CircleU discovery brief

Status: updated 23 October 2026. The owner selected audience A (reflection and communication for university students and early-career adults), approved Today/Journal/Practice navigation and removal of duplicated steps, deferred circles and rewards, and requested research/MVP planning before coding. Detailed scope and final visual design remain proposals.

Current planning documents: [MVP definition and user flow](mvp-definition.md) and [research findings and validation plan](research-findings.md). These supersede the provisional priorities below where they differ; existing product/code documentation still describes the broader implementation.

## Starting evidence

The [repository review](../project-review-2026-10-23.md) inventories current implementation and gaps. Existing code supports voice/text reflection, structured feedback, a journal, follow-up actions, communication practice, circles and progress. This implementation is evidence of capability, not evidence that users need every feature.

The owner's stated goal is to collect product, feature and design information before reorganizing or expanding the app. Figma is now verified as the owner's intended account. The owner had no existing prototype and requested a fresh start; the [first research wireframe draft](../design/README.md) now provides a proposed journey, not an approved design authority.

## Audience options considered

| Option | Suggested answer in the owner's words | Best-fit initial experience | Tradeoff |
| --- | --- | --- | --- |
| A — Reflection and communication | “CircleU helps university students and early-career adults process stressful everyday conversations, understand what they feel, and choose one constructive next step.” | Reflect on a real moment → review insight → rehearse wording → choose an action | Clear fit with existing practice features; usefulness must be tested with the intended audience |
| B — Everyday reflection | “CircleU helps busy adults who struggle to keep a journal capture their thoughts by voice, understand their day, and build a gentle reflection habit.” | Quick voice/text check-in → private journal → useful revisit | Simple first-use story; needs a convincing reason to choose it over established journals |
| C — Trusted support groups | “CircleU helps small groups of friends support one another through optional check-ins and encouragement while keeping personal journals private.” | Private reflection → deliberately selected share → support from known people | Makes circles central; requires invitation, access, moderation and group-activation work |

Decision: the owner selected A and deferred circles. An adults-only initial research cohort remains a proposal. The fit with existing practice features is a reason to investigate this direction, not evidence of market demand. B and C are retained here as alternatives considered, not parallel MVP goals.

## Initial comparative research

Sources accessed 23 October 2026. These are vendor descriptions, not independent usability or effectiveness studies.

| Reference | Documented behavior | Question for CircleU |
| --- | --- | --- |
| [Apple Journal](https://support.apple.com/en-ie/guide/iphone/iph9824e83ce/ios) | Writing, reflection prompts, journaling suggestions and quick actions including audio recording | What makes a person choose CircleU after they can already capture a journal entry easily? |
| [Day One privacy FAQ](https://dayoneapp.com/privacy-faqs/) | Describes end-to-end encrypted journals, device access safeguards and export options | What exact privacy promise can CircleU support, and can a user understand backup versus sharing versus AI processing? |
| [Finch approach](https://help.finchcare.com/hc/en-us/articles/37935669335309-Our-Approach-to-Self-Care) | Small goals, reminders, rewards and a companion are used to encourage routines | Does Pingu help people return and take a useful action, or mainly add decoration? |

Interpretation: capture, privacy and habit support already have established examples. CircleU's potential focus is the connection between a reflection and a concrete action or conversation. The research does not establish that this combination is unique or that people will adopt it.

## Provisional feature priorities

These priorities describe what to evaluate first, not permission to remove existing functionality.

| Priority | Candidate capability | User value to test | Acceptance evidence to collect |
| --- | --- | --- | --- |
| Core | Quick text/voice check-in with editable transcript | Capture a real moment without much effort | Participant creates a check-in and corrects transcription without assistance |
| Core | Grounded reflection with editable interpretation and clear fallback status | Help the user make sense of their own words | Participant can identify what the reflection is based on and correct an interpretation |
| Core | Private journal, search, export and reliable deletion | Keep ownership and control of personal history | Reopen/export/delete exercises behave as described, including restore |
| Core for A | One next action and communication rehearsal | Turn reflection into something usable | Participant chooses wording or an action they would use in their situation |
| Supporting | Simple progress and optional reminders | Support returning without pressure | A short pilot records actual repeat use and reasons for returning or stopping |
| Conditional | Account and backup | Preserve data when changing devices | Recovery, account switching and deletion tests pass |
| Deferred by owner | Small private circles | Get support from people the user trusts | Revisit after the private individual journey is validated |
| Later research | Richer rewards, deeper analytics, broader AI providers, public communities | Value is not yet established | Add only when a concrete user problem and support cost are understood |

For A, the first prototype should cover one complete situation: a difficult message or interaction, a brief reflection, a useful insight, suggested wording and a follow-up action. Keep the first research scenario small enough to test end to end.

## Research method

1. Use the selected audience A and test which everyday conversation situations most often motivate opening CircleU.
2. Conduct five initial discovery conversations with people in that audience. Five is a practical starting batch, not statistical validation. Ask about a recent real situation, what they did, what was difficult, what they already use and what they would keep private.
3. Record anonymized themes with evidence identifiers. Avoid collecting actual private journal entries or identifiable third-party messages; let participants use invented examples when useful.
4. Map the existing prototype to the feature inventory. Mark screens as current, aspirational, obsolete or unclear. Record file/node links and owner-approved decisions.
5. Test the main journey with a small first batch of participants. Observe completion, confusion, corrections, perceived usefulness and understanding of data sharing. Do not treat a positive reaction as proof of repeat use.
6. Produce a narrow release scope: must-have, later, excluded, acceptance criteria and unresolved risks. Then run a short beta to test repeat use.

Useful questions include: “Tell me about the last time this happened”; “What did you do next?”; “What was missing?”; “Which part would you keep private?”; and “What would make you stop using this?” Avoid pitching features before learning the person's current behavior.

## Design reference and information to collect

Figma is useful for the shared screen map, interaction prototype and component reference. Research and the feature register can proceed while the connection is corrected. Use repository docs for product decisions and acceptance criteria, and Figma for approved visuals/interactions; link them rather than maintaining two conflicting specifications.

Collect the design-file URL, prototype URL, file owner, approved version, page/node links, intended navigation, component variants and loading/empty/error/offline/permission-denied states. Compare the prototype against current screenshots and code before declaring it authoritative. Review text scaling, contrast, screen-reader labels and reduced motion.

## Open decisions

- Proposed next milestone: validate a prototype of the individual journey, then define a private beta.
- Guest-first local storage is now owner-approved. Resolve legacy TestFlight recovery and validate the [device scope](supported-devices.md) before implementation; see the [transition plan](../superpowers/plans/2026-10-23-local-first-transition.md).
- Which prototype/design version is authoritative.
- Feasibility of the approved on-device/manual direction and its model/speech fallbacks. CircleU cloud AI is already excluded from the proposed first guest-local beta; the remaining question is implementation capability, not permission for a silent cloud fallback.
- Who can participate in initial research and how they will be recruited. No outreach has been authorized or sent.
