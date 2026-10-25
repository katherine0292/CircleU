**2026-10-26 — Codex review — guest sign-in, round 3 — `d0ca506`**

**Verdict: one NEW BLOCKER.** Reviewed `git show HEAD`, surrounding implementation/tests and `firestore.rules`. Working tree clean; no files edited or inter-agent exchanges.

- **NEW BLOCKER — retained circles retain membership despite successful deletion.** [GuestAccount.swift:263](<../../Circleu/Services/GuestJournal/GuestAccount.swift:263>): when the user created a circle containing others’ posts, cleanup only increments `keptCircles`; membership removal is exclusively in the `else` branch. Their UID remains in `memberUserIDs`, then Auth deletion and success proceed despite the explicit membership-removal promise. Rules permit the creator to remove it (`firestore.rules:62`). Remove membership from retained circles and propagate update failures before deleting Auth.

- **Previous BLOCKER — posts in previously left circles: resolved in source.** [GuestAccount.swift:242](<../../Circleu/Services/GuestJournal/GuestAccount.swift:242>) scans all existing circles and queries owned posts. Rules allow these reads and author deletion without membership (`firestore.rules:55,81,99`).

- **Previous BLOCKER — failed child cleanup becomes success on retry: resolved in source.** [GuestAccount.swift:253](<../../Circleu/Services/GuestJournal/GuestAccount.swift:253>) prevents parent mutation after failed post deletion; query failures also skip it. Failures throw, preserving discovery on retry.

- **SHOULD-FIX — cancellation gate: partially fixed.** [GuestSignIn.swift:201](<../../Circleu/Features/GuestJournal/GuestSignIn.swift:201>): first cancellation holds the gate, but changes `step` to `.form`; a second cancellation releases it while work remains pending. `pendingCancel` is never consulted, and `holdsGate` permits another login on that model (`:129`). Cancellation during receipt checks also reaches the bare return at `:154`, leaving the session and gate held. Settle cancellation consistently.

- **SHOULD-FIX — sign-out results: partially fixed.** [GuestSignIn.swift:160](<../../Circleu/Features/GuestJournal/GuestSignIn.swift:160>): the failure warning is immediately overwritten at `:169`. Deletion still discards the result at `:437`. Preserve/report both operation and sign-out failures.

- **SHOULD-FIX — equal-timestamp duplicates: partially fixed.** [GuestAccount.swift:105](<../../Circleu/Services/GuestJournal/GuestAccount.swift:105>): equal timestamps **and words** still select the first record even when reflection, situation or creation date differs. Use a deterministic tie-break covering the retained payload.

**Not checked:** builds/XCTest, emulator execution, Simulator/device behavior, deployed rules, live accounts, concurrent legacy writes or pre-existing orphaned post subcollections. Conclusions are static source review, not runtime verification.