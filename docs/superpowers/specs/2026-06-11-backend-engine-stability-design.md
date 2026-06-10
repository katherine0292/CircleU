# Backend and Engine Stability Design

Date: 2026-06-11

## Purpose

Circleu needs one more backend and engine hardening pass before TestFlight. The app already supports Firebase Auth, private Firestore backup/restore, local-first journaling, and AI reflection fallback. The next slice should make those systems easier to trust during teacher testing without adding large new product areas.

## Goals

- Make Firebase sync status clearer during real-device QA.
- Keep local journaling, reflection, tips, profile, and export working when Firebase fails.
- Improve reflection output for realistic transcripts, especially conflict, anger, stress, low-signal input, and rough language.
- Add focused regression tests for backend failure paths and engine behavior.
- Keep cleanup small and tied to reliability.

## Non-Goals

- No shared circle backend yet.
- No real-time chat, social feed, or moderation workflow.
- No Firebase Analytics or Crashlytics integration in this slice.
- No external cloud AI provider in this slice.
- No large rewrite of `FirebaseFirestoreSyncService.swift`.

## Current Architecture

The app is local-first. SwiftUI features talk through stores, engines, and services. Backend work enters through:

- `BackendSessionStore`
- `FirebaseAuthService`
- `FirebaseFirestoreSyncService`
- `BackendSyncSnapshot`
- `ReflectionSessionRunner`
- `ReflectionEngine`
- `TranscriptQuality`

Firestore private data is stored under `users/{uid}`. Shared circle data remains denied by Firestore rules and local-only in the app.

## Backend Reliability Design

### Sync State

Extend backend session state so QA can distinguish:

- signed out,
- signed in but not synced,
- restore in progress,
- upload in progress,
- last restore succeeded,
- last upload succeeded,
- last operation failed.

Add lightweight metadata:

- `lastUploadStartedAt`
- `lastUploadSucceededAt`
- `lastRestoreStartedAt`
- `lastRestoreSucceededAt`
- `lastSyncAttemptedAt`

These values can stay in memory for beta. Persisting them is not required yet.

### Manual QA Actions

Expose manual backend actions where QA tools already show Firebase status:

- Force Upload
- Force Restore

Both actions should reuse existing `BackendSessionStore` methods. They must not delete local data. Restore remains merge-only.

### Failure Behavior

Firebase failures should:

- set a readable QA error,
- leave local data untouched,
- not block the user from saving entries,
- not sign the user out automatically,
- allow a later manual retry.

Tests should cover upload and restore failures using existing fake syncer/restorer patterns.

## Engine Quality Design

### Classification

Improve local reflection handling by classifying transcripts before choosing a fallback profile:

- empty or too short,
- rough low-signal test input,
- coherent rough or hostile language,
- boundary or conflict,
- stress or overwhelm,
- pride or progress,
- tenderness or sadness,
- neutral reflection.

Classification should stay deterministic and testable. It should use simple keyword and quality checks for now, not a new model.

### Output Rules

Generated feedback should:

- avoid generic praise when the transcript is angry, hostile, or unclear,
- avoid repeating profanity or hostile phrases,
- give one concrete next action,
- keep a supportive but grounded tone,
- keep the raw transcript only in "what you said" style UI, not in generated insight cards.

Apple Intelligence prompt rules should match local fallback rules so both paths aim for the same behavior.

### Regression Tests

Add test examples for:

- coherent boundary/conflict transcript,
- rough/hostile transcript,
- stress transcript,
- short/low-signal transcript,
- useful neutral transcript.

The tests should assert both positive behavior and safety behavior. For example: title/emotion/suggested quest are appropriate, and generated fields do not echo rough language.

## Cleanup Design

Avoid a full backend rewrite. Only extract helpers if the reliability work needs them.

Allowed cleanup:

- small sync status formatting helpers,
- small transcript classification helper,
- test fixture helpers for backend sync,
- private methods that reduce duplication inside existing files.

Deferred cleanup:

- splitting all Firestore readers/writers into separate files,
- replacing the full sync service architecture,
- building a general sync queue.

## Testing

Run focused tests first:

```bash
xcodebuild test -quiet -project Circleu.xcodeproj -scheme Circleu -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:CircleuTests/BackendSessionStoreTests -only-testing:CircleuTests/FirebaseFirestoreSyncServiceTests -only-testing:CircleuTests/EngineBehaviorTests
```

Then run a simulator build:

```bash
xcodebuild build -quiet -project Circleu.xcodeproj -scheme Circleu -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

Manual phone QA:

1. Sign in with Firebase.
2. Save one reflection.
3. Confirm QA tools show successful upload.
4. Force restore.
5. Confirm local data remains present.
6. Turn network off, save another local reflection, and confirm the app still works.
7. Test a rough/conflict reflection and confirm feedback coaches instead of praising the wording.

## Acceptance Criteria

- Backend QA status clearly shows last successful upload/restore or the latest failure.
- Force upload and force restore are available from QA tools.
- Upload/restore failures do not destroy or block local data.
- Engine has regression coverage for rough, conflict, stress, and normal reflection examples.
- App builds successfully for the iPhone simulator.
- No shared circle backend writes are introduced.
