# Sign-in batch: optional Log in, cloud backup copy, password reset, Delete my account

- Recorded: 2026-10-26 05:00:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer), on Mike's Mac
- Status: completed; merged under the auto-merge rule; phone check pending
- Base revision and branch: `codex/guest-sign-in` from `main` at `8c00285`
- Related record / task / PR: [approved plan](../superpowers/plans/2026-10-26-optional-sign-in-earlier-journal.md); Mike's "approve plan"; [screenshots](../qa/screenshots/sign-in-2026-10-26)

## Request and scope

Build the approved plan with decisions 1a, 2a, 3a and 4a. Dev project only, guest app behind the switch, Prod untouched.

## Work and outcome

- **Log in** for existing email/password accounts only, with no sign-up. It's reached from Welcome or Settings → Earlier CircleU account.
- **Firebase:** a separate named app (`circleu-guest-recovery`), configured only when Log in is first used.
  - Dev only (`circleu-45651`), reusing the bundled Dev configuration under the app's own bundle ID. At Mike's request, no new console registration was needed.
  - A probe with an invented account showed the Dev key accepts the guest bundle, and email-enumeration protection is on.
  - Firestore uses a memory-only cache and server-only reads.
  - Release builds (Prod) report Log in as unavailable.
- **Recovery:** preview of the account's cloud backup only (journal and practice), with rejected records counted. Then a copy-only, one-transaction import.
  - Receipts are scoped to project, account and kind, so re-runs never duplicate.
  - Duplicates keep the latest edit.
  - The person is signed out after copying, or when leaving without copying.
  - A leftover session is always cleared first.
- **Safety:**
  - Messages are generic, backing off after repeated failures.
  - Late results after Cancel are undone.
  - Only one account action runs at a time.
- **Password reset:** Firebase's own email and page. "No account" looks like success; real service failures are reported generically.
- **Delete my account:**
  - A fresh log in first.
  - Then everything the account owns in the cloud: private backup, posts in any circle, memberships, and circles it created. A circle is kept, with the person removed, while other people's posts remain (the rules forbid deleting those), and the result says so.
  - Then the account itself, bound to the uid just logged in to.
  - Nothing is reported as done unless it was, and a retry finds whatever is left.
  - Local entries are kept.
- Two existing Firestore document decoders were made internal for reuse, with no behaviour change. Debug-only fakes are used for UI tests.

## Verification

- **Full local suite:** 243 passed, 0 failed, 1 skipped. Sign-in tests cover:
  - preview, copy and sign-out;
  - re-runs;
  - generic failures and backoff;
  - offline and unavailable;
  - Cancel racing a late log in;
  - one action at a time;
  - a failed session clear;
  - deletion success, partial failures and the kept-circle note;
  - scoped receipts and duplicates;
  - startup isolation.
- **Out-of-repo XCUITests** (iPhone 18 Pro / iOS 27.0), passed:
  - Welcome → Log in (wrong password, then the fake account) → preview → copy → signed out → Delete my account, with fakes;
  - one real Dev sign-in with an invented account, which got the generic "Check your email and password";
  - all earlier flows.
- **Not run:**
  - real account recovery and deletion against Dev (Mike's phone check, with an account he chooses);
  - deployed rules versus the repo's `firestore.rules`;
  - CI (manual by owner decision).

## Discussion and decisions

Codex logs: [round 1](2026-10-26-041000-codex-review-guest-sign-in-round-1.md), [round 2](2026-10-26-042000-codex-review-guest-sign-in-round-2.md), [round 3](2026-10-26-043000-codex-review-guest-sign-in-round-3.md).

- **Round 1:** 3 blockers (a late session; wrong-account deletion; orphaned circle content) and 4 should-fixes.
- **Round 2:** 2 blockers in circle cleanup.
- **Round 3:** 1 narrow blocker (membership in kept circles) and 3 should-fixes.
- All were fixed. The final round's fixes were small, so they were merged without another review, per the rule.

## Handoff

- Remaining work: Mike's phone check with an existing Dev account (he types the password on the phone).
- Owner: Mike
- Risks / unresolved questions:
  - deleting a real account is permanent, so test deletion with a throwaway account;
  - deleting circles scans every circle, which is fine at Dev scale;
  - replies and likes on others' posts aren't removed (disclosed).
