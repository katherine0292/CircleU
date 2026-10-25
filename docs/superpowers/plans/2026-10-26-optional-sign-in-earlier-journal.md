# Plan: optional Log in to bring in your earlier journal

26 October 2026. **Proposed plan only.** It contains no code, and it is not approved until Mike says so. It was revised after Codex's review ([log](../../agent-collaboration-log/2026-10-26-031500-codex-review-sign-in-plan.md)).

Mike decided the earlier journal stays sealed until sign-in exists, and then only the signed-in account's own journal is imported ([decision](../../engineering/legacy-data-format.md#owner-decision-earlier-journal-in-the-guest-app-26-october-2026)). This plan says how.

## Goal and non-goals

**Goal.** Someone with an existing CircleU email/password account can optionally **Log in** in the guest app. They can then preview and copy **that account's cloud backup** of their journal and practice into the local journal.

**Non-goals:**
- No sign-up and no new accounts.
- No Google or Apple sign-in.
- No ongoing sync or backup, and no uploads.
- Guest-first stays the default: Get started never asks for an account.
- No circles or rewards.
- Nothing is deleted or changed in legacy data unless the person explicitly asks to delete their account (decision 3).

## What signing in proves, and what it unseals

Firebase Auth proves control of **one account (uid) in one Firebase project**. It does not certify where every historical record came from. So the plan unseals the least it can.

| Source | After Log in | Why |
| --- | --- | --- |
| Cloud backup `users/<uid>/journalEntries` and `users/<uid>/tipsPracticeSessions`, in the project this build uses | **Previewed and copied**, read-only, from the server | Owned by that uid under the project's security rules. The preview says it may include anything this account's earlier app ever backed up. |
| On-device data under that uid (`….user.<uid>`) | **Sealed** | Not proof: the earlier app's restore could finish after an account switch and save account A's records into account B's bucket (`BackendSessionStore.swift:312`). Keys also carry no project. |
| On-device data under other uids, and unsuffixed on-device data | **Sealed** | Unclear or someone else's. Never decoded. It can be revisited only if reliable provenance appears later. |

**A new, narrow cloud reader.** It reads only the two collections. It keeps document IDs and source metadata, reads from the **server** (no cache), and reports rejected records with reasons and partial or unavailable reads. It does **not** reuse the lossy legacy reader (which uses `compactMap` and fetches extra categories), and never calls the legacy merge.

## Flow

1. **Log in** from Welcome, or from Settings → Earlier CircleU app. The form has email, password and **Forgot password?**. Its wording comes from the approved [native recovery previews](../../design/brand-demo/native-recovery.md).
   - Outcomes are generic ("Check your email and password. Your entries are unchanged."), so they never reveal whether an account exists.
   - Duplicate taps are ignored, and repeated failures back off.
   - The legacy local-password check in `BackendSessionStore.signIn` is not used.
2. **Preview, nothing imported:** counts, a few samples with dates, and a left-out list with reasons. Reasons include rejected or unreadable records, no words, practice images that weren't backed up, and fields that aren't copied (titles, tags, turns, coaching).
3. **Copy:** one transaction, reusing batch C's import. Receipts are **scoped by source** (for example `cloud:<project>:<uid>:<kind>:<id>`).
   - Re-running never duplicates.
   - It never brings back items the person edited or deleted locally after copying.
   - Conflicts are settled the same way every time: journal items by `lastEditedAt`, practice by `updatedAt`.
4. **Sign out automatically after copying** (decision 2). Nothing syncs, and the local journal never uploads.

### Session, cache and offline

- **A recovery session is explicit every time.** A Firebase session persisted in the Keychain, for example after a reinstall, is never trusted on launch; the guest app signs it out. Cancelled logins, account switching, revoked credentials and late callbacks discard any results that don't match the current request.
- **No lasting Firestore cache.** Persistence is off for the recovery reader, and its data stays in memory. Sign-out clears it. Copied entries stay as the person's local entries.
- **Delete all** affects local data only.
- **Offline:** Log in and the preview say they need a connection. The guest journal itself never needs a network.

### Password reset

- Add `sendPasswordReset` to the auth adapter. It uses Firebase's hosted reset page, not in-app link handling, with the approved "Check your email" wording.
- Verify **email-enumeration protection** is on in the project.

## What stays local, and privacy wording

- Copied data lives only in the local SwiftData store.
- Privacy wording, shown before typing:
  > Logging in only fetches your earlier journal from your account so you can copy it here. Nothing new is uploaded, and you're signed out afterwards.
- No content in logs or analytics; counts only.

## Firebase configuration and project boundaries

- **Today:** Release builds select **Prod** (`circleu-prod` / `circleu-45651`); non-Release builds select **Dev**. Both are registered to `edu.uts.tuannm3812.Circleu`. The Dev plist is tracked in the repo.
- **Guest Test can't use either project as is.** It uses `com.tuannm3812.circleu.guesttest`, and `FirebaseRuntime` rejects a plist with a mismatched bundle ID (`FirebaseRuntime.swift:43`). The phone test needs a registered client (decision 4).
- **Dev holds real legacy state.** It isn't disposable. Never merge Dev and Prod or copy users between them.
- The guest build constructs **no** Firebase service before Log in. The test `testGuestStartupDoesNotConstructCloudServices` stays, plus a Release-configuration startup check.

## App Review and policy

- **Guideline 4.8:** not triggered by a proprietary email/password login with no third-party or social login.
- **Guideline 5.1.1(v):** explicitly triggered by **account creation**. This app doesn't create accounts, but anyone who can log in should still have an account-deletion route (decision 3). Reusing the legacy deletion is unsafe: it purges before checking for a recent login and hides purge failures.
  - A new deletion would **reauthenticate first**.
  - Cleanup would be verified and retryable, and cover the account's owned cloud content.
  - Local entries would be kept, and the person told so.
- **Privacy label and policy:** must cover email, and backup content fetched on request.

## Tests and review

- **Unit tests with fake auth and a fake cloud reader:**
  - sign-in success, wrong password, offline, throttled and duplicate submit;
  - reset outcomes that look the same whether or not an account exists;
  - a persisted session ignored at launch, an account switch mid-fetch, revoked credentials, late callbacks;
  - only the uid's cloud collections read, with every local bucket still sealed;
  - malformed nested records rejected and counted, and partial or denied reads;
  - deterministic conflicts, scoped receipts, re-run idempotence, and local edits and deletions respected;
  - interrupted import is all or nothing;
  - automatic sign-out after copying;
  - deletion: reauthentication required, and retry after failure.
- **Startup isolation:** no Firebase in the guest app before Log in, in Debug and Release configurations.
- **UI tests on the Simulator** against fakes: Log in → preview → copy, reset states, and offline.
- **Real-account check:** only after decision 4, read-only, with isolated fixtures first.
- **Review:** the full local suite before every merge, plus one Codex pass per PR.

## Decisions for Mike

1. **What can be brought in after Log in:** (a) the account's **cloud backup only** *(recommended)*; (b) also that account's on-device data, despite the known mix-up risk.
2. **After copying:** (a) **sign out automatically** *(recommended)*; (b) stay signed in to re-check later.
3. **Account deletion route:** (a) build **Delete my account** in the same batch, with reauthentication first and local entries kept *(recommended)*; (b) a later batch, before any App Store submission.
4. **Phone test client:**
   - (a) **register the Guest Test bundle as a new iOS app in the Dev project** *(recommended)*: read-only, using an account you choose;
   - (b) test only in the Simulator against fakes until the guest journal ships inside the real app.

## Mike's decisions (26 October 2026)

All recommended options were chosen, relayed through the coordinator:

- **1a:** cloud backup only.
- **2a:** sign out automatically after copying.
- **3a:** Delete my account in the same batch.
- **4a:** register CircleU Guest Test in the Firebase **Dev** project for the phone test.

**Building has not started.** It waits for Mike's own "approve plan".

## Appendix: Firebase console steps for 4a (Dev project only)

These are sent to Mike when building starts. Mike does them in the console; the agent doesn't.

1. Open <https://console.firebase.google.com> and choose the **Dev** project, **`circleu-45651`**.
   - It is the project in `Config/Firebase/GoogleService-Info-Dev.plist`.
   - Don't use `circleu-prod`.
2. Go to **Project settings** (gear) → **General** → **Your apps** → **Add app** → **iOS**.
   - **Apple bundle ID:** `com.tuannm3812.circleu.guesttest` (exactly).
   - **App nickname:** `CircleU Guest Test (Dev)`.
   - Leave App Store ID empty, then tap **Register app**.
3. **Download `GoogleService-Info.plist`.** Skip the SDK steps, because the project already has the SDK.
   - Send the file to Claude on the Mac, or save it as `Config/Firebase/GoogleService-Info-GuestTest-Dev.plist`.
   - It holds no password, but it's kept out of commits unless Mike says otherwise.
4. **Authentication → Sign-in method:** check that **Email/Password** is enabled. Don't enable anything new.
5. **Authentication → Settings → User actions:** turn on **Email enumeration protection**, if it's off.
6. **Firestore → Rules:** only look, don't change anything. Check that `users/{uid}/…` can be read only when `request.auth.uid == uid`, and send a screenshot or copy of the rules.
7. Choose which **existing** account to use for the read-only test, and tell Claude the email only. The password is typed by Mike on the phone, never in chat.

Nothing in these steps changes Prod, existing users or data.
