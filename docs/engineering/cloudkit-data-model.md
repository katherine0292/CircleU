# CloudKit Data Model

CloudKit is the preferred Apple-first database layer for Circleu. The app remains local-first: local stores keep working without sign-in, network, or CloudKit availability.

## Database Ownership

Use the private CloudKit database first:

- `UserProfileRecord`: profile and preferences.
- `JournalEntryRecord`: reflection journal history.
- `AIReflectionSessionRecord`: AI reflection attempts and selected output.
- `QuestRecord`: quest/tip progress.
- `TipsPracticeSessionRecord`: communication practice history.

Use the shared CloudKit database later:

- `CircleRecord`: shared circle metadata.
- `CircleMemberRecord`: membership, role, and invitation state.
- `CirclePostRecord`: posts inside a circle.

Do not store private journal text in public records.

## Record Types

| Record type | Scope | Fields |
| --- | --- | --- |
| `UserProfileRecord` | private | `localUserID`, `displayName`, `promptIndex`, `updatedAt` |
| `JournalEntryRecord` | private | `entryID`, `createdAt`, `updatedAt`, `durationSeconds`, `transcript`, `engineName`, `sessionID`, `editableTitle`, `editableEmotion`, `privateNote`, `tags`, `resultJSON` |
| `AIReflectionSessionRecord` | private | `sessionID`, `createdAt`, `updatedAt`, `entryID`, `engineName`, `source`, `transcript`, `durationSeconds`, `selectedAttemptID`, `mergedSessionIDs`, `attemptsJSON` |
| `QuestRecord` | private | `questID`, `title`, `detail`, `sourceEntryID`, `createdAt`, `completedAt`, `status` |
| `TipsPracticeSessionRecord` | private | `sessionID`, `createdAt`, `updatedAt`, `originalMessage`, `scene`, `customScene`, `tone`, `situation`, `attachedImageCount`, `turnsJSON`, `coachOutputJSON` |
| `CircleRecord` | shared later | `circleID`, `name`, `intention`, `createdAt`, `updatedAt` |
| `CircleMemberRecord` | shared later | `memberID`, `circleID`, `userID`, `role`, `status`, `createdAt`, `updatedAt` |
| `CirclePostRecord` | shared later | `postID`, `circleID`, `createdAt`, `updatedAt`, `title`, `body`, `sourceEntryID` |

## Record IDs

Use deterministic CloudKit record names so upload-only backup can overwrite the same logical record:

- `profile_<localUserID>`
- `journal_<entryID>`
- `aiSession_<sessionID>`
- `quest_<questID>`
- `tipsPractice_<sessionID>`
- `circle_<circleID>`
- `circleMember_<memberID>`
- `circlePost_<postID>`

## Sync Rules

The first CloudKit sync implementation should be upload-only backup to the private database. It should never delete local data when CloudKit is unavailable.

Two-way sync comes later and must define conflict rules for:

- edited journal fields,
- deleted journal entries,
- quest status changes,
- merged AI sessions,
- shared circle membership changes,
- shared circle post edits and deletes.

## Privacy Rules

Sensitive fields include transcripts, journal content, private notes, tags, circle post bodies, practice messages, and AI attempts. These fields may go to the user's private CloudKit database only after backend sync is intentionally enabled.

Analytics must not include sensitive field values. External AI providers must not read directly from CloudKit.

## Code Contract

`Circleu/Services/CloudKitDataModel.swift` mirrors this schema with stable record types, scopes, field names, sensitive-field flags, and deterministic record-name prefixes. Update the doc and tests together when the schema changes.
