# Screen content guidelines (single source)

26 October 2026. Owner request (Mike): less on-screen text, one enforced guideline for every agent. Tightened the same day: supporting lines ≤ 60 characters, and icons over labels. This file **replaces** [content.md](content.md) as the content source and keeps its voice, terms and truthful-state rules. [AGENTS.md](../../AGENTS.md) requires it, and the test `GuestCopyLintTests` enforces the measurable parts for the guest journal.

## Per-screen rules

| Element | Rule |
| --- | --- |
| Heading | One per screen, **≤ 40 characters**, sentence case, no full stop. The navigation title may be the heading. |
| Supporting line | **At most one**, **≤ 60 characters**, in the secondary style (`GuestSummary`: subheadline, muted, Dynamic Type). |
| Primary action | **At most one** filled button per screen (screens that are lists or settings may have none). A destructive primary, such as Delete my account, is a red text button rather than a filled one. |
| Secondary actions | **At most two** plain or outlined buttons or links. Back, toolbar items, "Learn more", dismiss controls (Hide, Close) and prompt chips (which add a sentence starter to the person's words) don't count. |
| Detail | Only where honesty needs it, behind **Learn more** (`GuestLearnMore`, collapsed, footnote, Dynamic Type). At most four short sentences, each **≤ 120 characters**, marked `// copy: detail` when over 100. |
| Errors and warnings | One sentence saying what happened, plus the next step if there is one, **≤ 100 characters**. Never reveal whether an account exists. Never show success before it happened. |
| Any string on screen | **≤ 100 characters**, unless marked `// copy: detail` or `// copy: export` (export file text, not a screen). |
| Labels | Prefer an icon to a label (see "Icons over labels" below). |
| Section summary pattern | Heading with icon, then **one** `GuestSummary` line, then optional `GuestLearnMore` with the detail. Settings instead uses grouped icon rows, and its privacy detail is a sheet of one-line icon rows. |

## Icons over labels

Words are for the person's own writing and for what honesty needs. Everything else should be a picture first.

- **Use an icon instead of a label** for section headings ("My words", "Reflection", "Next step"), field labels, row metadata (source, status, counts) and secondary actions (Edit, Remove, Go to today, Close). Use the app's guest icons and Pingu art first, then SF Symbols.
- **Every icon-only control keeps its words for VoiceOver:** an `accessibilityLabel` with the wording the label used to have (so UI tests that find it by name keep working), and a 44 × 44 pt target.
- **Keep words** for the primary action (icon plus a short word is fine), for anything destructive (Delete stays a word), and wherever an icon alone could mislead: privacy promises ("Not uploaded or synced"), local versus cloud deletion, and the source of a reflection.
- **Rarely used actions** go in a ••• menu rather than a row of text links.
- **Empty states** are Pingu art with at most one short line.

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
| Welcome (3 pages, full-bleed Pingu scene) | Something on your mind? · Write or talk it through · Find your words | A private place for the moments that stay with you. · Kept on this iPhone. Not uploaded or synced. · Practise what you want to say, when you’re ready. | Next (round arrow, pages 1–2); Get started (page 3) | Skip (pages 1–2); Log in (page 3) | — |
| Today (capture) | What’s on your mind? | Type, or tap the microphone and talk. (hidden while typing) | Save | Question chips when empty (“Not sure where to start?”, prompts, not actions), or the “Need a nudge?” bubble while writing (Add to my words; Another question; Hide is a dismiss control); microphone (control); avatar and Settings in the toolbar | — (guided prompts: only a sentence starter is added, never the question) |
| Reflection review (after saving) | Reflection (title) / A suggestion | Source label | Save reflection (off when nothing is kept) | Back | — |
| Journal | Journal | — (empty: Pingu + "Nothing saved yet."; after saving: “Saved to your journal” card, “Want a short reflection on it?”) | Reflect on it (in the card, after saving) | Not now (in the card); Calendar | — |
| Entry | Entry | — | — | Edit; Practice what to say | — |
| Practice | Practice | — (empty: Pingu + "Nothing practised yet.") | Practice a message (blue card with Pingu) | Continue your draft (card with a one-line preview); saved messages are bubbles with a journal icon and date, no header | — |
| Practice message | What would you like to say? | Tag (journal icon + From: … / On its own) | Save, or Copy when saved | Situation and Goal "+" chips (open a field); Copy icon in the bubble; Get a suggestion (tinted Pingu bubble); outlined Use this on each suggestion card. Saved: Edit (pencil) and ••• → Delete message in the toolbar | — ("Copied. Not saved or sent." shows after copying, "Copied. Not sent." once saved, replacing the always-on line; pending Mike's OK) |
| Settings | Settings (title) | — (your Pingu with a pencil badge and "Your Pingu" caption; "Kept on this iPhone" chip with "Not uploaded or synced." under it; icon rows grouped under "Your data" and "Earlier CircleU account"; version footer) | — | Rows: Export my data; Delete all data (red); Bring in your earlier journal; Delete my account (red) | — (the chip opens the privacy sheet) |
| Settings → Kept on this iPhone (sheet) | Kept on this iPhone | Not uploaded or synced. | — | Done (dismiss) | — (four icon rows replace Learn more: dictation, backups, restore, exports) |
| Settings → Export done | (banner) Export done. | — | — | — | — |
| Settings → Delete all data? (alert) | Delete all data? | Deletes this journal and drafts. The earlier app stays. | Delete all (red) | Cancel | — |
| Log in | Bring in your earlier journal | — (chips: Nothing uploaded; Signed out after) | Log in | Forgot password?; Continue without logging in (Welcome only) | (i) “What logging in does”: what it fetches; no new accounts; why on-phone data stays sealed |
| Backup preview | Your account’s backup | — (chips: N to copy; N already copied) | Copy into this journal | Don’t copy | (i) “What isn’t copied”: not changed; what isn’t copied. Left out (N), when something was |
| Copied | Copied N items (with Pingu) | — (chip: Signed out; or “Signing out didn’t finish…”) | Continue (Welcome only) | — | Left out (N) |
| Reset password | Reset password (envelope art) | — / If an account uses this email, a link is on its way. | Send reset link | — | — |
| Delete my account | Delete my account | — (two cards: Will be deleted: account, cloud backup, posts, memberships; Stays: entries on this iPhone) | Delete my account | — | Circles kept; replies and likes |

## Enforcement

- **Test:** `CircleuTests/GuestCopyLintTests.swift` reads every Swift file under the guest journal's feature and service folders, recursively. It fails on banned wording (whole words) and on any multi-word string literal over 100 characters (120 when marked `// copy: detail`). It runs on the Simulator or CI host from the checkout, and skips where the sources aren't reachable, such as on a device.
- **Not checked automatically:** heading (≤ 40) and supporting-line (≤ 60) limits, icons over labels, the number of actions, and the displayed length of interpolated or combined messages. These are checked in review against the table above. Messages shown together (for example a failure plus "Signing out didn't finish") must each fit on their own.
- **Review:** before accepting copy, read the screen at normal and larger text sizes: one purpose, one primary action, nothing duplicated, no placeholder repeating a label.
