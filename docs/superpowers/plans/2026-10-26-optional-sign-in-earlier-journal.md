# Plan: optional Log in to bring in your earlier journal

26 October 2026. **Proposed plan only.** It contains no code, and it is not approved until Mike says so.

Mike decided the earlier journal stays sealed until sign-in exists, and then only the signed-in account's own journal is imported ([decision](../../engineering/legacy-data-format.md#owner-decision-earlier-journal-in-the-guest-app-26-october-2026)). This plan says how.

## Goal and non-goals

**Goal.** Someone who already has a CircleU email/password account can optionally **Log in** in the guest app. That proves they own the account, which lets them preview and copy **that account's** earlier journal and practice into the local journal.

**Non-goals:**
- No sign-up and no new accounts.
- No Google or Apple sign-in.
- No ongoing sync or backup.
- Guest-first stays the default: Get started never asks for an account.
- No circles or rewards.
- No legacy data is deleted or changed, locally or in the cloud.

## What signing in proves, and what it unseals

Signing in with Firebase Auth proves control of **one account (its uid)**. It unseals only data that can be tied to that uid. Everything else stays sealed.

| Source | Unsealed after Log in? | Why |
| --- | --- | --- |
| Firestore private backup at `users/<uid>/journalEntries`, `users/<uid>/tipsPracticeSessions` | **Yes**, read-only | Owned by the uid under security rules. Read with the original app's backup reader, without its merge step. |
| On-device data saved under that account (`circleu.saved.reflections.v1.user.<uid>`, `circleu.tipsPractice.sessions.v1.user.<uid>`) | **Yes**, read-only | Written only while that uid was signed in on this iPhone. |
| On-device data saved under **other** uids | No | It belongs to someone else. It is counted only, and never decoded. |
| Unsuffixed on-device data (`circleu.saved.reflections.v1`, …) | No | Ownership is ambiguous (data from before accounts were separated, or a restored backup). See [legacy-data-format](../../engineering/legacy-data-format.md). It stays sealed. Decision 2 asks whether to offer more. |

Cloud and local copies of the same item share an ID. They are merged by that ID, keeping the newest `lastEditedAt`. Conflicts and rejected records are counted and shown, never silently dropped.

## Flow

1. **Log in** from Welcome, or from Settings → Earlier CircleU app. The form has email, password and **Forgot password?**. Its wording comes from the approved [native recovery previews](../../design/brand-demo/native-recovery.md), including "Check your email and password. Your entries are unchanged."
2. **Preview, nothing imported yet:** counts per source, a few sample entries with dates, and a left-out list with reasons. Reasons include unreadable, no words, another account's data, unclear ownership, and practice images that weren't backed up.
3. **Copy into this journal:** one transaction, reusing batch C's tested import. It keeps original dates and earlier-app labels, and records receipts keyed by earlier IDs, so re-running never duplicates.
4. **After copying:** the user chooses **Stay signed in** (to re-check later) or **Sign out** (recommended). Nothing syncs either way. The local journal never uploads.

**Sign-out** clears the session and the in-memory preview. Copied entries stay; they're now the person's local entries. **Delete all** removes local data only; it never touches the account or the cloud backup.

**Offline:** Log in and the cloud preview say plainly that they need a connection. Local copying from that uid's on-device data works without one; whatever couldn't be checked is named. The guest journal itself never needs a network.

**Password reset:** the Firebase reset email, using the approved preview states: "Check your email", an expired or invalid link, and Back to Log in. The in-app message never reveals whether an email has an account.

## What stays local, and privacy wording

- Everything copied lives only in the local SwiftData store. There is no automatic sync, upload or cloud AI.
- Privacy wording, before the person types anything:
  > Logging in only lets CircleU fetch your earlier journal from your account so you can copy it here. Nothing new is uploaded.
- Settings shows the signed-in state and a Sign out button.
- Logs and analytics hold no content. Only counts are recorded.

## Firebase configuration and project boundaries

- Reuse `FirebaseAuthService`/`LiveFirebaseAuthClient` (email/password `signIn` only), plus the Firestore backup reader.
- The guest build must still construct **no** Firebase service until the person taps Log in. The existing test `testGuestStartupDoesNotConstructCloudServices` stays green.
- **Dev and Prod are separate.** Debug builds and the CircleU Guest Test app use the **Dev** project. Release uses the project the shipped app used.
  - Configuration lives in `GoogleService-Info.plist`, which stays out of the repo, as now.
  - Dev and Prod are never merged, and users are never copied between projects.
- Which project holds Mike's and testers' real accounts is unverified. See [legacy inventory](../../engineering/legacy-data-inventory.md) and decision 4.

## App Review and policy risks

- **Guideline 4.8 (Sign in with Apple):** not triggered. There is only email/password for existing accounts, with no third-party or social login.
- **Guideline 5.1.1(v) (account deletion):** if the app lets people log in to an account, it must also let them **start deleting the account in the app**.
  - The original app has `deleteAccount()`.
  - Scope it to the account and its cloud backup, with reauthentication and a clear statement that local entries are kept.
  - Decision 3.
- **Data:** the privacy label and privacy policy must cover email, and the backup content fetched on request.

## Tests and review

- **Unit tests with a fake auth client and a fake Firestore reader:**
  - Sign-in success, wrong password, offline, and too many attempts.
  - Only that uid's sources are read: other uids and unsuffixed data are never decoded.
  - Merge by ID, keeping the newest.
  - Idempotent re-import.
  - Rejected-record counts.
  - Sign-out clears state but keeps copied entries.
  - Delete all keeps the account.
- **Startup isolation:** no Firebase construction in the guest app before Log in.
- **UI tests on the Simulator** against fakes: Log in → preview → copy → sign out, reset-request states, and offline.
- **One manual check:** Mike's own account on his iPhone, against the **Dev** project only.
- **Review:** the full local suite before every merge, plus one Codex pass per PR, as now.

## Decisions for Mike

1. **Scope of what can be brought in:** (a) the cloud backup plus that account's on-device data *(recommended)*; (b) the cloud backup only.
2. **Unsuffixed on-device data:** (a) keep it sealed permanently *(recommended)*; (b) after Log in, offer it with a clear "may include other accounts' data" choice per item.
3. **Account deletion in the app (needed by 5.1.1(v)):** (a) build it in the same batch *(recommended)*; (b) a later batch, before any App Store submission.
4. **Firebase project for the first phone test:** (a) Dev only *(recommended)*; (b) the shipped project, once its ownership and access are confirmed.
