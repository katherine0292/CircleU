# Practice review 08 — usability session guide

Prepared 30 October 2026. Ready for moderated sessions; **no participant sessions or findings recorded**. Supports M04/M09, F10/F23 and P3/P5/P7/P8/P9. Use the [current prototype and evidence](../../Prototypes/CircleUVisualPrototype/PracticeFeedbackReview/README.md).

## Purpose and setup

Check whether someone can start preparing a message, find help when stuck, understand applying/copying/saving, and continue with a reply. This is a flow-comprehension study. Fixed responses cannot validate AI quality or whether suggestions fit arbitrary input.

Start with 3–5 adult students or early-career adults, ideally unfamiliar with the design. This is a practical first batch, not a representative sample or statistical validation. Aim for 20–25 minutes each. The owner arranges participants; no invitations or external sharing have been sent.

Use the prototype on the host Mac: `http://127.0.0.1:55988/PracticeFeedbackReview/`. A localhost link will not work on someone else's computer. Test in person on this Mac or use an owner-arranged screen-sharing session; record remote pointer coaching separately. This guide does not publish the prototype.

Before each participant:

- [ ] Confirm review 08 loads; select Project responsibilities and Feedback in the outer controls.
- [ ] Choose Start blank; keep normal text size unless the participant prefers larger text.
- [ ] Keep the outer fixture notice visible. Explain that the outer controls belong to the demonstration, not the app.
- [ ] Use invented text only; collect anonymous participant codes such as P01. Do not record names, private messages or recordings in Git.
- [ ] Record device/browser, prototype revision, date and moderator; distinguish browser testing from native iPhone testing.

## Opening script — about one minute

“We’re testing the design, not you. Please use the invented situations and say what you expect as you go. You can stop or skip anything. Suggestions are preset examples; this prototype doesn’t use AI, access accounts or upload your writing. Saving lasts only during this page session. I’ll take anonymous notes rather than record you. Is that okay?”

Explain that Copy uses the device clipboard if they choose it. Do not ask them to paste into a real chat or send anything. If they decline notes or participation, stop and keep no session record.

## Tasks — give one prompt at a time

Keep moderator setup and observation criteria private; read only the participant prompt. Do not name the intended buttons or demonstrate the route first.

| Task | Participant prompt | Moderator setup / what to observe |
| --- | --- | --- |
| A · Start with wording | “Your project teammate has left most of the work to you. You’ve drafted ‘You never help with our project.’ Use CircleU to prepare a clear request to divide the remaining work.” | Blank start; fixed Project responsibilities example. Can they enter wording and reach review without a required journal/account/context form? Do they understand that the suggestion is editable? |
| B · Choose and keep words | “Change the proposed message to words you would choose. Get the wording ready to paste elsewhere, and keep a copy in CircleU. Tell me what you believe each action did.” | Continue A. Observe edits, explicit application, Copy and Save separately. Do not tell them all three are necessary in a fixed order. Ask what would happen on returning later; record expectation, then explain the browser's temporary storage. Do not count actual persistence as tested. |
| C · Start without a draft | “You want the group to agree on who will finish each remaining task, but you don’t know how to begin. Find a way to get started.” | Moderator chooses Start blank between tasks and records that setup. Can they discover optional guidance, state their outcome, and distinguish Your intent from a message? Continue should not be mistaken for sending to a model or person. |
| D · Continue after a reply | “Your teammate replies, ‘I thought you wanted to handle the slides.’ You want to agree on who does each task. Prepare your next response.” | Continue C after they have usable wording. If C failed, load the invented fixture as moderator setup and mark D assisted setup. Let them enter the quoted reply. Observe intent, attribution and which reply/context they choose to include. This is same-session continuation, not saved-history retrieval. |

Alternate A/B-first and C-first across participants to reduce learning effects; B follows A, D follows a usable draft. Record actual order. A later success after seeing the same controls is not first-use discovery.

## Neutral prompts and assistance

Use “What are you looking for?”, “What do you expect that to do?” or “What would you do next?” Avoid “Did you see Help me get started?” or directing a tap. If someone remains stuck, ask whether they want help; record the exact hint and mark completion assisted. Distinguish moderator task resets from help navigating within a task.

At the selected-text confirmation ask: “What information do you expect to leave the device if you continue, and who would receive it in the intended app?” Record their interpretation before explaining. Then remind them the current prototype uploads nothing. Never count this as proof of a real provider's privacy behaviour.

## Closing questions — about three minutes

1. Which step felt unnecessary or repetitive?
2. What did you think applying, copying and saving each did?
3. What would you expect to find when you came back tomorrow?
4. Which part would you keep, and which would you remove?
5. In what situation, if any, would you choose this over what you do today?

Positive comments about Pingu or appearance are visual feedback, not evidence of useful wording or repeat use.

## Anonymous results template

Session code: ___ · Date: ___ · Moderator: ___ · Device/browser: ___
Prototype revision: ___ · Order: ___ · Prior familiarity: ___ · Notes agreed: ___

| Task | Outcome: unaided / assisted / not completed / not testable | First hesitation or wrong turn | Exact assistance | Observable evidence / short anonymous quote | Impact / suggested change |
| --- | --- | --- | --- | --- | --- |
| A | — | — | — | — | — |
| B | — | — | — | — | — |
| C | — | — | — | — | — |
| D | — | — | — | — | — |

Use/Copy/Save interpretation: ___
Intent versus wording interpretation: ___
Selected sharing interpretation: ___
Return-later expectation: ___
What they would remove: ___

Keep completed notes locally outside tracked files until anonymized. Put only synthesized, non-identifying observations and participant codes in project documentation. Do not manufacture results to fill this template.

## Decide what to change

- Any belief that CircleU sent a message, unexpected sharing, or apparent draft loss: investigate before expanding the feature set, even if only one participant encounters it.
- A repeated navigation or terminology problem: revise that step and retest it; prioritize observed obstruction over adding explanatory text everywhere.
- An isolated preference about decoration: record it and compare with other sessions before changing the brand.
- If the main tasks are understandable without coaching, plan a bounded SwiftUI implementation and native checks. This is a design decision, not a numerical pass/fail or beta-release gate.

Still required separately: real AI usefulness/intent preservation; native voice/permissions, keyboard/VoiceOver, saved-history retrieval after relaunch, offline and storage failures, actual transport/privacy and legacy recovery. Neither a screenshot nor this browser session can close those items.
