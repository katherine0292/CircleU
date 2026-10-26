# Practice with fewer words: picture start card, message bubbles, folded details

- Recorded: 2026-10-26 16:00:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer), cloud session; tests and review on Mike's Mac
- Status: in review; not yet tested on the Simulator or a phone
- Base revision and branch: `codex/practice-visual` from `main` at `73b2d81`
- Related record / task / PR: Mike: "our app is full of text now"; canvas row "P · Practice with fewer words" (boards PR1–PR5)

## Work and outcome

- **Practice home (P2.4):** "Practice a message" is a blue card with Pingu practising. "Continue your draft" is a dashed card with a one-line preview. Saved messages are sent-style bubbles with a journal icon (when from an entry) and the date; the "Saved messages" header, the From/On its own line and the time are gone (the tag stays as a VoiceOver hint). Empty: large Pingu, "Nothing practised yet." and the button.
- **Practice message (P2.5, P3.1):** Situation and Goal start as "+" chips and open into an icon-led field (open already when a restored draft has them). The wording sits in a bubble with a Copy icon in its corner (VoiceOver "Copy"/"Copied"). "Copying won't save or send it." is replaced by "Copied. Not saved or sent." after copying, pending Mike's OK on the canvas.
- **Suggestions (P4.2):** Pingu thoughtful with a "Get a suggestion" bubble; options are swipeable tone cards with "Use this". The source label stays (honesty).
- **Saved message (P3.4):** words in a blue sent bubble with Pingu thumbs-up and "Saved · not sent"; Copy is the one button; Edit is a toolbar pencil and Delete message is in the ••• menu (still confirms).
- **Docs:** stories P2.4, P2.5, P3.4 added; P3.1 and P4.2 updated. Guideline rows for Practice and Practice message updated.
- **Tests:** UI tests tap "Add situation" before typing a situation, check the copy line, the toolbar Edit, and Delete in the ••• menu.
