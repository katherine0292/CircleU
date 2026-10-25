# Guest journal batches: QA record

25 October 2026. Each batch lists its local test run and the owner's phone check (CircleU Guest Test, iPhone 11 Pro Max).

| Batch | PR | Local suite | Simulator UI tests | Owner phone check |
| --- | --- | --- | --- | --- |
| Voice, three tabs, save while listening | #15 | 164 passed, 0 failed, 1 skipped | three entries with and without voice | Microphone works (Mike, 25 Oct). Three entries in a row: not yet confirmed. |
| Practice | #16 | 183 passed, 0 failed, 1 skipped | Practice end to end | Pending |
| A: suggestions, reflection review, next step | #18 | 199 passed, 0 failed, 1 skipped | suggestion flow, Practice options | **Owner-verified (Mike, 25 Oct): all three checks work.** This covers Get a suggestion → Save with reflection, Mark done / not done, and Practice Use this / Undo. |
| B: search, calendar, Settings, export, delete all, Practice drafts | this PR | see the PR | search, calendar, Practice draft across relaunch, export share sheet, delete all with relaunch | Pending |

What these checks don't cover:
- live Apple Intelligence (the phone has none, so it uses guided prompts);
- VoiceOver on a device;
- CI, which is manual by owner decision.
