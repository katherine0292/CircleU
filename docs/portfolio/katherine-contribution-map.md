# Katherine (katherine0292): contribution map

Compiled 5 November 2026 from this repository's full Git history (547 commits, all authors), `git blame` on `main` at `e8abbfc`, and the agent collaboration log. It records what the history shows and what it can't show.

## Summary

| Measure | Value |
| --- | --- |
| Commits authored as `katherine0292` | 25 (23 code commits, 2 PR merges), 9–11 June 2026 |
| Of those, co-written with Claude Code | 10 (Claude Opus 4.6 / Sonnet 4.6 `Co-Authored-By` trailers) |
| Lines added in those commits | about 6,250 |
| Swift lines still on `main` attributed to her | 5,526 of 37,949 (about 15%), plus the 108-line privacy manifest and two config templates |
| Commits authored as `Claude` | 21, all on 26 October 2026; **not attributable to her from the history** (see below) |

## Her commits by theme

### 1. Visual language: "liquid frosted glass" (9 June)

| Commit | What it did |
| --- | --- |
| `5d09312` | Converted the app shell to liquid frosted glass (merged as PR #2) |
| `dfe5111` | Fixed the aurora background width, added a bottom scrim, glass Home cards |
| `810dd19` | Converted the cards on all 15 feature screens to frosted glass (PR #3) |
| `3316d79` | 1:1 replication of the demo UI for Home, Journal, Reflection and Tips; created `Circleu/Design/PinguGlassKit.swift` (486 lines still on `main`: `PinguAurora`, `GlassSurface`, `GlassCard`, `GlassPill`, `PinguGlassButton`) |

### 2. Live Coach (AI communication practice) interaction (10 June)

| Commit | What it did |
| --- | --- |
| `5823971` | Redesigned `TipsLiveCoachView` to match the demo (347 lines still hers) |
| `41e8f5f` | Hid the tab bar during coaching, right-aligned replies, scene emoji, dashed "add" chip |
| `3487acf` | Copy-to-clipboard feedback; removed the clock icon from nav bars |
| `7ea035c` | Divider order, composer position and transparency |
| `2c263e3` (part) | Split the coach's suggested **reply** from its **context** in `CommunicationCoachEngine` |
| `a43da50` | Tap outside to dismiss the keyboard in Tips setup |
| `a54edfb` | Pingu mascot icons for the scene chips |

### 3. Circles (community) and Profile (10–11 June)

| Commit | What it did |
| --- | --- |
| `5db0a15` | Rewrote Circle as a community feed to match the demo |
| `c5e98ab` | Rewrote Profile to the demo layout with a rewards/activity data layer (`RewardsStore`) |
| `2c263e3` | Cover photos (PhotosPicker, JPEG compression), Welcome hints overlay, share-to-circle, owner-only edit/delete |
| `3c37112` | Public circles through Firebase (`FirebaseCircleService`, 278 lines), likes and bookmarks, Firestore rules |
| `5796e91` | Swift concurrency fix (`nonisolated` seed data) |

### 4. Accounts, privacy and gamification decisions (10–11 June)

| Commit | What it did | Decision it shows |
| --- | --- | --- |
| `905bba2` | Account sign-up/sign-in flow (`AuthStore`), onboarding rewrite | |
| `c500f82` | Password length rule | |
| `04b1b16` | **On-device caches scoped per Firebase UID** across 7 stores | Two people on one phone never see each other's journal |
| `a1fa683` | **Softened gamification wording in Profile** | Reflection over points |
| `1087b2c` | Restored quest/reward sections but **hid the point numbers** | Keep the progress cue, drop the score |

### 5. Release engineering (11 June)

| Commit | What it did |
| --- | --- |
| `deecbc9` | Moved signing settings to a git-ignored `Signing.xcconfig` (template kept) |
| `b7c0bb5` | Per-developer Firebase config: removed the committed `GoogleService-Info.plist`, added an `.example` |
| `2bf988f` | **App Store readiness pass**: `PrivacyInfo.xcprivacy` privacy manifest (108 lines), Firebase start-up and session-store fixes |

## Where her code is today

The project later (23 October onward) moved to a guest-first, local-only app (Today / Journal / Practice, SwiftData). Circles and rewards were deferred. The standard Release build still opens the earlier Firebase/account app, which is where most of her June work lives (Circle, Profile, glass kit, Live Coach). The guest app is a separate code path under `Circleu/Features/GuestJournal` and doesn't use her glass components.

## The 21 commits authored as `Claude`

All 21 are dated 26 October 2026 and carry `Claude-Session` links to six claude.ai cloud sessions. Evidence that they belong to another team member's sessions, not hers:

- None of the six sessions can be found from her claude.ai account (checked 5 November 2026).
- One of them (`session_01AwnvXo8gPibfNJBE2ycbd8`) also produced 5 commits authored as `Manh Tuan Nguyen`.
- The matching log entries (for example `docs/agent-collaboration-log/2026-10-26-160000-claude-settings-icon-rows.md`) say the work followed "Mike's 'less text' request", was approved by Mike, and was tested "on Mike's Mac".

**Open question:** if she used a second claude.ai account, opening one of those session links while signed in to it would settle the question. The same applies to the `Devlaycon` fork that PR #2 and PR #3 came from.

## Not visible in Git

Research, interviews, usability tests, MVP prioritisation, design reviews and product decisions don't produce commits. In this repository the product documents (`docs/product/*`) and the October agent logs were committed by other team members, so her PM work needs its own evidence: research notes, Figma files, test scripts, meeting notes or a teammate's confirmation.
