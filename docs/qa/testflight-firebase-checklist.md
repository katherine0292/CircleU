# TestFlight Firebase QA Checklist

Status, 23 October 2026: **legacy cloud-build checklist, not completed and not the new guest/local beta checklist.** The [live inventory](../engineering/legacy-data-inventory.md) found accounts and records in Dev, while current Release configuration selects Prod. TestFlight **1.0 (1)** is verified and expired; its bundled Firebase configuration is still unverified. The upload Mac was returned and no archive is currently available. Do not use this checklist as evidence that the backend passed testing.

Use the checks below only for an identified legacy build with isolated, disposable test data. Preserve existing installations and recovery copies; do not reinstall the only copy of someone's data. No account creation, record deletion or release change is authorized by the current planning task.

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
| Firebase project | Verify from the actual build/archive; do not assume Dev |
| Bundle ID | `edu.uts.tuannm3812.Circleu` |
| Test email |  |
| Firebase UID |  |

Use a fresh Firebase Auth account when possible. Reusing an old account can restore old test data and make the result harder to read.

## 1. Firebase Console Preflight

1. Open Firebase Console.
2. Select the project verified from the actual build/archive. Current source selects `circleu-prod` for Release and `circleu-45651` otherwise; `.firebaserc` defaults to Dev.
3. Open **Project settings > General**.
4. Confirm the iOS app bundle ID is `edu.uts.tuannm3812.Circleu`.
5. Open **Authentication > Sign-in method**.
6. Confirm **Email/Password** is enabled.
7. Open **Firestore Database > Rules**.
8. Read and compare the full deployed rules with the build's intended rules. Record differences; do not deploy merely to make them match. Validate ownership behavior in an isolated rules test environment.

Expected result:

- Fresh users can read/write only under `users/{theirUid}`.
- Private backup must not write into `circles/`. The earlier blanket expectation that all circle writes are denied is obsolete: circle records exist and current local rules include circle operations. Deployed owner/member/stranger behavior still needs verification.

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

1. On an isolated disposable test installation only, first verify a recoverable copy and expected record counts, then delete the Circleu app or reset its local test data. Never start with an existing tester's only installation/copy.
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

Historical cleanup reference only; do not run during discovery or migration planning. A familiar title or a Dev project name does not prove a record is disposable. Any later cleanup needs independently verified test-only ownership, an explicit deletion scope and a recovery plan. Candidate legacy paths were:

```text
users/{uid}/rewardState/main
users/{uid}/pointEntries/*
users/{uid}/activityEvents/*
users/{uid}/journalEntries/*
users/{uid}/aiReflectionSessions/*
users/{uid}/quests/*
```

Do not delete real or uncertain data. This checklist is not authorization to clean up existing accounts.

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

These results assess only the identified legacy cloud build. Readiness for the new guest/local beta also requires the [transition plan](../superpowers/plans/2026-10-23-local-first-transition.md), data-preserving recovery, network isolation and the supported-device checks. No pass is recorded by this document update.
