# Competition frontend review — 27 October 2026

**Status: assessment and proposals for owner review; no runtime changes approved or made by this document.** Reviewed source at `9967a10` on `codex/app-upgrade-plan`. The competition name, deadline, judging criteria and required submission format are still unknown. The recommendation prioritises a visible native UI improvement before broad backend qualification; it does not replace the release gates in the [upgrade roadmap](../superpowers/plans/2026-10-27-app-upgrade-roadmap.md).

## 1. Recommendation

Start with **Today and Journal hierarchy**, four changes within `GuestJournalScreens.swift`: a shallower Today scene, a quieter nudge, a full-screen Journal background and a compact entry date title. This improves the first task and the saved result without a new font, palette, asset set, navigation structure or feature. Keep the current native proportions as the baseline and show the four changes together for approval before coding.

If the deadline is very close, use the **two-change fallback**: Journal background and compact entry date title only. Both have direct visual evidence; the title also has an existing compact design reference. Leave Today composition and Practice untouched for that fallback. These are scope choices, not time estimates.

A Practice-first alternative would improve the most visibly inconsistent tab, but would leave Today's crowded first impression unchanged. A full onboarding/brand redesign has little evidence of benefit: the existing rainy-street Welcome is already distinctive, while the core editing screens need more attention.

## 2. Evidence inspected and limits

Read the required project standards, log protocol, shared coding baseline, MVP decisions, [guest stories](../product/user-stories.md), [content rules](screen-content-guidelines.md), [branding guideline](branding-guideline.md), upgrade roadmap and latest design/quality handoffs. The older branding/MVP documents contain prototype-era implementation status; current guest source and the [27 October quality record](../agent-collaboration-log/2026-10-27-005639-codex-practice-copy-quality.md) establish the newer native state. Release still has a separate route; this review concerns the guest app.

Native evidence was exported from the existing, previously run result bundle:

`/tmp/circleu-quality-derived/Logs/Test/Test-CircleuUITests-2026.10.27_00-54-56-+1100.xcresult`

The recorded run was iPhone 18 Pro / iOS 27.0 Simulator. Exporting attachments did not run a new build or test. The following are **local temporary evidence**, not committed review assets; the export manifest maps human-readable attachment names to these files. Only invented test scenarios were inspected.

| Attachment | Local exported filename under `/tmp/circleu-competition-frontend-evidence/` | What it shows |
| --- | --- | --- |
| `g1-today` | `DCBF3E5F-D6F5-4225-84D3-62503F2D80D8.png` | Current scene, avatar badge, three stacked chips and editor |
| `t2-nudge` | `4F066FDF-C609-43C8-AEEC-2C9887060FD4.png` | Default-size writing with the software keyboard, caret and Save visible |
| `today-ax5-writing` | `29615C84-29F3-4A6A-8CEE-1F9877FE5D85.png` | Largest-text nudge and writing, without software keyboard |
| `three-2-journal` | `7FBC9447-11FE-4CE2-97B5-5B50091A1B69.png` | Three saved rows and the one-row reflection offer |
| `journal-empty` | `D0A38C8C-3796-44F4-91BF-031BBE314F92.png` | White page surrounding an ice-coloured empty-state band |
| `u6-entry` | `45EF6158-9A5C-41DD-9F78-523391693749.png` | Very large date/time title above original words and reflection |
| `p4-history` | `2119FCE6-B48B-42F1-9792-8EBD94F0DC0C.png` | Large blue Practice start card and one saved bubble |
| `p2-compose` | `02754E32-CCDA-4893-8B7C-773135C2CC2E.png` | Composer, optional suggestion action, then Save in the scroll content |
| `s4-options` | `A2DCD121-3295-43C9-B046-267723E5DA22.png` | Keyboard covers lower suggestions/actions in this captured scroll position |

Also visually inspected committed [Practice home](../qa/screenshots/practice-visual-2026-10-26/01-practice-home-with-messages.png), [Practice with keyboard](../qa/screenshots/practice-visual-2026-10-26/03-compose.png) and [Welcome page 1](../qa/screenshots/onboarding-scenes-2026-10-26/w1-page1.png). These are 26 October evidence, not fresh current-build captures.

Compared exported design boards [D1 Today](circleu-design-export/png/boards/D1-VisualEmpty.png), [D3 writing](circleu-design-export/png/boards/D3-VisualWriting.png) and [JS3 entry](circleu-design-export/png/boards/JS3-Entry.png). These are static 26 October references, not live Figma reads. D1 still uses older art/chip icons; **do not restore them**. JS3 demonstrates compact date hierarchy; reuse the arrangement only, not its sample date text. No Figma edits were made.

The default-size `t2-nudge` image adds narrow keyboard evidence. It does not contradict the earlier log's claim that its inspected AX5 captures had no software keyboard, and does not prove keyboard behaviour across sizes or devices. No runtime blocker, VoiceOver failure, physical-device pass or contrast audit is claimed from these images.

## 3. Ranked findings

| Rank | Finding and evidence | Classification / implication |
| --- | --- | --- |
| 1 | Today gives the scene and three full-width chip rows most of the first viewport; the editor's lower edge falls behind the reserved Save region in `g1-today`. `GuestWriteView` uses a full-width 1170:600 scene, 16-point stack spacing and a minimum 200-point editor. | **Composition opportunity**, not a proven blocked task. Give writing more initial space without losing the chosen scene or any starter. |
| 2 | The Today nudge uses the same saturated blue as Save and a large white Add capsule. At AX5 the question dominates the viewport. Source confirms the nudge appears above the editor. | **Hierarchy preference plus validation risk.** Reduce its visual weight; preserve the full question, Add/Another/Hide, and user-controlled dismissal. Do not shrink accessible text to force a fit. |
| 3 | Empty Journal has white above/below its ice background band, unlike populated Journal. Its loaded-empty child is content-sized and the background attaches to the enclosing Group without expanding that child. | **Concrete visual inconsistency** visible in the latest capture, with a plausible source cause. Confirm the full-area background fix across empty/loading/error; no data or loading failure inferred. |
| 4 | Entry detail inherits a large navigation title for a full date/time. `u6-entry` is dominated by that metadata; `GuestEntryDetailView` sets no inline display mode. JS3 shows the intended compact alternative. | **Concrete reference mismatch**, not demonstrated truncation. Compact date hierarchy lets the person's words lead. Longer dates/locales still need testing. |
| 5 | Practice has a flat saturated 150-point start card while Today/empty Journal use landscape scenes; the empty Practice state uses a separate 220-point cutout. | **Taste/cohesion opportunity.** Keep the chosen character and native large title; tune its setting and proportions after the first batch. Empty space below short history is not itself a bug. |
| 6 | Practice Save sits after `suggestionsSection` inside the form; Today pins Save with a safe-area inset. More suggestions can move Practice Save further down. Keyboard captures show lower actions outside view. | **Confirmed structural difference; unproven usability failure.** Consider a consistent pinned Save, then test scrolling and focus rather than claiming the button is inaccessible. |
| 7 | Welcome already has a coherent full-bleed scene, short promise, page indicator and clear next action. | **Preserve.** More onboarding art or motion is lower priority than the core screens. |

## 4. First three UI batches

### Batch 1 — Today and Journal hierarchy (recommended first)

**Exact runtime ownership proposed:** `Circleu/Features/GuestJournal/GuestJournalScreens.swift` only. Keep `GuestBrand.swift` and `GuestPinguArt.swift` unchanged unless implementation demonstrates a genuine shared requirement; do not introduce another token system.

1. **Today scene:** retain `GuestSceneToday`, `GuestSceneListening`, microphone ring and chosen-avatar badge. Try a shallower approximately 2.4:1 visible scene instead of 1.95:1 at normal text size, cropping quiet upper sky first. Keep Pingu, the ice floe and microphone intact; reject the crop if it damages the composition. Keep the focused compact-microphone state and omission of decoration at accessibility sizes. Preserve all three starter chips and their current icons/order.
2. **Today nudge:** keep its speech-bubble shape and `GuestPinguThoughtful`, but use the existing ice/wash surface with ink text and blue controls. Make Add an outlined secondary action; retain 44-point targets. This is a proposed change to the accepted blue bubble, requiring owner selection, not a bug fix. Keep wording, trigger threshold, Add/Another/Hide behaviour and accessibility names.
3. **Journal background:** extend the existing ice surface across the available content/safe-area region for every load state; keep the empty illustration and single line. Fix the white/ice break without adding a new CTA or a fake entry.
4. **Entry date title:** use native inline navigation treatment; retain creation-date semantics, older-year information and accessible full timestamp. If a full localized date/time cannot fit, show a concise date in the title and time as unobtrusive metadata with an accessible full value. Do not change sorting, filters or stored dates. Compare to JS3's hierarchy, not its example date text.

**Reused assets:** `GuestSceneToday`, `GuestSceneListening`, `GuestSceneJournalEmpty`, `GuestPinguThoughtful`, `GuestIconLogo`, `GuestChipWhatHappened`, `GuestChipWhoWith`, `GuestChipWishSaid`, selected `GuestAvatars` entry. All already exist. No asset generation or new font.

**Acceptance:** first-screen editor has more visible writing area than the same-size baseline; no scene subject/control is cut off; Save remains the most prominent action while writing. Empty/loading/error Journal backgrounds fill the screen consistently. Entry words lead visually, while creation date/year remains available. No change to save, dictation, prompts, source labels, navigation or legacy recovery semantics.

**Before/after captures:** Today empty/listening; five-word draft with nudge and visible keyboard; nudge hidden; AX5 with keyboard and after scrolling; empty and populated Journal; entry with short/long text, reflection/step and previous-year date. Capture normal, intermediate and largest text on a compact supported iPhone size and the current test size. Physical-phone inspection remains separate.

**Regression ownership for the approved implementation:** frontend requests scoped updates to `CircleuUITests/GuestTodayUITests.swift`, `GuestStatesUITests.swift` and `GuestPolishUITests.swift` only where assertions genuinely verify changed behaviour/layout. The integrator owns changes to stories/content rules and runs both unit/UI schemes before merge. Avoid screenshot-only tests masquerading as runtime checks.

### Batch 2 — Practice visual continuity and a dependable action area

**Exact runtime ownership proposed:** `Circleu/Features/GuestJournal/GuestPracticeScreens.swift`; no ViewModel/service work unless a reproduced bug requires a separately agreed change.

- Recompose the existing `GuestPinguPractising` start card with a quieter ice/wash setting and a clearly blue action area, preserving one hit target and one primary action. Keep the empty state related to that composition; no new generated landscape is required. Preserve message bubbles and the native title/search.
- Move editing Save into a safe-area action region, following Today's established pattern; keep the suggestion source, tone options and Undo in scrolling content. Preserve independent Copy and Save semantics, validation, failed-save text retention and discard flow.
- Make tone-card width responsive to the available space rather than always 272 points; keep a visible next-card edge where practical, full text wrapping and explicit Use this. Do not add carousel pagination copy or hide options.

**Acceptance/captures:** empty/home with draft/history; standalone and linked composer; Situation/Goal expanded; software keyboard and long wording; suggestion success/stale/error; both tone directions; saved, copied and edited states. At large text, every action remains reachable and the original wording stays readable. Reuse `GuestPinguPractising`, `GuestPinguThoughtful`, `GuestPinguThumbsUp`, `GuestIconJournal` and existing tokens. Any claim that saved bubbles imply actual sending must be tested with people; preserve truthful “not sent” feedback now.

### Batch 3 — Coherent review set and state polish

**Exact potential runtime ownership:** `Circleu/Features/GuestJournal/GuestReflectionReview.swift`, `GuestFindAndControl.swift`, and `GuestSignIn.swift` for presentation-only discrepancies found during the approved comparison. These are not blanket rewrite targets. The backend agent/integrator must coordinate any shared file before editing. Leave `GuestImportAndWelcome.swift` unchanged unless a specific Welcome layout defect is reproduced.

- Match reflection, privacy and recovery surface spacing/icon scales to the selected first batches while retaining source labels, privacy wording and destructive scopes.
- Capture one complete invented journey with consistent device, text size and date, then assemble the competition's required format once supplied. Keep separate honest failure/permission/unavailable states. Test identifiers in old QA text are useful diagnostics, not submission content.
- Update accepted Figma frames only after native decisions are approved; label proposals and older boards. No live Figma work is included in this assessment.

**Acceptance:** a reviewer can follow Welcome → write → save → reflect → practise → copy, with the same typography/art/spacing and truthful state language. The submission distinguishes running app, static board and proposed state. No new motion, calendar grouping, time-of-day scene, rewards, cloud feature or distribution is added implicitly.

## 5. Next decision and boundaries

The owner can select Batch 1, the Journal-only fallback, or Practice first. Before implementation, show the proposed visual differences and capture requirements; the scope itself is not approval. Competition details may change which screens must be polished or recorded first. Keep backend qualification running as its separate assigned stream, and retain its release blockers before any external install.

This assessment changes only this document and its unique frontend log. No app build/test, app install, personal journal inspection, Figma mutation, staging, commit or push was performed. The historical 256-unit / 19-UI-pass / 1-skipped baseline is reported evidence from the quality record, not a fresh verification result.
