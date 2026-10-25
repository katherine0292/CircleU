# Hidden guest-mode switch — first slice step 3

- Recorded: 2026-10-25 19:12:57 +11:00; Australia/Sydney.
- Agent / role: Claude (Claude Code).
- Status: PR open for Codex review and owner approval; not merged. Stacked on PR #10.
- Base revision and branch: `codex/guest-mode-switch` on `codex/journal-store-swiftdata`.
- Related record: [first-slice plan](../superpowers/plans/2026-10-25-first-slice-typed-capture-local-journal.md).

## Request and scope

Step 3 of the approved plan: a hidden developer switch that opens the new guest-local experience. It's off by default, not discoverable by TestFlight testers, skips Firebase, and leaves the existing app and legacy data unchanged.

## Work and outcome

- `Circleu/App/AppStartup.swift`: `.existingApp` (default) or `.guestJournal`, the latter only in DEBUG builds with the `-CircleUGuestMode` launch argument. Release (TestFlight/App Store) builds always start the existing app.
- `CircleuApp`: configures Firebase and analytics only for `.existingApp`; otherwise unchanged.
- `GuestRootView` opens only the SwiftData guest store (Application Support/GuestJournal) and shows loading, error with Try again, or the journal list. There's no write screen yet (step 4).

## Verification

- `xcodebuild test` with the CI signing config (Xcode 27.1, iPhone 17 / iOS 26.5): 123 passed, 1 device-only skipped. New `AppStartupTests` cover the default path, Release ignoring the switch, and guest mode without Firebase.
- Simulator (iPhone 18 Pro / iOS 27.0, CI build): with `-CircleUGuestMode` the app opens "Journal — Nothing saved yet."; without it, the existing Home screen appears.
- Not run: phone; save → lock → relaunch needs the write screen (step 4).

## Discussion and decisions

Codex review requested (read-only).

## Handoff

- Remaining work: Codex review; merge after PR #10; step 4 (Write + Journal detail/edit), which enables the first phone check.
- Owner: Mike.
