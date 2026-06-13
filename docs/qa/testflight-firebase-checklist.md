# TestFlight Firebase QA Checklist

Use this checklist after uploading a TestFlight build and before telling the team the backend is ready for beta testing.

## Goal

Prove that a real TestFlight user can sign in, create private app data, sync it to Firebase, reinstall the app, and restore the same data without demo or mock records appearing for a fresh account.

## Test Setup

Record these before starting:

| Field | Value |
| --- | --- |
| Date |  |
| Tester |  |
| Device |  |
| iOS version |  |
| TestFlight build |  |
| Firebase project | `circleu-45651` |
| Bundle ID | `edu.uts.tuannm3812.Circleu` |
| Test email |  |
| Firebase UID |  |

Use a fresh Firebase Auth account when possible. Reusing an old account can restore old test data and make the result harder to read.

## 1. Firebase Console Preflight

1. Open Firebase Console.
2. Select project `circleu-45651`.
3. Open **Project settings > General**.
4. Confirm the iOS app bundle ID is `edu.uts.tuannm3812.Circleu`.
5. Open **Authentication > Sign-in method**.
6. Confirm **Email/Password** is enabled.
7. Open **Firestore Database > Rules**.
8. Confirm the deployed rules match `firestore.rules` in the repo.

Expected result:

- Fresh users can read/write only under `users/{theirUid}`.
- Top-level `circles/` writes are denied until shared-circle rules are intentionally implemented.

## 2. Fresh TestFlight User Flow

1. Install the latest Circleu build from TestFlight.
2. Launch the app.
3. Sign up with a fresh email and password.
4. Confirm Profile or QA tools shows a Firebase UID.
5. Create one reflection by recording or typing.
6. Save the reflection.
7. Open Journal and confirm the entry exists.
8. Open Tips and complete or skip one tip.
9. Open Profile and confirm progress/reward state reflects your real actions.
10. Do not use debug seed data. It should not be visible in a TestFlight build.

Pass/fail:

| Check | Pass? | Notes |
| --- | --- | --- |
| Sign-up succeeds |  |  |
| Firebase UID appears |  |  |
| Reflection saves locally |  |  |
| Journal shows saved entry |  |  |
| Tip action updates state |  |  |
| No demo seed button appears |  |  |
| No mock reward/activity appears for fresh user |  |  |

## 3. Firestore Data Check

In Firebase Console, open **Firestore Database > Data** and inspect:

```text
users/{uid}
users/{uid}/profile/main
users/{uid}/journalEntries/{entryID}
users/{uid}/aiReflectionSessions/{sessionID}
users/{uid}/quests/{questID}
users/{uid}/tipsPracticeSessions/{sessionID}
users/{uid}/rewardState/main
users/{uid}/pointEntries/{pointEntryID}
users/{uid}/activityEvents/{activityEventID}
```

Expected result:

- `users/{uid}` exists for the signed-in Firebase UID.
- `journalEntries` contains the reflection you just created.
- `aiReflectionSessions` contains the generation session for that reflection.
- `quests` contains the suggested or completed/skipped tip state.
- `rewardState`, `pointEntries`, and `activityEvents` reflect only real actions from this test.
- There are no canned demo titles such as `Boundary Builders`, `Daily reflection`, `Communication tip`, or old seeded reflections for a fresh account.

Pass/fail:

| Firestore path | Expected | Pass? | Notes |
| --- | --- | --- | --- |
| `users/{uid}` | Current UID only |  |  |
| `profile/main` | Current display name |  |  |
| `journalEntries` | One real reflection |  |  |
| `aiReflectionSessions` | One real session |  |  |
| `quests` | Real suggested/completed/skipped state |  |  |
| `tipsPracticeSessions` | Present only if Tips practice was used |  |  |
| `rewardState/main` | Real points only |  |  |
| `pointEntries` | Real point events only |  |  |
| `activityEvents` | Real activity only |  |  |
| `circles/` | No write from private backup |  |  |

## 4. Restore Test

1. Delete the Circleu app from the phone, or reset local app data if using a debug/device build.
2. Reinstall from TestFlight.
3. Sign in with the same email and password.
4. Wait for the app to finish restoring.
5. Open Journal.
6. Confirm the saved reflection appears.
7. Open Profile.
8. Confirm profile, reward, and activity state match the saved account.
9. Open Tips.
10. Confirm any saved tip state restores.

Pass/fail:

| Check | Pass? | Notes |
| --- | --- | --- |
| Sign-in succeeds after reinstall |  |  |
| Journal restores |  |  |
| AI session history restores |  |  |
| Tip/quest state restores |  |  |
| Reward/activity state restores |  |  |
| No other user's data appears |  |  |

## 5. Old Mock Data Cleanup

If old demo data appears for an account used before the cleanup commit, delete those records from Firebase Console. For the affected UID, inspect and remove seeded records under:

```text
users/{uid}/rewardState/main
users/{uid}/pointEntries/*
users/{uid}/activityEvents/*
users/{uid}/journalEntries/*
users/{uid}/aiReflectionSessions/*
users/{uid}/quests/*
```

Only delete records for known test accounts. Do not delete another tester's data unless they confirm it is disposable.

After cleanup:

1. Reinstall or reset local app data.
2. Sign in again.
3. Confirm old demo content does not restore.
4. Create one new real reflection and repeat the Firestore data check.

## 6. Result

Use this summary at the end of the run:

| Area | Status | Evidence |
| --- | --- | --- |
| Auth | Pass / Fail |  |
| Private backup upload | Pass / Fail |  |
| Private restore | Pass / Fail |  |
| Mock data cleanup | Pass / Fail |  |
| Firestore rules | Pass / Fail |  |
| TestFlight readiness | Pass / Fail |  |

Backend is ready for beta only when Auth, private backup upload, private restore, and mock-data checks all pass on a real TestFlight build.
