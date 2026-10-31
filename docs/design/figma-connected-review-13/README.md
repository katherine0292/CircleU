# Connected Figma review 13

31 October 2026. Design review only; no native implementation or backend change.

[Open the prototype](https://www.figma.com/proto/rfknpmLIXsOxA7fHUQQMtR/CircleU-Design--from-Claude-canvas-?node-id=74-210&starting-point-node-id=74%3A3&scaling=scale-down&content-scaling=fixed) · [Editable page](https://www.figma.com/design/rfknpmLIXsOxA7fHUQQMtR/CircleU-Design--from-Claude-canvas-?node-id=74-2)

## Changes

- One page connects Today, Journal and Practice. Previous review pages are preserved.
- 32px illustrated chips sit inside 44px targets; 12px chip labels, 16px Journal excerpts, 17px entry detail and 24px screen headings. Plus Jakarta Sans is retained.
- All four invented Journal entries have their own saved words and optional activity/feeling tags. Picker selections are draft state until Done; close discards them. Compact labels stay on one line.
- Today’s successful save reveals the new entry. Its simulated failure does not perform the success state update.
- Existing Practice Prepare → Refine → Save → reply/context flow is retained. Reopening a saved conversation selects its saved scenario.
- The three-tab bars have matching y=764 and height=60 on 390×844 frames. Deep Practice screens retain Back navigation.

## Figma AI credit use

Used Figma **Add interactions** once on the three main frames and kept its result. The first attempt to select all frames was rejected before generation because Figma allows ten or fewer frames. AI connected part of the top-level navigation; manual work then restored internal branches and added state handling.

The account menu showed **2,980 credits left**, from a 3,000 monthly Education allowance, resetting 1 November. This corroborates **20 Figma AI credits used**, consistent with [Figma’s published cost](https://help.figma.com/hc/en-us/articles/33459875669015-How-Figma-AI-credits-work). See `figma-credit-balance.jpg`. No Weave credits were used.

## Verification performed

| Check | Result |
| --- | --- |
| Today prompt → invented wording → Save/loading → saved Journal | Passed; new entry appears only after success |
| Change tags then close | Passed; saved Calm remained |
| Done with activity + feeling | Passed; both illustrated chips appear |
| Remove final tag, then add two tags | Passed; Add tag appears when empty and disappears after saving tags |
| Edit existing walk entry → Save → Back | Passed; new words appear in Journal |
| Journal → Practice → Journal | Passed; edited words and saved tags remain |
| Practice → Prepare → online-review fixture → Refine → Use wording → Save → add reply/context | Passed in player |
| Leave and reopen conversation | Passed; reply/context remain in the selected scenario |
| Final link audit | 125 screen/state frames; zero external URLs or destinations outside the connected page |
| Target/layout audit | All compact chip targets 44px; every tab bar y=764 |

Evidence: `journal-default.png`, `journal-saved-tags.jpg`, `tag-picker-selected.jpg`, `conversation-reopened.jpg`. The screenshots use invented content. The player is set to Fit width and height so the whole phone and bottom navigation are visible.

## Boundaries and next review

This is a **bounded, clickable Figma Design prototype**. Text entry, voice transcription, AI feedback, copying and saving are invented scenarios, not live services. Variables retain state within the current player session and reset on reload/restart; they do not establish device storage, migration, native accessibility or account recovery. The four entry edits use predefined replacements. Practice history is one scenario, not an unlimited conversation store. Calendar/search and error branches were retained and structurally linked; not every branch was replayed in this turn. Native larger-text and VoiceOver validation remain separate work.

Review the visual density and tag hierarchy here before approving native changes. Future implementation must follow the product brief/user stories and run the relevant Swift unit/UI checks.

`source-map.json` records original-to-copy frame IDs. `state-map.json` records the created variables/components. The JavaScript files document construction and fixes; they are not idempotent and must not be blindly rerun against the completed page. No sources contain credentials or raw tool/chat dumps.
