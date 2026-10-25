import Foundation
import SwiftData

/// Version 1 of the guest journal schema. Add a new version plus a migration stage for changes;
/// backfill derived values such as `updatedAt` in that stage rather than relying on defaults.
nonisolated enum GuestJournalSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }
    static var models: [any PersistentModel.Type] { [Entry.self, SavedDraft.self] }

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

    /// A draft that was saved as an entry. Kept even if the entry is later edited or deleted, so a
    /// leftover draft file can be recognised and never saved twice.
    @Model final class SavedDraft {
        @Attribute(.unique) var id: UUID
        var savedAt: Date

        init(id: UUID, savedAt: Date) {
            self.id = id
            self.savedAt = savedAt
        }
    }
}

/// Version 2 adds practice messages. Entries and saved drafts are unchanged from version 1.
nonisolated enum GuestJournalSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(2, 0, 0) }
    static var models: [any PersistentModel.Type] { [Entry.self, SavedDraft.self, PracticeMessage.self] }

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

    @Model final class SavedDraft {
        @Attribute(.unique) var id: UUID
        var savedAt: Date

        init(id: UUID, savedAt: Date) {
            self.id = id
            self.savedAt = savedAt
        }
    }

    /// Wording practised in Practice. Saved here only; never sent anywhere.
    @Model final class PracticeMessage {
        @Attribute(.unique) var id: UUID
        var situation: String
        var goal: String
        var wording: String
        /// The journal entry it was practised from; nil when it stands on its own.
        var sourceEntryID: UUID?
        var revision: Int
        var createdAt: Date
        var updatedAt: Date

        init(id: UUID, situation: String, goal: String, wording: String, sourceEntryID: UUID?,
             revision: Int, createdAt: Date, updatedAt: Date) {
            self.id = id
            self.situation = situation
            self.goal = goal
            self.wording = wording
            self.sourceEntryID = sourceEntryID
            self.revision = revision
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }
}

/// Version 3 adds an optional reflection and next step to entries (all optional, so the
/// lightweight stage leaves existing entries without one).
nonisolated enum GuestJournalSchemaV3: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(3, 0, 0) }
    static var models: [any PersistentModel.Type] { [Entry.self, SavedDraft.self, PracticeMessage.self] }

    @Model final class Entry {
        @Attribute(.unique) var id: UUID
        var originalWords: String
        var revision: Int
        var createdAt: Date
        var updatedAt: Date
        /// A suggestion the person accepted (and may have edited); nil when they saved only their words.
        var reflectionSummary: String?
        var reflectionFeeling: String?
        var reflectionInsight: String?
        /// `GuestSuggestionSource.rawValue`: on-device model or guided prompts.
        var reflectionSource: String?
        var reflectionBasedOn: String?
        /// One optional next step; done is voluntary and reversible.
        var nextStep: String?
        var nextStepDoneAt: Date?

        init(id: UUID, originalWords: String, revision: Int, createdAt: Date, updatedAt: Date) {
            self.id = id
            self.originalWords = originalWords
            self.revision = revision
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }

    @Model final class SavedDraft {
        @Attribute(.unique) var id: UUID
        var savedAt: Date

        init(id: UUID, savedAt: Date) {
            self.id = id
            self.savedAt = savedAt
        }
    }

    /// Wording practised in Practice. Saved here only; never sent anywhere.
    @Model final class PracticeMessage {
        @Attribute(.unique) var id: UUID
        var situation: String
        var goal: String
        var wording: String
        /// The journal entry it was practised from; nil when it stands on its own.
        var sourceEntryID: UUID?
        var revision: Int
        var createdAt: Date
        var updatedAt: Date

        init(id: UUID, situation: String, goal: String, wording: String, sourceEntryID: UUID?,
             revision: Int, createdAt: Date, updatedAt: Date) {
            self.id = id
            self.situation = situation
            self.goal = goal
            self.wording = wording
            self.sourceEntryID = sourceEntryID
            self.revision = revision
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }
}

nonisolated enum GuestJournalMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [GuestJournalSchemaV1.self, GuestJournalSchemaV2.self, GuestJournalSchemaV3.self]
    }
    /// V1 → V2 adds a model and V2 → V3 adds optional fields, so lightweight stages keep every
    /// entry, saved draft and practice message.
    static var stages: [MigrationStage] {
        [.lightweight(fromVersion: GuestJournalSchemaV1.self, toVersion: GuestJournalSchemaV2.self),
         .lightweight(fromVersion: GuestJournalSchemaV2.self, toVersion: GuestJournalSchemaV3.self)]
    }
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
actor SwiftDataGuestJournalStore: GuestJournalStore, GuestPracticeStore, GuestReflectionStore, GuestDataStore,
    ModelActor {
    typealias Entry = GuestJournalSchemaV3.Entry
    typealias SavedDraft = GuestJournalSchemaV3.SavedDraft
    typealias PracticeMessage = GuestJournalSchemaV3.PracticeMessage

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
            container = try ModelContainer(for: Schema(versionedSchema: GuestJournalSchemaV3.self),
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

    func create(originalWords: String, draftID: UUID?) throws -> GuestJournalEntry {
        try create(originalWords: originalWords, draftID: draftID, reflection: nil, nextStep: nil)
    }

    func create(originalWords: String, draftID: UUID?, reflection: GuestReflection?,
                nextStep: String?) throws -> GuestJournalEntry {
        if let draftID, try isDraftSaved(draftID) { throw GuestJournalError.draftAlreadySaved }
        let now = Date()
        let row = Entry(id: UUID(), originalWords: originalWords, revision: 0, createdAt: now, updatedAt: now)
        Self.apply(reflection, nextStep: nextStep, nextStepDone: false, to: row)
        modelContext.insert(row)
        if let draftID { modelContext.insert(SavedDraft(id: draftID, savedAt: now)) } // Same transaction.
        try commit(entryID: row.id)
        return Self.value(row)
    }

    func isDraftSaved(_ draftID: UUID) throws -> Bool {
        do {
            try faults.beforeFetch()
            return try !modelContext.fetch(FetchDescriptor<SavedDraft>(predicate: #Predicate { $0.id == draftID })).isEmpty
        } catch {
            throw GuestJournalError.storeUnavailable("read: \(error)")
        }
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

    func updateReflection(id: UUID, reflection: GuestReflection?, nextStep: String?, nextStepDone: Bool,
                          expectedRevision: Int) throws -> GuestJournalEntry {
        guard let row = try fetch(FetchDescriptor<Entry>(predicate: #Predicate { $0.id == id })).first else {
            throw GuestJournalError.notFound
        }
        guard row.revision == expectedRevision else {
            throw GuestJournalError.staleRevision(current: row.revision, expected: expectedRevision)
        }
        Self.apply(reflection, nextStep: nextStep, nextStepDone: nextStepDone, to: row)
        row.revision += 1
        row.updatedAt = Date()
        try commit(entryID: id)
        return Self.value(row)
    }

    private static func apply(_ reflection: GuestReflection?, nextStep: String?, nextStepDone: Bool, to row: Entry) {
        row.reflectionSummary = reflection?.summary
        row.reflectionFeeling = reflection?.feeling
        row.reflectionInsight = reflection?.insight
        row.reflectionSource = reflection?.source.rawValue
        row.reflectionBasedOn = reflection?.basedOnWords
        row.nextStep = nextStep
        row.nextStepDoneAt = nextStep != nil && nextStepDone ? (row.nextStepDoneAt ?? Date()) : nil
    }

    func deleteAll() throws {
        // Read everything first, so a failed read can't leave deletions pending in the context.
        let entries = try fetch(FetchDescriptor<Entry>())
        let messages = try fetch(FetchDescriptor<PracticeMessage>())
        let receipts = try fetch(FetchDescriptor<SavedDraft>())
        entries.forEach(modelContext.delete)
        messages.forEach(modelContext.delete)
        receipts.forEach(modelContext.delete)
        try commit(entryID: UUID()) // One transaction; rolled back on failure.
    }

    func delete(id: UUID) throws {
        guard let row = try fetch(FetchDescriptor<Entry>(predicate: #Predicate { $0.id == id })).first else {
            throw GuestJournalError.notFound
        }
        modelContext.delete(row)
        try commit(entryID: id)
    }

    // MARK: Practice

    func loadPractice() throws -> [GuestPracticeMessage] {
        try fetch(FetchDescriptor<PracticeMessage>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]))
            .map(Self.value)
    }

    func createPractice(situation: String, goal: String, wording: String, sourceEntryID: UUID?,
                        draftID: UUID?) throws -> GuestPracticeMessage {
        if let draftID, try isDraftSaved(draftID) { throw GuestJournalError.draftAlreadySaved }
        // Never link to an entry that no longer exists.
        if let sourceEntryID, try fetch(FetchDescriptor<Entry>(predicate: #Predicate { $0.id == sourceEntryID })).isEmpty {
            throw GuestJournalError.notFound
        }
        let now = Date()
        let row = PracticeMessage(id: UUID(), situation: situation, goal: goal, wording: wording,
                                  sourceEntryID: sourceEntryID, revision: 0, createdAt: now, updatedAt: now)
        modelContext.insert(row)
        if let draftID { modelContext.insert(SavedDraft(id: draftID, savedAt: now)) } // Same transaction.
        try commit(entryID: row.id)
        return Self.value(row)
    }

    func updatePractice(id: UUID, situation: String, goal: String, wording: String,
                        expectedRevision: Int) throws -> GuestPracticeMessage {
        guard let row = try fetch(FetchDescriptor<PracticeMessage>(predicate: #Predicate { $0.id == id })).first else {
            throw GuestJournalError.notFound
        }
        guard row.revision == expectedRevision else {
            throw GuestJournalError.staleRevision(current: row.revision, expected: expectedRevision)
        }
        row.situation = situation
        row.goal = goal
        row.wording = wording
        row.revision += 1
        row.updatedAt = Date()
        try commit(entryID: id)
        return Self.value(row)
    }

    func deletePractice(id: UUID) throws {
        guard let row = try fetch(FetchDescriptor<PracticeMessage>(predicate: #Predicate { $0.id == id })).first else {
            throw GuestJournalError.notFound
        }
        modelContext.delete(row)
        try commit(entryID: id)
    }

    func deleteEntry(id: UUID, linkedPractice: GuestLinkedPracticeChoice) throws {
        guard let entry = try fetch(FetchDescriptor<Entry>(predicate: #Predicate { $0.id == id })).first else {
            throw GuestJournalError.notFound
        }
        let linked = try fetch(FetchDescriptor<PracticeMessage>(predicate: #Predicate { $0.sourceEntryID == id }))
        for message in linked {
            switch linkedPractice {
            case .keepMessages: message.sourceEntryID = nil // Kept, now on its own.
            case .deleteBoth: modelContext.delete(message)
            }
        }
        modelContext.delete(entry)
        try commit(entryID: id) // One transaction: all of it, or none of it.
    }

    /// Fetch errors are `storeUnavailable`, never `notFound`: an unreadable store isn't empty.
    private func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) throws -> [T] {
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

    private static func value(_ row: PracticeMessage) -> GuestPracticeMessage {
        GuestPracticeMessage(id: row.id, situation: row.situation, goal: row.goal, wording: row.wording,
                             sourceEntryID: row.sourceEntryID, revision: row.revision,
                             createdAt: row.createdAt, updatedAt: row.updatedAt)
    }

    private static func value(_ row: Entry) -> GuestJournalEntry {
        let reflection = row.reflectionSource.flatMap(GuestSuggestionSource.init(rawValue:)).map { source in
            GuestReflection(summary: row.reflectionSummary ?? "", feeling: row.reflectionFeeling ?? "",
                            insight: row.reflectionInsight ?? "", source: source,
                            basedOnWords: row.reflectionBasedOn ?? row.originalWords)
        }
        return GuestJournalEntry(id: row.id, originalWords: row.originalWords, revision: row.revision,
                                 createdAt: row.createdAt, updatedAt: row.updatedAt, reflection: reflection,
                                 nextStep: row.nextStep, nextStepDone: row.nextStepDoneAt != nil)
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
