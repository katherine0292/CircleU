# Original app vs the refined MVP: gap analysis

25 October 2026. Owner request: check what the original app has against the refining plan, then build the gaps in big batches.

Sources:
- the code on `main` at `4879f01`;
- [MVP definition](mvp-definition.md) M01–M08;
- [flow checklist](flow-status-checklist.md) F01–F22;
- [walkthrough decisions](../design/today-walkthrough-script-2026-10-25.md).

"Guest" means the new guest journal behind the hidden switch.

## Status labels

- **Rebuilt**: the guest journal already has it.
- **Port**: in MVP scope; reuse the original code where it fits.
- **Deferred**: later by owner decision.
- **Drop**: not carried into the guest journal.

## Feature map

| Original feature (code) | MVP / flow | Status | Notes |
| --- | --- | --- | --- |
| Welcome, onboarding hints, Firebase login (`Features/Onboarding`) | M01, F01–F02 | **Port** (batch C) | The guest journal starts straight at Today. Wire Welcome → Get started → Today, and Log in → earlier-data route. The login itself stays legacy. |
| Typed capture (`HomeView`, `RecordingViewModel.manualTranscript`) | M02, F04 | **Rebuilt** | Write screen with "Save only my words". |
| Voice recording + transcript (`VoiceRecorder`) | M02, F05 | **Rebuilt** | Now on-device only. Interruptions, denial, and Save while listening are handled. |
| Reflection engine (`ReflectionEngine`) | M03, F06–F07 | **Port** (batch A) | Original: Apple Intelligence → cloud Gemini (with consent) → local templates. Result fields: title, emotion, summary, insight, quote, suggested quest. Port the **on-device model** and the **local fallback** only; no cloud. Make it opt-in ("Get a suggestion"), editable, rejectable, and saved with the original words. |
| Suggested quest (`AIReflectionResult.suggestedQuest`, `QuestStore`) | M05, F13 | **Port** as an optional next step (batch A) | One step that can be edited or skipped, stored on the entry. No quest list, no rewards. |
| Journal list, detail, share text (`Features/Journal`) | M06, F14 | **Rebuilt** (list, detail, edit, delete). **Port** search (batch B) | The original has per-entry share text. Export comes in batch B. |
| Journal calendar (prototype only) | F15 | **Port** (batch B) | Month view with marked days, from the approved preview. |
| Drafts (`RecordingViewModel` in-process) | F09 | **Rebuilt** | Kept on the phone across relaunches. A Practice draft isn't kept yet (batch B). |
| Tips: practice scenes, tones and coaching (`Features/Tips`, `CommunicationCoachEngine`) | M04, F10–F12, F16 | **Rebuilt** (save, copy, history, linking). **Port** suggestions (batch A) | The original offers soft, diplomatic and firm template variants per scene. Reuse them as the non-AI fallback for "Get a suggestion" in Practice: up to 3 editable options. The live voice coach is **Deferred**. |
| Linked deletion | M07, F20 | **Rebuilt** | Keep message / Delete both, in one transaction. |
| Settings hub, About, Policy, Support, Trust & Safety (`Profile/Settings`) | M07, F19–F20 | **Port** (batch B) | Guest Settings: Privacy and data, export (readable text through the share sheet), and delete all guest data with explicit scope. Reuse the About and Policy content where accurate. |
| AI Reflection Lab, QA tools (`Profile`) | none | **Drop** (guest) | Developer tools; kept in the legacy app. |
| Profile edit, levels and rewards (`RewardsStore`, `ProgressEngine`, `PinguLevel*`) | none | **Deferred** | No rewards, streaks or points (MVP). |
| Circles (`Features/Circle`, `FirebaseCircleService`) | none | **Deferred** | Owner decision. |
| Firebase auth, sync, analytics; CloudKit; backend preparation | F21–F22 | **Deferred** / legacy only | The guest journal never constructs them. Recovering old data is batch C, explicit and copy-only. |
| Gentle follow-up | M08 | **Deferred** (P1) | After the beta. |
| Haptics (`HapticManager`) | none | **Port** (small) | Light feedback on save and copy. |
| Stale suggestions after editing the source (F17) | F17 | **Port** (batch A) | Mark a suggestion as "based on an earlier version" after the words change. |
| Offline, model unavailable, protected storage (F19) | F19 | **Port** (batch A) | Clear "suggestions unavailable" with typing and saving still working. Storage is already handled. |

## Build order

1. **Batch A: suggestions.**
   - Opt-in "Get a suggestion" after Write: a short reflection (summary, feeling, one question) to edit or reject.
   - "Save without suggestion" stays.
   - An optional next step.
   - In Practice, "Get a suggestion" offers up to 3 editable options.
   - Uses the on-device model when available (iOS 26 and Apple Intelligence), otherwise clearly labelled templates ported from `LocalReflectionEngine` and `CommunicationCoachEngine`. Mike's iPhone 11 Pro Max gets the templates.
   - Includes stale-suggestion marking and unavailable states.
2. **Batch B: find and control.**
   - Journal search and calendar.
   - Settings: Privacy and data, export (readable text), delete all guest data.
   - Practice draft kept across relaunches.
3. **Batch C: old data and Welcome.**
   - A one-time, copy-only import of the old app's local journal, with a preview. **This needs Mike's OK before building**, because it is the first time the guest journal reads legacy data.
   - Welcome wired to the real guest app.

Guardrails for every batch:
- guest journal only, behind the switch;
- nothing sent off the phone;
- no legacy data changed or deleted;
- no Firebase changes;
- no TestFlight or release.
