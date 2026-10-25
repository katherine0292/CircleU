# Batch C: Welcome, and copying the earlier journal (sealed by default)

- Recorded: 2026-10-26 02:45:00 +11:00; Australia/Sydney
- Agent / role: Claude Code (implementer), on Mike's Mac
- Status: completed and merged under the auto-merge rule. Owner decision pending on whether and how to switch on the import.
- Base revision and branch: `codex/guest-import-welcome` from `main` at `723d078`
- Related record / task / PR: Mike's "import ok"; [legacy data format](../engineering/legacy-data-format.md); [screenshots](../qa/screenshots/import-welcome-2026-10-26)

## Request and scope

Mike approved the import with these conditions: copy only, preview first, never delete or modify old-app data or Firebase, idempotent, and report what was skipped and why. Also: Welcome wired into the guest app.

## Work and outcome

- **Welcome** on first launch (new key `circleu.guest.welcomeSeen.v1`):
  - **Get started** goes to Today.
  - **Log in** explains that accounts aren't in this version and offers the earlier journal.
- **Earlier CircleU app** section in Settings.
- **Import machinery:**
  - A read-only scan of the original app's on-device journal (`circleu.saved.reflections.v1`) and practice (`circleu.tipsPractice.sessions.v1`).
  - A preview that lists what's left out and why.
  - The copy is one transaction, with receipts keyed by the earlier IDs, so it is idempotent.
  - Original dates are kept. The earlier reflection is kept apart and labelled as from the earlier app. Practice becomes standalone messages.
  - Unsupported fields are disclosed.
  - The earlier data is never modified.
- **Privacy decision:**
  - Codex round 1: other accounts' buckets were readable. Fixed.
  - Round 2: on-device keys can hold an earlier account's data. Fixed by sealing whenever any sign-in history exists.
  - Round 3: a reinstall can restore an account's backup with no trace left, so nothing in the earlier data proves ownership.
  - **Decision:** by default nothing from the earlier app is shown or copied (`GuestLegacyImport.allowsUnverifiedOnDeviceImport = false`). The screen explains why. The tested copy path stays behind that switch.
- **Fixtures:** the Debug fixture writes to its own suite, never the real keys (also from round 1).
- **On Mike's phone:** CircleU Guest Test is a separate app (bundle `com.tuannm3812.circleu.guesttest`, no app group), so it can't read the original app's data in any case. The original app's exports are formatted text, not a structured file.

## Verification

- **Full local suite:** 232 passed, 0 failed, 1 skipped. Import tests run against fixtures written with the original app's own models and encoding:
  - sealed by default;
  - sign-in history seals;
  - unreadable buckets are reported;
  - guest-only mapping;
  - idempotence;
  - the earlier data is byte-for-byte untouched;
  - failed reads and saves add nothing.
- **Out-of-repo XCUITests** on a clean install, ten passed:
  - the sealed default;
  - Welcome → Log in → preview → copy, then a re-run copies nothing (with the switch on, Debug only);
  - all earlier flows.
- **Not run:**
  - real shipped-binary data;
  - a reinstall reproduction;
  - CI (manual by owner decision).

## Discussion and decisions

Codex logs: [round 1](2026-10-26-021000-codex-review-guest-import-round-1.md), [round 2](2026-10-26-022000-codex-review-guest-import-round-2.md), [round 3](2026-10-26-023000-codex-review-guest-import-round-3.md).

- Round 3's remaining blocker is resolved by the sealed default.
- Should-fixes not done:
  - Duplicate resolution within one bucket: first ID wins.
  - Journal, practice and draft receipts share one namespace. They are UUIDs, so a collision is practically impossible. Accepted.

## Handoff

- Remaining work: Mike decides how the earlier journal can be brought in:
  1. keep it sealed until account sign-in and recovery are built (recommended);
  2. allow it after the person confirms only they have used CircleU on this iPhone, accepting the residual risk;
  3. a machine-readable export from the original app.
- Owner: Mike
- Risks / unresolved questions: none for the default, which shows nothing.
