# Moments, Talk and the step-by-step guide

- Recorded: 2026-11-06 21:00:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (desktop app, Katherine's Mac), usability review and implementation
- Status: completed
- Base revision and branch: `codex/otter-artwork`, after `3b73a33` (merged to `main` in PR #4)
- Related record: [warm glass entry](2026-11-06-180000-claude-warm-glass-ui.md); artifacts 「Practice 可用性评审」, 「CircleU 功能串联方案」, 「Practice 对话原型」 and 「CircleU 完整流程原型」 (6 November)

## Request and scope

Katherine found Practice hard to follow. She asked for:
- a heuristic usability review, then one covering how the features connect;
- an explanation of why Tuan replaced Live Coach;
- clickable prototypes.

After trying the prototypes she approved the direction and asked for it in the app, keeping the existing design and motion. Later rounds asked for:
- a step-by-step guide across the whole app;
- a living otter;
- "How did it go?" with a feeling only;
- an Earlier conversations heading;
- Relationship as a context;
- Back after reflecting returning to the moment.

She then removed the Get started glow, all blinking and the breathing avatar, and asked for one final full test run and many small commits in her name.

New feature approval: Katherine approved reading the other person's reply ("two possible readings, you choose") and the Talk thread after reviewing both prototypes. Everything stays on this iPhone: Apple Intelligence where available, otherwise guided templates. No cloud AI, sync or sending was added.

## Work and outcome

- **Tabs:** Write · Journal · Talk (renamed from Today · Journal · Practice).
- **Moments:** an entry's page is a timeline: what happened (words and tags), reflection, conversation, and how did it go.
  - Its one main action is the next stop.
  - The action hides while typing.
  - Context and feeling chips open the tag picker.
  - The Journal card says "How did it go?" until it's written.
- **Talk** (`GuestTalkScreens.swift`) replaces the staged Practice pages with one thread:
  - a scene card first (scene art, tone, optional situation and hope, the person's avatar), filled in from a moment and never guessing tone;
  - suggestions in Soft, Balanced or Firm, each as is, shorter, warmer or more direct, all from one request;
  - ↻ adds a page (‹ › keeps every take);
  - Copy, then I said it (copied or not);
  - stop and retry, and a note in •••;
  - editing an earlier message starts again from there and keeps the earlier branch;
  - their reply gets two possible readings (or Neither fits), then reply ideas.
- **Engine:** a new `replyOptions` gives Apple Intelligence its own reply prompt, so its ideas answer the actual reply. Guided mode uses per-reading templates.
- **Saved data:** Talk saves in the existing conversation format (said wording, their reply and context as attributed turns), so earlier Practice messages open as threads. A new turn kind, `outcome`, holds "How it went" with an optional feeling; older saves decode unchanged.
- **Bridges:**
  - Reflection offers "Save and prepare what to say". From the Saved card this opens the moment, then Talk on top, so Back lands on the timeline.
  - Talk lists up to three moments with a context under From your journal, then Earlier conversations.
- **Relationship** is a fifth journal context (art already existed). It matches Talk's scenes.
- **Guide** (`GuestTour.swift`): the ? on Write starts a 13-step tour across the three tabs.
  - Each step lights one control or area and dims the rest; the tab bar's frame is read from the window.
  - An otter changes pose per step, breathes and hops, and a paw points at the lit area.
- **Living otter** (`GuestAlive.swift`):
  - Write's scene drifts slowly; standing otters in the guide, Talk and Saved card breathe.
  - Welcome page 1 says "Hi, I’m Tuanwei!".
  - Talk's empty page waves.
  - Every motion is still with Reduce Motion.
  - Eye positions found in each image are kept only to place speech bubbles. Blinking (drawn eyelids) was tried and removed at Katherine's request, as was the Get started glow and the breathing Settings avatar.
- **Motion and controls:**
  - said suggestions morph into the You said bubble;
  - timeline rails grow;
  - the reading not chosen fades;
  - haptics on Copy and readings;
  - "How did it go?" saves with a feeling alone, and Save sits beside the field so the keyboard can't cover it.
- **Animation brief:** written for Katherine to make video loops of the 8 scenes and 3 Welcome pages (tail, paws, expressions). It is on her Desktop (`CircleU动效需求_场景图与欢迎页.md`), outside the repo. Page turns and paw motion need those frames; nothing in the app fakes them.
- **Tests and docs:**
  - Staged-Practice UI tests (`GuestPracticeUITests`, `GuestPracticeMessageFirstUITests`) replaced by `GuestTalkUITests`.
  - Other UI tests moved to the new tab names and Talk helpers.
  - New unit tests in `GuestTalkTests`.
  - User stories J8, TK1–TK7, G1 and W3 added; old references point to the replacements.

## Verification

- Final run (`xcodebuild test`, iPhone 17 Pro Simulator, iOS 26.5, separate derived data, `CODE_SIGNING_ALLOWED=NO`):
  - unit (scheme Circleu): 311 tests, 310 passed, 0 failed, 1 skipped (physical-device data protection);
  - UI (scheme CircleuUITests): 28 tests, 24 passed, 3 failed, 1 skipped. `GuestTalkUITests.testEditBranchesAndAnEarlierBranchComesBack` failed once on a cursor-position assumption in the test; after the fix it passed on its own.
- The three UI failures are the known ones:
  - `GuestVoiceTabsUITests.testTabsPracticeAndDictationDenied` (no Simulator speech);
  - `GuestFindControlUITests` line 49 and `GuestStatesUITests` line 133 (calendar labels under the Chinese Simulator locale).
- Temporary walkthrough tests captured screenshots of the new flow, the guide and Welcome. They were deleted before commit.
- Apple Intelligence was available in this Simulator. Its suggestions were seen; not judged for quality.
- Not checked:
  - a physical iPhone, VoiceOver end to end, iOS 17/18 fallbacks, Reduce Transparency;
  - the largest text size on the timeline.

## Discussion and decisions

- Tuan's design notes rule out guessing motives as fact. Readings are offered as two guesses the person chooses between, which keeps that rule while meeting Katherine's request.
- The Practice name changed to Talk because the feature now runs during a real conversation, not only before it.

## Handoff

- Owner: Katherine
- Remaining:
  - video loops from the animation brief (then wire them in, with a still fallback);
  - the calendar UI tests' locale dependence;
  - dark mode;
  - some background copy still says "practice".
