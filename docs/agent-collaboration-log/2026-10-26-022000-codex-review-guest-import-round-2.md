**2026-10-26 — Codex review, Round 2 — guest batch C — `8749737`**

**Verdict: one remaining privacy BLOCKER.** Review-only; no files edited. Statuses below reflect static inspection.

| Round 1 finding | HEAD status |
|---|---|
| Cross-account buckets read | **PARTIAL / BLOCKER:** `.user.<uid>` buckets excluded; unsuffixed historical account data remains exposed—details below. |
| DEBUG fixture overwrites legacy keys | **Addressed:** dedicated defaults suite and import source. [GuestRootView.swift:43](<Circleu/Features/GuestJournal/GuestRootView.swift:43>) |
| Mid-import fetch failure escapes rollback | **Addressed:** receipt fetch precedes all inserts; commit failures roll back. Regression test added. [SwiftDataGuestJournalStore.swift:499](<Circleu/Services/GuestJournal/SwiftDataGuestJournalStore.swift:499>) |
| Duplicate resolution | **SHOULD-FIX remains:** first UUID wins before mapping; an empty/older record can suppress a valid/newer duplicate. Cross-bucket case removed. [GuestLegacyImport.swift:59](<Circleu/Services/GuestJournal/GuestLegacyImport.swift:59>) |
| Receipt namespace collisions | **SHOULD-FIX remains:** journal, practice and guest-draft receipts still share bare UUID identity. Separate source/type namespaces. [SwiftDataGuestJournalStore.swift:497](<Circleu/Services/GuestJournal/SwiftDataGuestJournalStore.swift:497>) |
| Delete-all re-import policy | **Addressed in disclosure:** explicitly permits later manual re-import; receipts are deleted. [GuestImportAndWelcome.swift:155](<Circleu/Features/GuestJournal/GuestImportAndWelcome.swift:155>) |
| Protection warning | **Addressed:** committed-but-unprotected result reaches the visible warning. [GuestImportAndWelcome.swift:113](<Circleu/Features/GuestJournal/GuestImportAndWelcome.swift:113>) |
| Omission reporting | **PARTIAL / SHOULD-FIX:** skip reasons persist after copying, but omitted user conversation turns and image attachments remain undisclosed; “practice coaching” does not cover them. [GuestImportAndWelcome.swift:155](<Circleu/Features/GuestJournal/GuestImportAndWelcome.swift:155>), [GuestLegacyImport.swift:105](<Circleu/Services/GuestJournal/GuestLegacyImport.swift:105>) |
| Welcome overpromise | **Addressed:** removes “Everything stays on this iPhone.” [GuestImportAndWelcome.swift:209](<Circleu/Features/GuestJournal/GuestImportAndWelcome.swift:209>) |

- **Remaining BLOCKER — unsuffixed does not establish guest ownership.** [GuestLegacyImport.swift:53](<Circleu/Services/GuestJournal/GuestLegacyImport.swift:53>) and `:68` still decode unsuffixed keys for unauthenticated preview/import. At historical `1087b2c`, `BackendSessionStore.restorePrivateBackup` merges authenticated account backups into stores using those exact keys. An upgrade containing account A’s restored data therefore exposes it to the current guest before copying. Preserve ambiguous buckets without content preview until provenance is established; see [legacy-data-format.md:68](<docs/engineering/legacy-data-format.md:68>). Actual shipped-build provenance remains unverified.

- **NEW NIT — bucket count labelled as account count.** One UID with journal and practice buckets displays “2 accounts.” Count distinct suffixes or say “account data collections.” [GuestLegacyImport.swift:46](<Circleu/Services/GuestJournal/GuestLegacyImport.swift:46>)

**Checked:** `git show HEAD`, surrounding import/transaction/deletion code, tests, relevant plans/logs and historical ownership paths. `git diff --check HEAD^ HEAD` exited 0; working tree clean.

**Not checked:** build/XCTest execution, Simulator/UI, physical-device protection, crash/cold-reopen behavior, real legacy payloads or deployed Firebase. No inter-agent exchanges. Remaining work: ownership isolation and SHOULD-FIX items; owner unassigned.