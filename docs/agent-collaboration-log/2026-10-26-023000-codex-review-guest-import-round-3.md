**2026-10-26 — Codex review — guest batch C, round 3 — `90aa5a7`**

**Verdict: acceptable for a truly guest-only device, but HEAD cannot reliably establish that condition. One privacy BLOCKER remains.** Review-only; no files edited.

- **FIXED — Existing history markers seal content.** [GuestLegacyImport.swift:49](<../../Circleu/Services/GuestJournal/GuestLegacyImport.swift:49>) returns before decoding. The predicate covers every inspected `.user.` store, the cached UID, and local auth records. Ordinary logout retains `AuthStore.accounts`, so removing the current UID/session does not unlock content.

- **BLOCKER remains — Concrete pre-scoping reinstall/restore bypass.** [GuestLegacyImport.swift:93](<../../Circleu/Services/GuestJournal/GuestLegacyImport.swift:93>) treats absent defaults markers as absent history. In historical `1087b2c`, this sequence can defeat that assumption:
  1. Sign in and back up, then uninstall/reinstall the earlier app. Firebase credentials can survive in Keychain while app defaults disappear. [Apple DTS confirms this persistence behavior](https://developer.apple.com/forums/thread/36442).
  2. `BackendSessionStore.init` accepts the existing Firebase session without recreating `AuthStore` records. Its historical `wireBackendStores` writes no UID marker.
  3. Choose **Skip** on Welcome. `RootView` automatically calls `restorePrivateBackup`, which writes account content into unsuffixed stores.
  4. Upgrade directly to HEAD: none of the three marker families exists, so account content becomes previewable/importable.

  Evidence: historical [BackendSessionStore.swift:42](https://github.com/tuannm3812/CircleU/blob/1087b2c/Circleu/Stores/BackendSessionStore.swift#L42), [RootView.swift:205](https://github.com/tuannm3812/CircleU/blob/1087b2c/Circleu/App/RootView.swift#L205), and [ReflectionJournalStore.swift:8](https://github.com/tuannm3812/CircleU/blob/1087b2c/Circleu/Stores/ReflectionJournalStore.swift#L8). This is a source-traced defect, not a device reproduction. Keep ambiguous unsuffixed content sealed until positive provenance is available.

**Checked:** `git show HEAD`, historical/current auth, scoped stores, restore/startup paths, import UI and tests; whitespace check passed, working tree clean.

**Not checked:** XCTest/build, simulator/device reinstall reproduction, actual shipped TestFlight binary, real backups or deployed Firebase. No inter-agent exchanges.