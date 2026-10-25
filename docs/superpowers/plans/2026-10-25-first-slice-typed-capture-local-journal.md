# First production slice: typed moment → local save → Journal → edit

> **Status:** proposal for owner approval, 25 October 2026. No app code until Mike approves. For agentic workers: use superpowers:executing-plans once approved.

**Goal:** prove that the guest-local app can keep someone's own words safely. Type a moment, save it on the phone, see it in Journal, open it, edit it, and find the edit after relaunch. No account and no network.

**Inputs:** [walkthrough decisions](../../design/prototype-review-results.md#walkthrough-summary--25-october), [MVP definition](../../product/mvp-definition.md), [local-first transition plan](2026-10-23-local-first-transition.md) (Task 2), [architecture](../../engineering/architecture.md), [reuse map](../../engineering/mvp-reuse-map.md).

## Scope

- **Today:** "Work through a moment" opens Write. "Continue your draft" appears only when a draft exists.
- **Write:** typed original words; the draft survives leaving and relaunch. **Save only my words** is the only save in this slice.
- **Journal:** list, newest first; an entry's detail shows the original words; "Edit"; leaving with unsaved edits asks Keep editing / Discard.
- **Storage:** a new versioned local store with stable IDs and explicit states: loading, empty, read-failed, write-failed. A failed read is never shown as an empty journal, and a failed save keeps the text on screen with "Couldn't save. Try again."
- **Delete:** a single entry, with "Couldn't delete. Try again." on failure. Linked-message deletion comes with Practice.

## Out of scope (later slices)

Suggestions and AI (on-device model later), voice, Practice, calendar/search, Privacy and data in Settings, legacy data migration and recovery, Circles, rewards, Firebase changes, dark mode, release and TestFlight.

## Approach

1. **Storage spike (bounded, invented data):** compare SwiftData with versioned JSON files. Check atomic writes, file protection, a schema change, disk-full and interrupted writes. Pick from evidence and record it in the transition plan.
2. **`LocalContentRepository` (`Circleu/Services/`)**: load, saveDraft, save(entry, revision), delete, with typed errors. It's a new storage namespace; legacy `UserDefaults` keys and bytes are **never read, changed or deleted** by this slice.
3. **Guest composition root (`Circleu/App/`)**: builds only local services, with no Firebase, backup, listeners or cloud engine. It runs only behind a debug-only launch flag, so the shipped/TestFlight path is unchanged.
4. **Screens and ViewModels (`Circleu/Features/`):** new `Capture` (Write) and guest `Journal` list/detail/edit ViewModels using the repository. Reuse brand fonts, colours and illustrations from the prototype; Dynamic Type and VoiceOver from the start.
5. **Copy:** as approved in the walkthrough ("Save only my words", "Nothing saved on this day." style, Discard prompt).

## Tests

- **Unit:** save → relaunch → read; edit keeps ID and bumps revision; read failure reported, not empty; write failure keeps text; delete failure keeps entry; draft survives relaunch; guest root constructs no Firebase/cloud services (`testGuestStartupDoesNotConstructCloudServices`).
- **UI (Simulator):** type → save → Journal → edit → relaunch shows the edit; unsaved-edits prompt; largest text; accessibility audit.
- **Phone:** the same flow on Mike's iPhone. CI must stay green (existing 96 tests plus new ones).

## Risks

- **Legacy data:** previous TestFlight users' local and Firebase data stay untouched, because this slice uses a separate store and a debug-only flag. Migration is Task 3 of the transition plan, not this slice.
- **Firebase paths:** the existing app still configures Firebase at startup. The guest root must not import or construct those services. A test guards this.
- **Storage choice:** the wrong store is costly to undo, hence the spike first.
- **Scope creep:** suggestions, voice and Practice stay out until this slice is proven.

## Order and checkpoints

Spike (report to Mike) → repository + tests → guest root behind flag → Write + draft → Journal list/detail/edit → UI/phone checks → Codex review → PR. One PR per step where practical, each with CI green; owner check after the spike and after the first phone run.
