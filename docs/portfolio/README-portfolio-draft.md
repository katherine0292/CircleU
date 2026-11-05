<!--
Draft README for a portfolio copy of CircleU. Not the team README.
Image and link paths assume this file is moved to the repository root as README.md.
Items marked [confirm] come from Katherine's own records and are not in this repository; check each before publishing.
Screenshots: use real captures from docs/design/core-screen-review-2026-10-27/ or new ones; don't use mock-ups as if they were the shipped app.
-->

# CircleU

**Reflect on a hard conversation. Practise what to say next. Everything stays on your phone.**

An iPhone app built by a five-person team in the Apple Foundation Program (Sydney, May–November 2026), mentored by Apple engineers. Shipped to TestFlight.

| Today | Journal | Practice |
| :---: | :---: | :---: |
| ![Today](docs/design/core-screen-review-2026-10-27/t1-chips.png) | ![Journal](docs/design/core-screen-review-2026-10-27/u6-entry.png) | ![Practice](docs/design/core-screen-review-2026-10-27/practice-pinned-save.png) |

<!-- Replace with a 20–30 second screen recording (GIF or MP4) of: capture → reflection → practice. -->

## The problem

People who are new to a team, a job or a country often replay a difficult conversation for days and still don't know what to say next time. Journaling apps stop at "how do you feel"; speaking coaches assume you're preparing a presentation.

CircleU joins the two: **capture → reflect → practise the wording**.

## My role: product lead (PM & UX)

Team of five. I owned product definition, research and design review, and wrote part of the app with Claude Code.

**Research and definition**
- Interviews with 20 people and 10 usability sessions [confirm]; competitive analysis of Finch and Yoodli.
- MVP of 10 features in P0/P1 tiers; cut the community and rewards modules.
- After testing, cut the reflection card from 5 sections to 3 and added an on-device privacy note. Retest task completion went from 6/10 to 9/10 [confirm].

**AI experience decisions**
- The AI's interpretation is shown apart from the user's own words; rewrites need confirmation and can be undone.
- When the model is unavailable, a local rules path still completes the reflection. No core task depends on AI.
- Moved from cloud Gemini to Apple's on-device Foundation Models: privacy, cost, availability.

**Code I wrote (June, about 6,000 lines, 23 commits)**
- The "liquid glass" visual system for the first TestFlight build (`Circleu/Design/PinguGlassKit.swift`).
- Live Coach practice screen: reply vs. context split, copy feedback, composer layout.
- Journal caches scoped per account, so two people on one phone never see each other's entries.
- Removed point scores from Profile to keep the focus on reflection.
- App Store readiness: privacy manifest, signing and Firebase config kept out of Git.

Full, commit-level breakdown: [contribution map](docs/portfolio/katherine-contribution-map.md).

## Key decisions

| Decision | Why | Trade-off |
| --- | --- | --- |
| Guest-first, local only | Journal content is sensitive; no account wall before first use | No sync between devices |
| On-device model with rules fallback | Nothing leaves the phone; works offline and on older iPhones | Weaker wording than a cloud model |
| Cut circles and rewards from the MVP | Testing showed they pulled attention from reflection | Less retention scaffolding |
| AI suggests, the user decides | Users must recognise their own words | More taps per rewrite |

## What we learned

<!-- 3 short points, written by you. Example: what a usability session changed, a decision you'd make differently, what AI-agent collaboration was good and bad at. -->

## Build

Requires a current Xcode and iOS 17+ [confirm Xcode version]. Copy `Config/Signing.xcconfig.example` to `Config/Signing.xcconfig` and set your team. The project has 321 automated tests (unit + UI): scheme `Circleu` and `CircleuUITests`.

## Team and credits

Five-person team, Apple Foundation Program 2026. [add names and roles, with their permission]. Engineering lead: Manh Tuan Nguyen [confirm title]. Parts of the code were written with Claude Code and Codex; the agent collaboration log is in `docs/agent-collaboration-log/`.
