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

/// Where the guest journal lives. The setup marker sits outside `directory`, so losing the whole
/// journal folder can't also erase the evidence that a journal existed.
nonisolated struct GuestJournalLocation: Sendable {
    let directory: URL
    let setupMarker: URL

    var storeURL: URL { directory.appendingPathComponent("GuestJournal.store") }
    var storeFiles: [URL] { ["", "-wal", "-shm"].map { URL(fileURLWithPath: storeURL.path + $0) } }

    /// Application Support/GuestJournal, separate from every legacy store and UserDefaults key.
    static func standard() throws -> GuestJournalLocation {
        let support = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask,
                                                  appropriateFor: nil, create: true)
        return GuestJournalLocation(directory: support.appendingPathComponent("GuestJournal", isDirectory: true),
                                    setupMarker: support.appendingPathComponent("GuestJournalSetup/initialized"))
    }
}

/// Applies Data Protection. `.completeUnlessOpen`: files can't be opened while the phone is
/// locked, but an already-open store can finish a save if the phone locks mid-write.
/// It doesn't revoke access to a store that is already open. Injectable so tests can observe it.
nonisolated struct GuestJournalFileProtection: Sendable {
    let apply: @Sendable (URL) throws -> Void

    static let completeUnlessOpen = GuestJournalFileProtection { url in
        try FileManager.default.setAttributes([.protectionKey: FileProtectionType.completeUnlessOpen],
                                              ofItemAtPath: url.path)
    }
}

/// Test-only failure hooks that run inside the real store's fetch and save paths.
nonisolated struct GuestJournalFaults: Sendable {
    var beforeFetch: @Sendable () throws -> Void = {}
    var beforeSave: @Sendable () throws -> Void = {}

    static let none = GuestJournalFaults()
}

/// SwiftData-backed guest journal. One instance owns each store location (see
/// `GuestJournalStoreRegistry`), and actor isolation serializes every read-check-write.
/// Access from another process (for example an extension) is not supported.
actor SwiftDataGuestJournalStore: GuestJournalStore, ModelActor {
    typealias Entry = GuestJournalSchemaV1.Entry

    nonisolated let modelExecutor: any ModelExecutor
    nonisolated let modelContainer: ModelContainer
    private let location: GuestJournalLocation
    private let protection: GuestJournalFileProtection
    private let faults: GuestJournalFaults

    /// Returns the single live store for `location`, opening it if needed.
    static func open(location: GuestJournalLocation,
                     protection: GuestJournalFileProtection = .completeUnlessOpen,
                     faults: GuestJournalFaults = .none) async throws -> SwiftDataGuestJournalStore {
        try await GuestJournalStoreRegistry.shared.store(for: location, protection: protection, faults: faults)
    }

    private init(container: ModelContainer, location: GuestJournalLocation,
                 protection: GuestJournalFileProtection, faults: GuestJournalFaults) {
        modelContainer = container
        modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(container))
        self.location = location
        self.protection = protection
        self.faults = faults
    }

    /// Synchronous so the registry can check and claim a location without an await in between.
    fileprivate static func make(location: GuestJournalLocation, protection: GuestJournalFileProtection,
                                 faults: GuestJournalFaults) throws -> SwiftDataGuestJournalStore {
        let wasSetUp = try itemExists(location.setupMarker)
        if wasSetUp, try !itemExists(location.storeURL) {
            throw GuestJournalError.storeMissing // Includes losing the whole journal folder.
        }
        do {
            try FileManager.default.createDirectory(at: location.directory, withIntermediateDirectories: true)
        } catch {
            throw GuestJournalError.storeUnavailable("folder: \(error.localizedDescription)")
        }
        // Protect the folder and any existing files before SQLite opens or migrates them.
        try protect(location, protection, includeFolder: true)

        let container: ModelContainer
        do {
            container = try ModelContainer(for: Schema(versionedSchema: GuestJournalSchemaV1.self),
                                           migrationPlan: GuestJournalMigrationPlan.self,
                                           configurations: ModelConfiguration(url: location.storeURL, cloudKitDatabase: .none))
        } catch {
            throw GuestJournalError.storeUnavailable("open: \(error)")
        }
        try protect(location, protection, includeFolder: false) // Files SQLite just created.

        if !wasSetUp {
            do {
                try FileManager.default.createDirectory(at: location.setupMarker.deletingLastPathComponent(),
                                                        withIntermediateDirectories: true)
                try Data().write(to: location.setupMarker, options: .atomic)
            } catch {
                throw GuestJournalError.storeUnavailable("could not record setup: \(error.localizedDescription)")
            }
        }
        return SwiftDataGuestJournalStore(container: container, location: location,
                                          protection: protection, faults: faults)
    }

    func loadAll() throws -> [GuestJournalEntry] {
        let descriptor = FetchDescriptor<Entry>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        return try fetch(descriptor).map(Self.value)
    }

    func create(originalWords: String) throws -> GuestJournalEntry {
        let now = Date()
        let row = Entry(id: UUID(), originalWords: originalWords, revision: 0, createdAt: now, updatedAt: now)
        modelContext.insert(row)
        try commit(entryID: row.id)
        return Self.value(row)
    }

    func update(id: UUID, originalWords: String, expectedRevision: Int) throws -> GuestJournalEntry {
        guard let row = try fetch(FetchDescriptor<Entry>(predicate: #Predicate { $0.id == id })).first else {
            throw GuestJournalError.notFound
        }
        guard row.revision == expectedRevision else {
            throw GuestJournalError.staleRevision(current: row.revision, expected: expectedRevision)
        }
        row.originalWords = originalWords
        row.revision += 1
        row.updatedAt = Date()
        try commit(entryID: id)
        return Self.value(row)
    }

    func delete(id: UUID) throws {
        guard let row = try fetch(FetchDescriptor<Entry>(predicate: #Predicate { $0.id == id })).first else {
            throw GuestJournalError.notFound
        }
        modelContext.delete(row)
        try commit(entryID: id)
    }

    /// Fetch errors are `storeUnavailable`, never `notFound`: an unreadable store isn't empty.
    private func fetch(_ descriptor: FetchDescriptor<Entry>) throws -> [Entry] {
        do {
            try faults.beforeFetch()
            return try modelContext.fetch(descriptor)
        } catch {
            throw GuestJournalError.storeUnavailable("read: \(error)")
        }
    }

    private func commit(entryID: UUID) throws {
        do {
            try faults.beforeSave()
            try modelContext.save()
        } catch {
            modelContext.rollback() // Previously committed data is unchanged.
            throw GuestJournalError.saveFailed("\(error)")
        }
        // SQLite can create -wal/-shm on first write. The change is already committed, so a
        // failure here is reported distinctly; a retry must not create the entry again.
        do {
            try Self.protect(location, protection, includeFolder: false)
        } catch {
            throw GuestJournalError.savedButUnprotected(entryID: entryID)
        }
    }

    private static func protect(_ location: GuestJournalLocation, _ protection: GuestJournalFileProtection,
                                includeFolder: Bool) throws {
        let candidates = (includeFolder ? [location.directory] : []) + location.storeFiles
        for url in candidates where try itemExists(url) {
            do { try protection.apply(url) } catch {
                throw GuestJournalError.protectionFailed(url.lastPathComponent)
            }
        }
    }

    /// Distinguishes "confirmed missing" from "couldn't check" (permissions, protection, I/O).
    private static func itemExists(_ url: URL) throws -> Bool {
        do {
            _ = try FileManager.default.attributesOfItem(atPath: url.path)
            return true
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile || error.code == .fileNoSuchFile {
            return false
        } catch {
            throw GuestJournalError.storeUnavailable("check \(url.lastPathComponent): \(error.localizedDescription)")
        }
    }

    private static func value(_ row: Entry) -> GuestJournalEntry {
        GuestJournalEntry(id: row.id, originalWords: row.originalWords, revision: row.revision,
                          createdAt: row.createdAt, updatedAt: row.updatedAt)
    }
}

/// Ensures one live owner per store location, so two callers can't open independent writers
/// on the same database. Holds stores weakly: a released store can be reopened later.
/// File-private with a private initializer: `SwiftDataGuestJournalStore.open` is the only way in.
fileprivate actor GuestJournalStoreRegistry {
    static let shared = GuestJournalStoreRegistry()

    private init() {}

    private struct WeakStore {
        weak var store: SwiftDataGuestJournalStore?
    }

    private var stores: [String: WeakStore] = [:]

    /// No suspension between checking and claiming a location, so concurrent opens share one store.
    func store(for location: GuestJournalLocation, protection: GuestJournalFileProtection,
               faults: GuestJournalFaults) throws -> SwiftDataGuestJournalStore {
        let key = location.directory.standardizedFileURL.resolvingSymlinksInPath().path
        if let existing = stores[key]?.store { return existing }
        let store = try SwiftDataGuestJournalStore.make(location: location, protection: protection, faults: faults)
        stores[key] = WeakStore(store: store)
        return store
    }
}
