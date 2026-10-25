# Legacy data format and migration risks

Research snapshot, 23 October 2026. Inspected current source at `2f28966` and historical commit `1087b2c` from upload day. This is a source-backed format catalog, **not a verified dump of TestFlight 1.0 (1)**. The original Mac was returned and its archive is unavailable. No real user records were downloaded, opened for this schema review or copied into this document.

## Historical evidence

- `1087b2c` is dated 11 June 2026, 10:57:08 +10:00. Apple displays the upload at 11:02 AM that day, but its timestamp timezone and exact build checkout are not established. This is a candidate source snapshot, not an identified release commit.
- At that snapshot, journal, practice and AI-session stores use unsuffixed device-wide keys. Commit `04b1b16` at 13:07:42 +10:00 adds account scoping to several stores. Current source uses `<base>.user.<firebaseUID>`. Therefore support both layouts; **an unsuffixed key is not proof of guest ownership** and may contain earlier signed-in or mixed-account content.
- Comparing the candidate to HEAD shows the journal Codable fields, practice models, AI-session model and private Firestore payload shapes are materially unchanged. The journal gains a computed preview; the Firestore service gains deletion operations. Store behavior and ownership isolation did change.
- Allowlisted historical plist inspection: `b7c0bb5^:Circleu/GoogleService-Info.plist` points to `circleu-45651` and the existing bundle ID. `b7c0bb5` removes that tracked plist in favor of per-developer configuration. This is evidence for Dev as a historical candidate, not proof of the plist bundled at upload. No API key or credential was recorded.

## Local persistence

The stores use `UserDefaults.standard`. The main collections are JSON-encoded `Data`, not a SQLite/SwiftData database. Their encoders/decoders use ISO-8601 dates, UUID strings and raw-string enums. Optional `Data` values in Codable models use the encoder's default representation; inspect and preserve attachment bytes rather than treating their count as the attachment.

| Key / current scope | Stored shape | Recovery treatment |
| --- | --- | --- |
| `circleu.saved.reflections.v1[.user.<uid>]` | `[JournalReflectionEntry]` | Preserve original transcript, generated result and accepted overrides separately |
| `circleu.tipsPractice.sessions.v1[.user.<uid>]` | `[TipsPracticeSession]` | Preserve original message, conversation turns, output choices and local image bytes; do not apply the old 12-session truncation during import |
| `circleu.aiReflectionSessions.v1[.user.<uid>]` | `[AIReflectionSession]` | Preserve attempts, selected attempt and entry links; history is not automatically accepted content |
| `circleu.quests.v1[.user.<uid>]` | `[Quest]` | Preserve status and `sourceEntryID`; only explicitly selected items become new optional next steps |
| `circleu.rewards.v1[.user.<uid>]` | Object: `points`, `pointsLog`, `questAwards`, `activity` | Preserve/export legacy history separately; no rewards feature added to the MVP |
| `circleu.profile.displayName.v1[.user.<uid>]` | String | Ownership-aware optional profile metadata |
| `circleu.profile.dailyPromptIndex.v1[.user.<uid>]` | Integer | Nonessential legacy preference |
| `circleu.settings.isCloudAIEnabled.v1[.user.<uid>]`, `circleu.settings.hasConsentedToCloudAI.v1[.user.<uid>]` | Booleans | Do not reactivate cloud AI or carry old consent into the new guest experience |
| `circleu.auth.accounts.v1` | `[Account]`: local UUID, email, display name, salted password hash, salt, created date | Sensitive legacy authentication material; exclude from portable content exports and new guest storage |
| `circleu.auth.session.v1`, `circleu.currentFirebaseUID` | Local session email / cached Firebase UID | Hints only, not proof of identity or authority to import another scope |
| `circleu.circles.v2`, `circleu.circlePosts.v2` | Device-wide `[CircleSpace]`, `[CirclePost]` caches | Mixed/shared ownership; do not bulk-import into a private Journal or treat cached membership as verified ownership |

Square brackets above indicate an optional suffix, not literal key characters. The guest/local UUID, cached email and Firebase UID are distinct identities. A user may have several scopes on one installation. Enumerate keys without logging their private values; never merge all scopes merely because one person currently holds the phone.

Sources: [journal store](../../Circleu/Stores/ReflectionJournalStore.swift), [practice store](../../Circleu/Stores/TipsPracticeStore.swift), [AI store](../../Circleu/Stores/AIReflectionSessionStore.swift), [quests](../../Circleu/Stores/QuestStore.swift), [rewards](../../Circleu/Stores/RewardsStore.swift), [profile](../../Circleu/Stores/UserProfileStore.swift), [local auth](../../Circleu/Stores/AuthStore.swift), [backend session](../../Circleu/Stores/BackendSessionStore.swift), [circle cache](../../Circleu/Stores/CircleStore.swift).

## Core record fields

| Record | Required / significant fields in inspected source |
| --- | --- |
| Journal entry | `id`, `createdAt`, `durationSeconds`, `transcript`, `engineName`, `result`. Optional `sessionID`, `editableTitle`, `editableEmotion`, `lastEditedAt`; absent `privateNote` defaults to empty and `tags` to an empty array |
| Reflection result | `title`, `emotion`, `summary`, `insight`, `expressionMoment`, `quote`, `confidenceScore`, `suggestedQuest`; all required by the current decoder |
| Practice session | `id`, `createdAt`, `updatedAt`, `originalMessage`, `scene`, optional `customScene`, `tone`, `situation`, `turns`, `coachOutput`, `attachedImageCount`. No journal-entry link exists in this model |
| Practice turn/output | Turn: UUID, role, label, text, date, optional `imageData`. Output: suggested phrasing, explanation, simulated reply, room reading and reply-option records. Preserve these separately from whichever message the user later accepts |
| AI session | UUID, dates, optional `entryID`, engine, source, transcript, duration, attempts, optional selected-attempt UUID and merged-session UUIDs. Missing `mergedSessionIDs` defaults to an empty array |
| Quest | UUID, title, detail, optional `sourceEntryID`, dates and raw status (`active`, `completed`, `skipped`) |

The practice scene enum includes workplace/family/friendship/romantic/custom; tone includes soft/diplomatic/firm; turn roles include user/coach/simulatedPerson. Unknown enum values must be retained as unsupported data rather than discarded or coerced into misleading content.

Source definitions: [journal/result](../../Circleu/Models/ReflectionEntry.swift), [practice](../../Circleu/Models/TipsPracticeModels.swift), [AI sessions](../../Circleu/Models/AIReflectionSession.swift), [quests/shared/reward records](../../Circleu/Models/PinguModels.swift).

## Firestore backup format

The [mapper and reader](../../Circleu/Services/FirebaseFirestoreSyncService.swift) use explicit dictionaries, not the local Codable JSON shape. Firestore writes contain Date/Timestamp values; its reader also accepts numeric Unix seconds. Do not decode them using the local ISO-8601 assumption.

| Path relative to `users/<firebaseUID>` | Identifier / mapping |
| --- | --- |
| User document itself | `uid`, optional `email`, `displayName`, optional `localUserID`, `createdAt`, `updatedAt` |
| `profile/main` | `displayName`, `promptIndex`, `updatedAt` |
| `journalEntries/<UUID>` | `entryID` maps to local `id`; `updatedAt` maps to `lastEditedAt`; transcript/result/overrides/tags and optional AI `sessionID` |
| `tipsPracticeSessions/<UUID>` | `sessionID`; nested `turnID` and `optionID`; scene/tone/context/output. **Turn `imageData` is omitted from this backup mapper**, although `attachedImageCount` is present |
| `aiReflectionSessions/<UUID>` | `sessionID`, optional `entryID`, `selectedAttemptID`, `mergedSessionIDs`, nested `attemptID`/status/result/error/timing |
| `quests/<UUID>` | `questID`, optional `sourceEntryID`, text/dates/status |
| `rewardState/main` | Points/level/progress, `questAwards`, `updatedAt` |
| `pointEntries/<UUID>`, `activityEvents/<UUID>` | `pointEntryID` / `activityEventID`, dates, event fields and optional reference UUID |

Public/shared `circles/<circleID>/posts/<postID>` uses a separate [circle service](../../Circleu/Services/FirebaseCircleService.swift). Private backup explicitly excludes circles/posts. Cloud project ownership, Firebase UID and shared-content ownership are separate from Apple team membership. Do not move all cloud records to a new Firebase project as part of Apple enrollment.

## Risks that change the migration plan

1. **Ownership ambiguity:** pre-scoping device keys can include earlier accounts' data. Preserve them in a protected unresolved archive. Determine provenance before a normal content preview/import; current Firebase login alone does not establish ownership of every unsuffixed item.
2. **Destructive decoding:** AI-session loading removes its stored key if array decoding fails. Other stores return empty state on a decode failure; a later save can overwrite the original. Snapshot raw bytes before constructing old stores or normalizing records.
3. **Silent omissions:** Firestore restore uses `compactMap`, dropping malformed documents/children, while some dates default to “now.” Migration needs fetched/decoded/rejected counts and explicit field errors. Never show complete recovery after silently losing records.
4. **History limits:** practice mutations/merge retain only 12 sessions; reward histories also have caps. Preserve all recovered source records outside these legacy store methods. Already-trimmed records may not be recoverable locally.
5. **Incomplete cloud copies:** practice images are local-only in the inspected mapper. An attachment count is not proof of backed-up bytes. Cloud-only recovery must disclose missing attachments, and local recovery should preserve them where available.
6. **No reliable deletion history:** upload uses merge and restore merges by IDs; there is no tombstone/versioned migration contract here. Cloud-only records may have been deleted locally. Require explicit selection and durable import receipts; do not resurrect them automatically.
7. **Exports are currently readable text:** existing journal `exportText`/`shareText` is not a complete round-trip archive and does not cover all categories/relationships. A future machine-readable migration package is new work, not an existing capability.
8. **No practice-entry link to preserve:** current practice records do not have `sourceEntryID`. Import them as standalone unless a future verified source provides a link. Never infer a relationship from similar text or timestamps.

## Evidence needed before implementation

Use isolated, invented fixtures for pre-scoping and scoped formats, malformed JSON/unknown enums, duplicate IDs, missing optional fields, attachments, cross-account collisions and cloud timestamp variants. Validate the decoder against an authorized source from an existing installation or archive if obtainable; code history alone cannot certify the shipped schema. Keep raw source and rejected data protected, verify record/link/attachment counts, and distinguish a faithful content import from a readable export. No new decoder or tests were written/run in this research pass.

See the [personal-account release options](../product/personal-account-release-plan.md) and [transition plan](../superpowers/plans/2026-10-23-local-first-transition.md).

## Owner decision: earlier journal in the guest app (26 October 2026)

Mike chose option 1. The earlier journal **stays sealed** in the guest app (`GuestLegacyImport.allowsUnverifiedOnDeviceImport` stays `false`) until account sign-in is built. After that, only **the signed-in account's own journal** is imported. Unverified on-device data is never shown on the strength of a personal confirmation, and no export-file route is planned for now.

Sign-in work touches Firebase and accounts, so it needs Mike's explicit go-ahead before it starts. See the [batch C log](../agent-collaboration-log/2026-10-26-024500-claude-guest-import-welcome.md).
