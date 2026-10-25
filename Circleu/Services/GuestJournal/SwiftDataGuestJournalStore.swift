import Foundation
import SwiftData

/// Version 1 of the guest journal schema. Add a new version plus a migration stage for changes;
/// backfill derived values such as `updatedAt` in that stage rather than relying on defaults.
nonisolated enum GuestJournalSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }
    static var models: [any PersistentModel.Type] { [Entry.self] }

    @Model final class Entry {
        @Attribute(.unique) var id: UUID
        var originalWords: String
        var revision: Int
        var createdAt: Date
        var updatedAt: Date

        init(id: UUID, originalWords: String, revision: Int, createdAt: Date, updatedAt: Date) {
            self.id = id
            self.originalWords = originalWords
            self.revision = revision
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }
}

nonisolated enum GuestJournalMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [GuestJournalSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}

/// Applies Data Protection to the store folder and every SQLite file (store, -wal, -shm).
/// `.completeUnlessOpen`: files can't be opened while the phone is locked, but an open
/// store can finish writing if the phone locks mid-save. Injectable so tests can observe it.
nonisolated struct GuestJournalFileProtection: Sendable {
    let apply: @Sendable (URL) throws -> Void

    static let completeUnlessOpen = GuestJournalFileProtection { url in
        try FileManager.default.setAttributes([.protectionKey: FileProtectionType.completeUnlessOpen],
                                              ofItemAtPath: url.path)
    }
}

/// SwiftData-backed guest journal. Actor isolation serializes every read-check-write, so two
/// edits can't both pass the revision check and overwrite each other.
@ModelActor
actor SwiftDataGuestJournalStore: GuestJournalStore {
    typealias Entry = GuestJournalSchemaV1.Entry

    private var storeURL: URL?
    private var protection: GuestJournalFileProtection?

    /// Opens (or, on first use, creates) the store in `directory`.
    /// A marker records that the store was set up, so a vanished store is an error, not a fresh start.
    static func open(directory: URL,
                     protection: GuestJournalFileProtection = .completeUnlessOpen) async throws -> SwiftDataGuestJournalStore {
        let fileManager = FileManager.default
        let storeURL = directory.appendingPathComponent("GuestJournal.store")
        let markerURL = directory.appendingPathComponent("GuestJournal.initialized")
        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        } catch {
            throw GuestJournalError.storeUnavailable("folder: \(error.localizedDescription)")
        }
        if fileManager.fileExists(atPath: markerURL.path), !fileManager.fileExists(atPath: storeURL.path) {
            throw GuestJournalError.storeMissing
        }
        let container: ModelContainer
        do {
            container = try ModelContainer(for: Schema(versionedSchema: GuestJournalSchemaV1.self),
                                           migrationPlan: GuestJournalMigrationPlan.self,
                                           configurations: ModelConfiguration(url: storeURL))
        } catch {
            throw GuestJournalError.storeUnavailable("open: \(error)")
        }
        if !fileManager.fileExists(atPath: markerURL.path) {
            guard fileManager.createFile(atPath: markerURL.path, contents: Data()) else {
                throw GuestJournalError.storeUnavailable("could not record store setup")
            }
        }
        try protectFiles(storeURL: storeURL, protection: protection)
        let store = SwiftDataGuestJournalStore(modelContainer: container)
        await store.remember(storeURL: storeURL, protection: protection)
        return store
    }

    func loadAll() throws -> [GuestJournalEntry] {
        let rows: [Entry]
        do {
            rows = try modelContext.fetch(FetchDescriptor<Entry>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]))
        } catch {
            throw GuestJournalError.storeUnavailable("read: \(error)")
        }
        return rows.map(Self.value)
    }

    func create(originalWords: String) throws -> GuestJournalEntry {
        let now = Date()
        let row = Entry(id: UUID(), originalWords: originalWords, revision: 0, createdAt: now, updatedAt: now)
        modelContext.insert(row)
        try commit()
        return Self.value(row)
    }

    func update(id: UUID, originalWords: String, expectedRevision: Int) throws -> GuestJournalEntry {
        guard let row = try fetch(id: id) else { throw GuestJournalError.notFound }
        guard row.revision == expectedRevision else {
            throw GuestJournalError.staleRevision(current: row.revision, expected: expectedRevision)
        }
        row.originalWords = originalWords
        row.revision += 1
        row.updatedAt = Date()
        try commit()
        return Self.value(row)
    }

    func delete(id: UUID) throws {
        guard let row = try fetch(id: id) else { throw GuestJournalError.notFound }
        modelContext.delete(row)
        try commit()
    }

    private func fetch(id: UUID) throws -> Entry? {
        do {
            return try modelContext.fetch(FetchDescriptor<Entry>(predicate: #Predicate { $0.id == id })).first
        } catch {
            throw GuestJournalError.storeUnavailable("read: \(error)") // Not `notFound`: the store is unreadable.
        }
    }

    private func commit() throws {
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw GuestJournalError.saveFailed("\(error)")
        }
        // The -wal/-shm sidecars can appear on first write; protect them as well. This is
        // best-effort: the data is already saved, and reporting a failed save here would make
        // the person save again and duplicate the entry. `open` applies protection strictly.
        if let storeURL, let protection {
            try? Self.protectFiles(storeURL: storeURL, protection: protection)
        }
    }

    private func remember(storeURL: URL, protection: GuestJournalFileProtection) {
        self.storeURL = storeURL
        self.protection = protection
    }

    private static func protectFiles(storeURL: URL, protection: GuestJournalFileProtection) throws {
        let candidates = [storeURL.deletingLastPathComponent(), storeURL,
                          URL(fileURLWithPath: storeURL.path + "-wal"),
                          URL(fileURLWithPath: storeURL.path + "-shm")]
        for url in candidates where FileManager.default.fileExists(atPath: url.path) {
            do { try protection.apply(url) } catch {
                throw GuestJournalError.storeUnavailable("protection: \(error.localizedDescription)")
            }
        }
    }

    private static func value(_ row: Entry) -> GuestJournalEntry {
        GuestJournalEntry(id: row.id, originalWords: row.originalWords, revision: row.revision,
                          createdAt: row.createdAt, updatedAt: row.updatedAt)
    }
}
