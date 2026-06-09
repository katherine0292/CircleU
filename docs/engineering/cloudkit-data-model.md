# CloudKit Data Model

Circleu should use CloudKit as the primary Apple-first database layer. The app remains local-first: local stores keep working without sign-in, network, or CloudKit availability.

## Database Ownership

Use the private CloudKit database first.

- `UserProfileRecord`: private user profile and preferences.
- `JournalEntryRecord`: private reflection journal history.
- `AIReflectionSessionRecord`: private AI reflection attempts and selected output.
- `QuestRecord`: private quest progress.
- `TipsPracticeSessionRecord`: private communication practice history.

Use the shared CloudKit database later.

- `CircleRecord`: shared circle metadata.
- `CircleMemberRecord`: shared membership, role, and invitation state.
- `CirclePostRecord`: shared posts inside a circle.

Do not store private journal text in public CloudKit records.

## Record Types

### UserProfileRecord

Fields: `localUserID`, `displayName`, `promptIndex`, `updatedAt`.

Scope: private.

### JournalEntryRecord

Fields: `entryID`, `createdAt`, `updatedAt`, `durationSeconds`, `transcript`, `engineName`, `sessionID`, `editableTitle`, `editableEmotion`, `privateNote`, `tags`, `resultJSON`.

Scope: private.

### AIReflectionSessionRecord

Fields: `sessionID`, `createdAt`, `updatedAt`, `entryID`, `engineName`, `source`, `transcript`, `durationSeconds`, `selectedAttemptID`, `mergedSessionIDs`, `attemptsJSON`.

Scope: private.

### QuestRecord

Fields: `questID`, `title`, `detail`, `sourceEntryID`, `createdAt`, `completedAt`, `status`.

Scope: private.

### TipsPracticeSessionRecord

Fields: `sessionID`, `createdAt`, `updatedAt`, `originalMessage`, `scene`, `customScene`, `tone`, `situation`, `attachedImageCount`, `turnsJSON`, `coachOutputJSON`.

Scope: private.

### CircleRecord

Fields: `circleID`, `name`, `intention`, `createdAt`, `updatedAt`.

Scope: shared later. Keep local-only until membership and sharing rules exist.

### CircleMemberRecord

Fields: `memberID`, `circleID`, `userID`, `role`, `status`, `createdAt`, `updatedAt`.

Scope: shared later.

### CirclePostRecord

Fields: `postID`, `circleID`, `createdAt`, `updatedAt`, `title`, `body`, `sourceEntryID`.

Scope: shared later. Never expose the full linked journal entry through the post.

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

Phase 1 CloudKit sync should be upload-only backup to the private database. It should not delete local data when CloudKit is unavailable.

Two-way sync comes later and must define conflict rules for edited journal fields, deleted journal entries, quest status changes, merged AI sessions, shared circle membership changes, and shared circle post edits or deletes.

## Privacy Rules

Sensitive fields include transcripts, journal content, private notes, tags, circle post bodies, practice messages, and AI attempts. These fields may go to the user's private CloudKit database only after backend sync is intentionally enabled.

Analytics must not include sensitive field values. External AI providers must not read from CloudKit directly.
