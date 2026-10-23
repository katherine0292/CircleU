# CircleU research findings and validation plan

Status: desk research and source inspection, 23 October 2026. No participant interviews, usability sessions or retention study have been conducted. The owner chose audience A and deferred circles. Recommendations below are hypotheses to test.

## Desk research

Primary sources accessed 23 October 2026. Product pages describe vendor features; they do not independently demonstrate usefulness or privacy implementation quality.

| Source | Observed evidence | Inference for CircleU |
| --- | --- | --- |
| [Apple Journal guide](https://support.apple.com/en-ie/guide/iphone/iph9824e83ce/ios) | Supports writing, prompts/suggestions and audio capture | Capture alone is unlikely to explain CircleU's value; test the transition from a real moment to useful wording |
| [Day One privacy FAQ](https://dayoneapp.com/privacy-faqs/) | Describes journal encryption, access safeguards and export | Users may expect control and recovery. Explain CircleU's actual storage/processing separately; do not imply equivalent encryption |
| [Finch approach to self-care](https://help.finchcare.com/hc/en-us/articles/37935669335309-Our-Approach-to-Self-Care) | Combines small goals, a companion, reminders and rewards | Pingu could support return visits, but a large rewards system is not necessary to test the core conversation task |
| [Yoodli chat-based roleplays](https://support.yoodli.ai/en/articles/15862405-create-chat-based-roleplays) | Offers typed conversation practice and coaching feedback, aimed at workplace communication scenarios | Communication practice is an existing category, not a uniqueness claim. Test CircleU's narrower personal reflection-to-wording journey |
| [Microsoft Research: human–AI interaction](https://www.microsoft.com/en-us/research/project/guidelines-for-human-ai-interaction/) | Research-backed guidelines address initial use, regular use, AI errors and behavior over time | Prototype correction, rejection and failure recovery alongside successful suggestions; treat AI mistakes as normal interaction states |

Working hypothesis: people in the chosen audience may value a short private bridge between an uncomfortable interaction and a constructive response. The sources establish adjacent patterns, not demand, a market gap or improved wellbeing.

## Repository implications

See the [dated review](../project-review-2026-10-23.md) for the full inventory and release risks.

- `Circleu/App/RootView.swift` routes the recording flow to the Tips tab through `onViewTips`; that closure does not pass the source reflection. A later implementation review must trace the complete handoff and establish explicit context linkage, rather than assuming navigation provides it.
- `Circleu/Features/Reflection/ReflectionViewModel.swift` calls `questStore.addSuggestedQuest` when saving. The proposed MVP instead asks users to choose or skip a next step.
- `Circleu/Stores/TipsPracticeStore.swift` already supports message/situation/tone drafts and saved sessions. Its draft fields are in memory; relaunch recovery must be verified or added before making that promise.
- Existing text rewriting and screenshot presence should not be presented as image understanding or a live conversational model.
- Two design systems, mixed privacy wording, merge-only backup and swallowed deletion errors need explicit decisions before release. A smaller navigation surface does not fix those data paths.

## Research questions and decisions they inform

| Question | Evidence sought | Decision affected |
| --- | --- | --- |
| When does someone need help: immediately after a conversation, before sending a message, or much later? | Recent concrete examples and current alternatives | Default entry point and relative priority of reflection versus direct practice |
| What would they actually use from a suggestion? | Edits, chosen wording, rejections and reasons | Output format, tone controls and how much feedback to show |
| Does reflection add value before drafting? | Compare both routes within realistic tasks | Whether reflection should be suggested or remain entirely optional |
| What privacy/recovery tradeoff is acceptable? | Their explanation of storage and reaction to device-loss scenarios | Local-only beta versus account-backed recovery |
| Does recording help in their real setting? | Where/when they would record, discomfort and correction effort | Voice prominence versus a text-first design |
| Why would they return? | Actual follow-up behavior and unmet repeat needs | Follow-up prompts, reminders and later features |

## First interview batch

Propose five adults across university study and early-career work, with recent relevant experiences. This is a practical learning batch, not a representative sample. Recruitment channel and outreach need owner input; no messages have been sent.

Allow roughly 20–30 minutes. Begin with existing behavior rather than a product pitch:

1. Tell me about a recent everyday conversation you found difficult.
2. What did you do before or after it? What tools or people did you turn to?
3. What was hardest: understanding your reaction, finding words, or deciding what to do?
4. What worked or failed in the approach you used?
5. Where would you be comfortable typing or recording? What information would you leave out?
6. If these notes were on your phone, what would you expect to happen after replacing or losing it?

After the behavior questions, show the concept and ask what would make it useful or unnecessary. Do not request private screenshots or identifiable third-party messages; participants can invent an equivalent example. Recording research interviews is a separate explicit consent decision.

Record participant code, audience segment, scenario, current approach, observed difficulty, exact permitted quote, counterevidence and resulting product decision. Keep raw personal material outside the public repository. Save only anonymized findings approved for project documentation.

## Prototype tasks and synthetic test cases

These are invented scenarios for evaluation, not user findings.

| Scenario | Task / observation |
| --- | --- |
| Groupmate missed a deadline | Capture frustration, correct a feeling suggestion, create a clear request and save it |
| Manager gave vague feedback | Ask for clarification without inventing the manager's intentions |
| Friend asks for another favor | Draft a boundary in the user's own tone; allow rejection of every option |
| User wants only to write | Save an entry without practicing or choosing an action |
| Message is one vague sentence | Request context or give modest guidance, rather than a confident story |
| Microphone denied and no model available | Complete the task using text and guided prompts; identify the limitation |
| User edits, closes and returns | Resume a draft, retain corrections and avoid duplicate saves |
| User deletes a saved reflection | Understand treatment of linked practice and verify it does not reappear |

Observe unassisted completion, where users hesitate, whether they correct suggestions, whether any wording is usable, and whether they can explain data processing and deletion. Do not lead participants toward a preferred answer. Separate usability defects from lack of interest in the concept.

Proposed first-round criterion: no unresolved critical data-loss/privacy misunderstanding; most participants can complete the core task unaided and identify a useful result. Record individual outcomes instead of treating a percentage from five people as market validation. Rework the prototype if the reflection step adds friction without perceived value.

## Sequence and next outputs

1. Review the [MVP proposal](mvp-definition.md) and model fallback. Guest/local storage is now owner-approved; validate participant understanding of its recovery limits and complete the [transition inventory](../superpowers/plans/2026-10-23-local-first-transition.md).
2. Correct the Figma connection, verify the intended account, and inspect the owner's file or agree a new prototype destination.
3. Recruit and run the first interview batch; summarize evidence and counterevidence.
4. Prototype the core route and direct-practice alternative, including errors and permissions. Test, revise and freeze a narrow beta scope.
5. Write separate implementation plans for build/CI, data lifecycle, design consolidation and the core journey. Start product coding only after scope approval.
