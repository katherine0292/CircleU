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

/// Version 4 keeps unsaved drafts in the store too, so Delete all is one transaction.
nonisolated enum GuestJournalSchemaV4: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(4, 0, 0) }
    static var models: [any PersistentModel.Type] { [Entry.self, SavedDraft.self, PracticeMessage.self, KeptDraftRecord.self] }

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

    /// One unsaved draft per slot ("write", "practice"), kept until it's saved or cleared.
    @Model final class KeptDraftRecord {
        @Attribute(.unique) var slot: String
        var id: UUID
        var text: String
        var updatedAt: Date

        init(slot: String, id: UUID, text: String, updatedAt: Date) {
            self.slot = slot
            self.id = id
            self.text = text
            self.updatedAt = updatedAt
        }
    }
}


nonisolated enum GuestJournalSchemaV5: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(5, 0, 0) }
    static var models: [any PersistentModel.Type] { [Entry.self, SavedDraft.self, PracticeMessage.self, KeptDraftRecord.self] }

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
        var conversationData: Data?
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

    /// One unsaved draft per slot ("write", "practice"), kept until it's saved or cleared.
    @Model final class KeptDraftRecord {
        @Attribute(.unique) var slot: String
        var id: UUID
        var text: String
        var updatedAt: Date

        init(slot: String, id: UUID, text: String, updatedAt: Date) {
            self.slot = slot
            self.id = id
            self.text = text
            self.updatedAt = updatedAt
        }
    }
}


nonisolated enum GuestJournalMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [GuestJournalSchemaV1.self, GuestJournalSchemaV2.self, GuestJournalSchemaV3.self, GuestJournalSchemaV4.self, GuestJournalSchemaV5.self]
    }
    /// V1 → V2 adds a model and V2 → V3 adds optional fields, so lightweight stages keep every
    /// entry, saved draft and practice message.
    static var stages: [MigrationStage] {
        [.lightweight(fromVersion: GuestJournalSchemaV1.self, toVersion: GuestJournalSchemaV2.self),
         .lightweight(fromVersion: GuestJournalSchemaV2.self, toVersion: GuestJournalSchemaV3.self),
         .lightweight(fromVersion: GuestJournalSchemaV3.self, toVersion: GuestJournalSchemaV4.self),
         .lightweight(fromVersion: GuestJournalSchemaV4.self, toVersion: GuestJournalSchemaV5.self)]
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
actor SwiftDataGuestJournalStore: GuestJournalStore, GuestConversationStore, GuestReflectionStore, GuestDataStore,
    GuestImportStore, ModelActor {
    typealias Entry = GuestJournalSchemaV5.Entry
    typealias SavedDraft = GuestJournalSchemaV5.SavedDraft
    typealias PracticeMessage = GuestJournalSchemaV5.PracticeMessage
    typealias KeptDraftRecord = GuestJournalSchemaV5.KeptDraftRecord

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
            container = try ModelContainer(for: Schema(versionedSchema: GuestJournalSchemaV5.self),
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

    func snapshot() throws -> (entries: [GuestJournalEntry], messages: [GuestPracticeMessage]) {
        (try loadAll(), try loadPractice()) // One actor turn: nothing changes in between.
    }

    /// Draft files written by earlier builds, moved into the store once (see `adoptLegacyDraft`).
    static let legacyDraftFiles = ["Draft.json", "PracticeDraft.json"]
    private static let adoptedMarker = "legacy-adopted:"

    @discardableResult
    func deleteAll() throws -> Bool {
        // Read everything first, so a failed read can't leave deletions pending in the context.
        let entries = try fetch(FetchDescriptor<Entry>())
        let messages = try fetch(FetchDescriptor<PracticeMessage>())
        let receipts = try fetch(FetchDescriptor<SavedDraft>())
        let rows = try fetch(FetchDescriptor<KeptDraftRecord>())
        entries.forEach(modelContext.delete)
        messages.forEach(modelContext.delete)
        receipts.forEach(modelContext.delete)
        // Drafts go; "already adopted" markers stay (and are added), so an older draft file that
        // outlives this can never be imported again.
        let marked = Set(rows.filter { $0.slot.hasPrefix(Self.adoptedMarker) }.map(\.slot))
        rows.filter { !$0.slot.hasPrefix(Self.adoptedMarker) }.forEach(modelContext.delete)
        for name in Self.legacyDraftFiles where !marked.contains(Self.adoptedMarker + name) {
            modelContext.insert(KeptDraftRecord(slot: Self.adoptedMarker + name, id: UUID(), text: "", updatedAt: Date()))
        }
        do {
            try commit(entryID: UUID()) // One transaction, drafts included; rolled back on failure.
        } catch GuestJournalError.savedButUnprotected {
            // Committed: everything is deleted, so carry on and remove the older files too.
        }
        // Older draft files (readable or not) are removed too. True when nothing was left behind.
        var clean = true
        for name in Self.legacyDraftFiles {
            let url = location.directory.appendingPathComponent(name)
            guard FileManager.default.fileExists(atPath: url.path) else { continue }
            if (try? FileManager.default.removeItem(at: url)) == nil { clean = false }
        }
        return clean
    }

    func isLegacyDraftAdopted(_ name: String) throws -> Bool {
        let marker = Self.adoptedMarker + name
        return try !fetch(FetchDescriptor<KeptDraftRecord>(predicate: #Predicate { $0.slot == marker })).isEmpty
    }

    /// In one transaction: puts an older file's draft into `slot` unless the slot already has a
    /// newer one, and marks that file adopted so it's never imported again.
    func adoptLegacyDraft(slot: String, draft: KeptDraft?, legacyName: String) throws {
        let marker = Self.adoptedMarker + legacyName
        let existing = try fetch(FetchDescriptor<KeptDraftRecord>(predicate: #Predicate { $0.slot == slot })).first
        let isMarked = try !fetch(FetchDescriptor<KeptDraftRecord>(predicate: #Predicate { $0.slot == marker })).isEmpty
        if existing == nil, let draft, !draft.text.isEmpty {
            modelContext.insert(KeptDraftRecord(slot: slot, id: draft.id, text: draft.text, updatedAt: Date()))
        }
        if !isMarked { modelContext.insert(KeptDraftRecord(slot: marker, id: UUID(), text: "", updatedAt: Date())) }
        try commitDraft()
    }

    // MARK: Import from the earlier app

    func isImported(_ legacyID: UUID) throws -> Bool { try isDraftSaved(legacyID) }

    func importLegacy(entries: [GuestImportedEntry], messages: [GuestImportedMessage]) throws -> GuestImportResult {
        // Every read happens before any insert, so a failed read leaves nothing pending.
        let receipts: Set<UUID>
        do {
            try faults.beforeFetch()
            receipts = Set(try modelContext.fetch(FetchDescriptor<SavedDraft>()).map(\.id))
        } catch {
            throw GuestJournalError.storeUnavailable("read: \(error)")
        }
        var added = 0
        var seen = receipts
        // Receipts are the same "saved" records drafts use, keyed by the earlier app's IDs.
        let now = Date()
        for item in entries where seen.insert(item.legacyID).inserted {
            let row = Entry(id: UUID(), originalWords: item.originalWords, revision: 0,
                            createdAt: item.createdAt, updatedAt: item.updatedAt)
            Self.apply(item.reflection, nextStep: nil, nextStepDone: false, to: row)
            modelContext.insert(row)
            modelContext.insert(SavedDraft(id: item.legacyID, savedAt: now))
            added += 1
        }
        for item in messages where seen.insert(item.legacyID).inserted {
            modelContext.insert(PracticeMessage(id: UUID(), situation: item.situation, goal: "", wording: item.wording,
                                                sourceEntryID: nil, revision: 0,
                                                createdAt: item.createdAt, updatedAt: item.updatedAt))
            modelContext.insert(SavedDraft(id: item.legacyID, savedAt: now))
            added += 1
        }
        guard added > 0 else { return GuestImportResult(added: 0) }
        do {
            try commit(entryID: UUID()) // All or nothing; rolled back on failure.
        } catch GuestJournalError.savedButUnprotected {
            return GuestImportResult(added: added, isProtected: false) // Committed; say so.
        }
        return GuestImportResult(added: added)
    }

    // MARK: Kept drafts

    func keptDraft(slot: String) throws -> KeptDraft? {
        try fetch(FetchDescriptor<KeptDraftRecord>(predicate: #Predicate { $0.slot == slot })).first
            .map { KeptDraft(id: $0.id, text: $0.text, isProtected: true) } // Protected with the store.
    }

    /// Replaces the slot's draft; empty text removes it.
    func keepDraft(slot: String, id: UUID, text: String) throws {
        let existing = try fetch(FetchDescriptor<KeptDraftRecord>(predicate: #Predicate { $0.slot == slot })).first
        if text.isEmpty {
            guard let existing else { return }
            modelContext.delete(existing)
        } else if let existing {
            existing.id = id
            existing.text = text
            existing.updatedAt = Date()
        } else {
            modelContext.insert(KeptDraftRecord(slot: slot, id: id, text: text, updatedAt: Date()))
        }
        try commitDraft()
    }

    /// Removes the slot's draft only if it's still the one with this ID.
    func removeKeptDraft(slot: String, id: UUID) throws {
        guard let existing = try fetch(FetchDescriptor<KeptDraftRecord>(predicate: #Predicate { $0.slot == slot })).first,
              existing.id == id else { return }
        modelContext.delete(existing)
        try commitDraft()
    }

    private func commitDraft() throws {
        do {
            try commit(entryID: UUID())
        } catch GuestJournalError.savedButUnprotected {
            throw GuestJournalError.protectionFailed("draft") // Kept, but not fully secured.
        }
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
        try createPracticeRecord(situation: situation, goal: goal, wording: wording,
                                 sourceEntryID: sourceEntryID, draftID: draftID, conversation: nil)
    }

    func createConversation(situation: String, goal: String, wording: String, sourceEntryID: UUID?,
                            draftID: UUID?, conversation: GuestPracticeConversation) throws -> GuestPracticeMessage {
        try createPracticeRecord(situation: situation, goal: goal, wording: wording,
                                 sourceEntryID: sourceEntryID, draftID: draftID, conversation: conversation)
    }

    private func createPracticeRecord(situation: String, goal: String, wording: String, sourceEntryID: UUID?,
                                      draftID: UUID?, conversation: GuestPracticeConversation?) throws -> GuestPracticeMessage {
        let data = try conversation.map { try JSONEncoder().encode($0) }
        if let draftID, try isDraftSaved(draftID) { throw GuestJournalError.draftAlreadySaved }
        // Never link to an entry that no longer exists.
        if let sourceEntryID, try fetch(FetchDescriptor<Entry>(predicate: #Predicate { $0.id == sourceEntryID })).isEmpty {
            throw GuestJournalError.notFound
        }
        let now = Date()
        let row = PracticeMessage(id: UUID(), situation: situation, goal: goal, wording: wording,
                                  sourceEntryID: sourceEntryID, revision: 0, createdAt: now, updatedAt: now)
        row.conversationData = data
        modelContext.insert(row)
        if let draftID { modelContext.insert(SavedDraft(id: draftID, savedAt: now)) } // Same transaction.
        try commit(entryID: row.id)
        return try Self.value(row)
    }

    func updatePractice(id: UUID, situation: String, goal: String, wording: String,
                        expectedRevision: Int) throws -> GuestPracticeMessage {
        try updatePracticeRecord(id: id, situation: situation, goal: goal, wording: wording,
                                 expectedRevision: expectedRevision, conversation: nil)
    }

    func updateConversation(id: UUID, situation: String, goal: String, wording: String,
                            expectedRevision: Int, conversation: GuestPracticeConversation) throws -> GuestPracticeMessage {
        try updatePracticeRecord(id: id, situation: situation, goal: goal, wording: wording,
                                 expectedRevision: expectedRevision, conversation: conversation)
    }

    private func updatePracticeRecord(id: UUID, situation: String, goal: String, wording: String,
                                      expectedRevision: Int, conversation: GuestPracticeConversation?) throws -> GuestPracticeMessage {
        let data = try conversation.map { try JSONEncoder().encode($0) }
        guard let row = try fetch(FetchDescriptor<PracticeMessage>(predicate: #Predicate { $0.id == id })).first else {
            throw GuestJournalError.notFound
        }
        guard row.revision == expectedRevision else {
            throw GuestJournalError.staleRevision(current: row.revision, expected: expectedRevision)
        }
        _ = try Self.value(row) // Refuse to overwrite unreadable conversation data.
        if let data { row.conversationData = data }
        row.situation = situation
        row.goal = goal
        row.wording = wording
        row.revision += 1
        row.updatedAt = Date()
        try commit(entryID: id)
        return try Self.value(row)
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

    private static func value(_ row: PracticeMessage) throws -> GuestPracticeMessage {
        let conversation: GuestPracticeConversation?
        do {
            conversation = try row.conversationData.map { try JSONDecoder().decode(GuestPracticeConversation.self, from: $0) }
        } catch { throw GuestJournalError.storeUnavailable("Conversation could not be read") }
        return GuestPracticeMessage(id: row.id, situation: row.situation, goal: row.goal, wording: row.wording,
                             sourceEntryID: row.sourceEntryID, revision: row.revision,
                             createdAt: row.createdAt, updatedAt: row.updatedAt, conversation: conversation)
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
