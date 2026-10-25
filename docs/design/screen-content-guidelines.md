# Screen content guidelines (single source)

26 October 2026. Owner request (Mike): less on-screen text, one enforced guideline for every agent. This file **replaces** [content.md](content.md) as the content source and keeps its voice, terms and truthful-state rules. [AGENTS.md](../../AGENTS.md) requires it, and the test `GuestCopyLintTests` enforces the measurable parts for the guest journal.

## Per-screen rules

| Element | Rule |
| --- | --- |
| Heading | One per screen, **≤ 40 characters**, sentence case, no full stop. The navigation title may be the heading. |
| Supporting line | **At most one**, **≤ 90 characters**, in the secondary style (`GuestSummary`: subheadline, muted, Dynamic Type). |
| Primary action | **At most one** filled button per screen (screens that are lists or settings may have none). A destructive primary, such as Delete my account, is a red text button rather than a filled one. |
| Secondary actions | **At most two** plain or outlined buttons or links. Back, toolbar items and "Learn more" don't count. |
| Detail | Only where honesty needs it, behind **Learn more** (`GuestLearnMore`, collapsed, footnote, Dynamic Type). At most four short sentences, each **≤ 120 characters**, marked `// copy: detail` when over 100. |
| Errors and warnings | One sentence saying what happened, plus the next step if there is one, **≤ 100 characters**. Never reveal whether an account exists. Never show success before it happened. |
| Any string on screen | **≤ 100 characters**, unless marked `// copy: detail` or `// copy: export` (export file text, not a screen). |
| Section summary pattern (Settings, Privacy) | Heading with icon, then **one** `GuestSummary` line, then optional `GuestLearnMore` with the detail. |

## Voice and wording

- Plain, warm and brief, for adults working through difficult conversations. No motivational filler, praise, pressure or exclamation marks. Sentence case. Australian English in prose ("practise" as a verb), with the approved "Practice" destination name.
- **Banned:** "AI analysis" or any claim of analysing the person, "diagnose" or "diagnosis", "Demo", "Sample", "lorem", and placeholder or debug wording. Templates are labelled "Guided prompts, not a personal analysis"; on-device model output is labelled as such.
- **Shared terms:**
  - Today, Journal and Practice.
  - Reflection (separate from the person's own words).
  - Save and Copy are separate actions; copying never saves or sends.
  - Log in and Sign out for accounts. Don't mix in "Login" or "Sign in".
  - "Bring in your earlier journal" for recovery.
- **Truthful state:**
  - "Saved", "Copied" and "Deleted" are shown only after the operation succeeded.
  - Local deletion, account deletion and cloud deletion are told apart.
  - Nothing implies sync, upload or automatic restore.

## Guest screens

The supporting line is the single line under the heading; "—" means none.

| Screen | Heading | Supporting line | Primary | Secondary (≤ 2) | Learn more |
| --- | --- | --- | --- | --- | --- |
| Welcome | CircleU | A private place to work through a moment and find your words. | Get started | Log in | — |
| Today (capture) | What’s on your mind? | Type, or tap the microphone and talk. | Save only my words | Get a suggestion; microphone (control); avatar and Settings in the toolbar | — |
| Reflection review | Reflection (title) / A suggestion | Source label | Save with reflection, or Save only my words when nothing is kept | Save only my words | — |
| Journal | Journal | — (empty: Pingu + "Nothing saved yet.") | — (list) | Calendar | — |
| Entry | Entry | — | — | Edit; Practice what to say | — |
| Practice | Practice | — (empty: Pingu + "Nothing practised yet.") | Practice a message | Continue your draft | — |
| Practice message | What would you like to say? | Tag (From: … / On its own) | Save, or Copy when saved | Copy, or Edit when saved | — ("Copying won’t save or send it." stays: approved) |
| Settings → Your Pingu | Your Pingu | Tap to change. | — | — | — |
| Settings → Privacy and data | Privacy and data | Kept on this iPhone. Not uploaded or synced. | — | — | Backups, restore, exports, dictation |
| Settings → Your data | Your data | A text file you can save or share. (above Export) | — | Export my data; Delete all data | — |
| Settings → Earlier CircleU account | Earlier CircleU account | Bring in your journal from an earlier account. | — | Log in to bring in your journal; Delete my account | — |
| Log in | Bring in your earlier journal | Nothing new is uploaded, and you’re signed out after. | Log in | Forgot password?; Continue without logging in (Welcome only) | What logging in does; no new accounts; why on-phone data stays sealed |
| Backup preview | Your account’s backup | N to copy · N already copied | Copy into this journal | Don’t copy | Not changed; what isn’t copied; what was left out |
| Copied | (banner) Copied N items into your journal. | You’re signed out. | Continue (Welcome only) | — | Left out (N) |
| Reset password | Reset password | We’ll email you a reset link. / If an account uses this email, a link is on its way. | Send reset link | — | — |
| Delete my account | Delete my account | Deletes your earlier account and its cloud data. Entries on this iPhone stay. | Delete my account | — | What's deleted; circles kept; replies and likes |

## Enforcement

- **Test:** `CircleuTests/GuestCopyLintTests.swift` reads every Swift file under the guest journal's feature and service folders, recursively. It fails on banned wording (whole words) and on any multi-word string literal over 100 characters (120 when marked `// copy: detail`). It runs on the Simulator or CI host from the checkout, and skips where the sources aren't reachable, such as on a device.
- **Not checked automatically:** heading (≤ 40) and supporting-line (≤ 90) limits, the number of actions, and the displayed length of interpolated or combined messages. These are checked in review against the table above. Messages shown together (for example a failure plus "Signing out didn't finish") must each fit on their own.
- **Review:** before accepting copy, read the screen at normal and larger text sizes: one purpose, one primary action, nothing duplicated, no placeholder repeating a label.
