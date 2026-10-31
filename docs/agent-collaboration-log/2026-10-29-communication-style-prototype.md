# Communication style and companion screens

- Recorded: 29 October 2026, Australia/Sydney (work began in the preceding evening)
- Agent: Codex `/root`
- Status: browser design prototype only
- Prior: [Refine focus](2026-10-28-refine-prototype-focus.md)

Owner accepted setting up communication-style personalisation and asked about other screens. Extended the authorised prototype with optional Settings preferences, per-request inclusion and connected Today/Journal/detail routes. Reused existing brand resources. No native Swift, model, Firebase, account or real-user storage changes; no commit/push. Existing dirty work preserved. No additional agents or exchanges.

Files: PracticeFeedbackReview index, feedback script/styles, new style-profile.js, README and three versioned screenshots. Full scope/limitations and verification are in the [review README](../../Prototypes/CircleUVisualPrototype/PracticeFeedbackReview/README.md).

Decision: explicit preferences first; no demographic inference, background learning or implicit uploads. Preference use is off initially, sharing is unchecked per request, and clearing is available. Profile remains in volatile browser memory. Formal/brief changes select canned examples; language variety is a previewed parameter without distinct spelling fixtures. No claim of a trained or learning model. Sounds like me feedback and approved-example memory deferred to a later designed/authorised increment.

Browser verification observed save, summary, unchecked sharing, exact included values, changed formal fixture, unchanged original Journal text after use, and clear. Today and Journal are companion specimens illustrating navigation; native layouts, the calendar and full capture/edit flows remain authoritative elsewhere. The Screen selector initially failed a Playwright label lookup; AX selection worked, and an explicit aria-label was added and successfully retested. Final screenshots visually inspected. Syntax/resource/whitespace checks passed; no Xcode, physical-device or real-model tests. Remaining native integration and provider decisions unassigned.
