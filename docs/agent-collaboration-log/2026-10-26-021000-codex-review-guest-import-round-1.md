**2026-10-26 — Codex review — guest batch C — HEAD `1afb8ef`**

**Verdict: BLOCKED — three blockers.** Review-only; no files edited.

- **BLOCKER — Cross-account disclosure:** [GuestLegacyImport.swift:38](<../../Circleu/Services/GuestJournal/GuestLegacyImport.swift:38>) scans every `.user.<uid>` bucket, including practice at line 53. Any guest can preview/import another account’s private content. Restrict reads to verified ownership; keep other scopes sealed. Unsuffixed data also needs provenance handling.

- **BLOCKER — Fixture overwrites legacy data:** [GuestRootView.swift:43](<../../Circleu/Features/GuestJournal/GuestRootView.swift:43>) seeds `.standard`; [GuestLegacyImport.swift:145](<../../Circleu/Services/GuestJournal/GuestLegacyImport.swift:145>) unconditionally replaces original journal/practice keys. DEBUG and a launch argument do not protect an existing installation. Use an isolated fixture suite.

- **BLOCKER — Mid-import fetch failure escapes rollback:** [SwiftDataGuestJournalStore.swift:505](<../../Circleu/Services/GuestJournal/SwiftDataGuestJournalStore.swift:505>) performs throwing receipt reads between inserts. If a later read fails, earlier rows/receipts remain pending and a subsequent save can commit them despite “Nothing was added.” Preflight reads or roll back the entire operation. The failure test exercises only `beforeSave`.

- **SHOULD-FIX — Duplicate handling discards newer edits:** [GuestLegacyImport.swift:44](<../../Circleu/Services/GuestJournal/GuestLegacyImport.swift:44>) keeps the first UUID encountered in sorted buckets, regardless of modification date. An older—or empty—base record suppresses a newer valid account record without explanation. Resolve conflicts within authorized scopes before marking IDs seen.

- **SHOULD-FIX — Receipt identities collide:** [SwiftDataGuestJournalStore.swift:497](<../../Circleu/Services/GuestJournal/SwiftDataGuestJournalStore.swift:497>) treats draft receipts as import receipts. Matching IDs can silently skip imports or reject unrelated drafts as already saved. Journal/practice identities also share one namespace. Use scoped, typed import receipts with destination-ID mapping; destination IDs currently become fresh UUIDs.

- **SHOULD-FIX — Delete-all semantics need an explicit policy:** [SwiftDataGuestJournalStore.swift:450](<../../Circleu/Services/GuestJournal/SwiftDataGuestJournalStore.swift:450>) deletes import receipts, making all unchanged legacy records eligible again. Individual deletion retains receipts. Re-import requires another explicit action, but this inconsistent reset behavior needs disclosure and regression coverage.

- **SHOULD-FIX — Protection failure becomes ordinary success:** [SwiftDataGuestJournalStore.swift:524](<../../Circleu/Services/GuestJournal/SwiftDataGuestJournalStore.swift:524>) suppresses `savedButUnprotected`. Preserve committed receipts, but surface the protection warning instead of reporting unqualified success.

- **SHOULD-FIX — Incomplete omission reporting:** [GuestLegacyImport.swift:75](<../../Circleu/Services/GuestJournal/GuestLegacyImport.swift:75>) silently drops titles/tags and practice turns/coaching/custom-scene information. Disclose unsupported fields. [GuestImportAndWelcome.swift:114](<../../Circleu/Features/GuestJournal/GuestImportAndWelcome.swift:114>) says “see above” after replacing the preview and its skip reasons; retain the report.

- **SHOULD-FIX — Welcome overpromises:** [GuestImportAndWelcome.swift:192](<../../Circleu/Features/GuestJournal/GuestImportAndWelcome.swift:192>) says everything stays on this iPhone despite the documented device-backup/export exceptions. “Log in” opens information, not authentication. Make both claims accurately describe this guest build.

**Checked:** HEAD diff, surrounding stores/models/startup, tests and relevant guidance. Normal scanning is read-only; no new Firebase/network calls found. Hidden DEBUG gating remains. Selected records retain source timestamps. Welcome uses a separate flag, scrolling, scalable text and accessible decorative-art handling. `git diff --check HEAD^ HEAD` passed; working tree clean.

**Not checked:** build/XCTest execution, crash/cold-reopen behavior, actual network traffic, shipped legacy payloads, screenshots, live VoiceOver/Dynamic Type or physical devices. Inter-agent exchanges: none.