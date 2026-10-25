import Foundation
import os
import SwiftData
import XCTest
@testable import Circleu

/// Fails the next save on demand, inside the real store's save path.
private final class SaveFault: Sendable {
    private let fail = OSAllocatedUnfairLock(initialState: false)
    func set(_ value: Bool) { fail.withLock { $0 = value } }
    var faults: GuestJournalFaults {
        GuestJournalFaults(beforeSave: { [fail] in if fail.withLock({ $0 }) { throw CocoaError(.fileWriteOutOfSpace) } })
    }
}

final class GuestPracticeStoreTests: XCTestCase {
    private var root: URL!
    private var location: GuestJournalLocation!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("GuestPracticeTests-\(UUID())")
        location = GuestJournalLocation(directory: root.appendingPathComponent("Journal"),
                                        setupMarker: root.appendingPathComponent("Setup/initialized"))
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: root)
    }

    private func open(faults: GuestJournalFaults = .none) async throws -> SwiftDataGuestJournalStore {
        try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in }, faults: faults)
    }

    func testStandaloneAndLinkedMessagesSurviveReopen() async throws {
        var store: SwiftDataGuestJournalStore? = try await open()
        let entry = try await store!.create(originalWords: "My groupmate missed the deadline.")
        let standalone = try await store!.createPractice(situation: "Team chat", goal: "Be clear",
                                                         wording: "Can we split the next part?", sourceEntryID: nil)
        let linked = try await store!.createPractice(situation: "", goal: "", wording: "Hey, can we talk?",
                                                     sourceEntryID: entry.id)
        store = nil

        let reopened = try await open()
        let messages = try await reopened.loadPractice()
        XCTAssertEqual(Set(messages.map(\.id)), [standalone.id, linked.id])
        XCTAssertNil(messages.first { $0.id == standalone.id }?.sourceEntryID)
        XCTAssertEqual(messages.first { $0.id == linked.id }?.sourceEntryID, entry.id)
        XCTAssertEqual(messages.first { $0.id == standalone.id }?.goal, "Be clear")
        let entries = try await reopened.loadAll()
        XCTAssertEqual(entries.count, 1, "practice is separate from journal entries")
    }

    func testCannotLinkToAMissingEntry() async throws {
        let store = try await open()
        do {
            _ = try await store.createPractice(situation: "", goal: "", wording: "Hi", sourceEntryID: UUID())
            XCTFail("expected notFound")
        } catch {
            XCTAssertEqual(error as? GuestJournalError, .notFound)
        }
        let messages = try await store.loadPractice()
        XCTAssertEqual(messages, [])
    }

    func testEditUsesRevisionAndRejectsStaleEdits() async throws {
        let store = try await open()
        let message = try await store.createPractice(situation: "", goal: "", wording: "First", sourceEntryID: nil)
        let edited = try await store.updatePractice(id: message.id, situation: "", goal: "", wording: "Second",
                                                    expectedRevision: 0)
        XCTAssertEqual(edited.revision, 1)
        XCTAssertEqual(edited.id, message.id)
        do {
            _ = try await store.updatePractice(id: message.id, situation: "", goal: "", wording: "Stale",
                                               expectedRevision: 0)
            XCTFail("expected staleRevision")
        } catch {
            XCTAssertEqual(error as? GuestJournalError, .staleRevision(current: 1, expected: 0))
        }
        try await store.deletePractice(id: message.id)
        do {
            _ = try await store.updatePractice(id: message.id, situation: "", goal: "", wording: "Back?",
                                               expectedRevision: 1)
            XCTFail("an edit must not bring back a deleted message")
        } catch {
            XCTAssertEqual(error as? GuestJournalError, .notFound)
        }
    }

    func testDeletingAnEntryCanKeepItsMessageOnItsOwn() async throws {
        var store: SwiftDataGuestJournalStore? = try await open()
        let entry = try await store!.create(originalWords: "Source")
        let message = try await store!.createPractice(situation: "", goal: "", wording: "Kept", sourceEntryID: entry.id)
        try await store!.deleteEntry(id: entry.id, linkedPractice: .keepMessages)
        store = nil

        let reopened = try await open()
        let entries = try await reopened.loadAll()
        let messages = try await reopened.loadPractice()
        XCTAssertEqual(entries, [])
        XCTAssertEqual(messages.map(\.id), [message.id])
        XCTAssertNil(messages.first?.sourceEntryID, "now on its own")
    }

    func testDeletingAnEntryCanDeleteBoth() async throws {
        let store = try await open()
        let entry = try await store.create(originalWords: "Source")
        _ = try await store.createPractice(situation: "", goal: "", wording: "Linked", sourceEntryID: entry.id)
        let other = try await store.createPractice(situation: "", goal: "", wording: "Unrelated", sourceEntryID: nil)
        try await store.deleteEntry(id: entry.id, linkedPractice: .deleteBoth)
        let entries = try await store.loadAll()
        let messages = try await store.loadPractice()
        XCTAssertEqual(entries, [])
        XCTAssertEqual(messages.map(\.id), [other.id], "only the linked message goes")
    }

    func testFailedEntryDeleteKeepsEntryAndMessage() async throws {
        let fault = SaveFault()
        var store: SwiftDataGuestJournalStore? = try await open(faults: fault.faults)
        let entry = try await store!.create(originalWords: "Source")
        let message = try await store!.createPractice(situation: "", goal: "", wording: "Linked", sourceEntryID: entry.id)
        fault.set(true)
        do {
            try await store!.deleteEntry(id: entry.id, linkedPractice: .deleteBoth)
            XCTFail("expected saveFailed")
        } catch {
            guard case .saveFailed = error as? GuestJournalError else { return XCTFail("got \(error)") }
        }
        let entriesNow = try await store!.loadAll()
        let messagesNow = try await store!.loadPractice()
        XCTAssertEqual(entriesNow.map(\.id), [entry.id])
        XCTAssertEqual(messagesNow.map(\.id), [message.id])
        XCTAssertEqual(messagesNow.first?.sourceEntryID, entry.id, "rolled back, still linked")
        fault.set(false)
        store = nil

        let reopened = try await open()
        let entries = try await reopened.loadAll()
        let messages = try await reopened.loadPractice()
        XCTAssertEqual(entries.map(\.id), [entry.id])
        XCTAssertEqual(messages.first?.sourceEntryID, entry.id)
    }

    func testVersionOneJournalMigratesWithEntriesAndSavedDrafts() async throws {
        // A store written by the first slice (schema V1), before Practice existed.
        let entryID = UUID()
        let draftID = UUID()
        try FileManager.default.createDirectory(at: location.directory, withIntermediateDirectories: true)
        do {
            let container = try ModelContainer(for: Schema(versionedSchema: GuestJournalSchemaV1.self),
                                               configurations: ModelConfiguration(url: location.storeURL,
                                                                                  cloudKitDatabase: .none))
            let context = ModelContext(container)
            let now = Date()
            context.insert(GuestJournalSchemaV1.Entry(id: entryID, originalWords: "Written before Practice",
                                                      revision: 2, createdAt: now, updatedAt: now))
            context.insert(GuestJournalSchemaV1.SavedDraft(id: draftID, savedAt: now))
            try context.save()
        }
        try FileManager.default.createDirectory(at: location.setupMarker.deletingLastPathComponent(),
                                                withIntermediateDirectories: true)
        try Data().write(to: location.setupMarker)

        let store = try await open()
        let entries = try await store.loadAll()
        XCTAssertEqual(entries.map(\.id), [entryID])
        XCTAssertEqual(entries.first?.originalWords, "Written before Practice")
        XCTAssertEqual(entries.first?.revision, 2)
        let draftStillSaved = try await store.isDraftSaved(draftID)
        XCTAssertTrue(draftStillSaved, "saved-draft receipts survive, so nothing is saved twice")
        let message = try await store.createPractice(situation: "", goal: "", wording: "New", sourceEntryID: entryID)
        XCTAssertEqual(message.sourceEntryID, entryID)
    }
}

/// In-memory practice store for the view-model tests.
private actor MemoryPracticeStore: GuestPracticeStore {
    var messages: [GuestPracticeMessage] = []
    var entryIDs: Set<UUID> = []
    var failNext: GuestJournalError?
    private(set) var writes = 0

    func fail(with error: GuestJournalError?) { failNext = error }
    func addEntry(_ id: UUID) { entryIDs.insert(id) }

    private func check() throws {
        if let failNext { self.failNext = nil; throw failNext }
    }

    func loadPractice() throws -> [GuestPracticeMessage] { messages.sorted { $0.updatedAt > $1.updatedAt } }

    func createPractice(situation: String, goal: String, wording: String,
                        sourceEntryID: UUID?) throws -> GuestPracticeMessage {
        try check()
        writes += 1
        let message = GuestPracticeMessage(id: UUID(), situation: situation, goal: goal, wording: wording,
                                           sourceEntryID: sourceEntryID, revision: 0, createdAt: Date(), updatedAt: Date())
        messages.append(message)
        return message
    }

    func updatePractice(id: UUID, situation: String, goal: String, wording: String,
                        expectedRevision: Int) throws -> GuestPracticeMessage {
        try check()
        guard let index = messages.firstIndex(where: { $0.id == id }) else { throw GuestJournalError.notFound }
        writes += 1
        let old = messages[index]
        let new = GuestPracticeMessage(id: id, situation: situation, goal: goal, wording: wording,
                                       sourceEntryID: old.sourceEntryID, revision: old.revision + 1,
                                       createdAt: old.createdAt, updatedAt: Date())
        messages[index] = new
        return new
    }

    func deletePractice(id: UUID) throws {
        try check()
        messages.removeAll { $0.id == id }
    }

    func deleteEntry(id: UUID, linkedPractice: GuestLinkedPracticeChoice) throws {
        try check()
        entryIDs.remove(id)
        switch linkedPractice {
        case .keepMessages:
            messages = messages.map { var m = $0; if m.sourceEntryID == id { m.sourceEntryID = nil }; return m }
        case .deleteBoth:
            messages.removeAll { $0.sourceEntryID == id }
        }
    }
}

/// Journal side for the entry-deletion flow.
private actor EmptyJournalStore: GuestJournalStore {
    func loadAll() throws -> [GuestJournalEntry] { [] }
    func create(originalWords: String, draftID: UUID?) throws -> GuestJournalEntry { throw GuestJournalError.notFound }
    func isDraftSaved(_ draftID: UUID) throws -> Bool { false }
    func update(id: UUID, originalWords: String, expectedRevision: Int) throws -> GuestJournalEntry {
        throw GuestJournalError.notFound
    }
    func delete(id: UUID) throws {}
}

@MainActor
final class GuestPracticeViewModelTests: XCTestCase {
    func testNewMessageNeedsWordingThenSavesAndShowsAsSaved() async {
        let store = MemoryPracticeStore()
        let composer = GuestPracticeComposerViewModel(store: store, sourceEntryID: nil)
        XCTAssertFalse(composer.canSave)
        composer.situation = "Group project"
        XCTAssertFalse(composer.canSave, "wording is required")
        composer.wording = "  Can we split the slides?  "
        XCTAssertTrue(composer.canSave)
        let saved = await composer.save()
        XCTAssertTrue(saved)
        XCTAssertFalse(composer.isEditing, "a saved message is shown with Copy as the main action")
        XCTAssertEqual(composer.saved?.wording, "Can we split the slides?")
        XCTAssertFalse(composer.canSave, "nothing new to save")
    }

    func testCopyDoesNotSave() async {
        let store = MemoryPracticeStore()
        let composer = GuestPracticeComposerViewModel(store: store, sourceEntryID: nil)
        composer.wording = "Hi, about Friday…"
        var clipboard: String?
        composer.copy { clipboard = $0 }
        XCTAssertEqual(clipboard, "Hi, about Friday…")
        XCTAssertTrue(composer.didCopy)
        XCTAssertNil(composer.saved)
        let writes = await store.writes
        XCTAssertEqual(writes, 0, "copying never saves")
        XCTAssertTrue(composer.canSave, "still unsaved")
    }

    func testFailedSaveKeepsWordsAndShowsError() async {
        let store = MemoryPracticeStore()
        await store.fail(with: .saveFailed("injected"))
        let composer = GuestPracticeComposerViewModel(store: store, sourceEntryID: nil)
        composer.goal = "Stay calm"
        composer.wording = "Keep these words"
        let saved = await composer.save()
        XCTAssertFalse(saved)
        XCTAssertEqual(composer.wording, "Keep these words")
        XCTAssertEqual(composer.goal, "Stay calm")
        XCTAssertTrue(composer.isEditing)
        XCTAssertEqual(composer.saveError, GuestPracticeComposerViewModel.saveFailedMessage)
    }

    func testEditingASavedMessageUpdatesTheSameMessage() async {
        let store = MemoryPracticeStore()
        let composer = GuestPracticeComposerViewModel(store: store, sourceEntryID: nil)
        composer.wording = "First"
        await composer.save()
        let id = composer.saved?.id
        composer.edit()
        composer.wording = "Second"
        await composer.save()
        XCTAssertEqual(composer.saved?.id, id)
        XCTAssertEqual(composer.saved?.revision, 1)
        let messages = await store.messages
        XCTAssertEqual(messages.count, 1, "edit, not a new message")
    }

    func testDeletedSourceEntryKeepsWords() async {
        let store = MemoryPracticeStore()
        await store.fail(with: .notFound)
        let composer = GuestPracticeComposerViewModel(store: store, sourceEntryID: UUID())
        composer.wording = "Still here"
        let saved = await composer.save()
        XCTAssertFalse(saved)
        XCTAssertEqual(composer.wording, "Still here")
        XCTAssertEqual(composer.saveError, GuestPracticeComposerViewModel.missingMessage)
    }

    func testEntryDeleteChoicesAndFailure() async {
        let store = MemoryPracticeStore()
        let entryID = UUID()
        await store.addEntry(entryID)
        let practice = GuestPracticeViewModel(store: store)
        let journal = GuestJournalViewModel(store: EmptyJournalStore())
        _ = try? await store.createPractice(situation: "", goal: "", wording: "Linked", sourceEntryID: entryID)
        await practice.load()
        XCTAssertEqual(practice.linkedMessages(to: entryID).count, 1)

        await store.fail(with: .saveFailed("injected"))
        let failure = await practice.deleteEntry(id: entryID, linkedPractice: .deleteBoth, journal: journal)
        XCTAssertEqual(failure, GuestPracticeViewModel.deleteFailedMessage)
        XCTAssertEqual(practice.linkedMessages(to: entryID).count, 1, "a failed delete keeps everything")

        let kept = await practice.deleteEntry(id: entryID, linkedPractice: .keepMessages, journal: journal)
        XCTAssertNil(kept)
        XCTAssertEqual(practice.messages.count, 1)
        XCTAssertNil(practice.messages.first?.sourceEntryID)
        XCTAssertEqual(GuestPracticeTag.label(sourceEntryID: practice.messages.first?.sourceEntryID, entries: []),
                       "On its own")
    }

    func testFailedMessageDeleteKeepsIt() async {
        let store = MemoryPracticeStore()
        let message = try? await store.createPractice(situation: "", goal: "", wording: "Keep", sourceEntryID: nil)
        let practice = GuestPracticeViewModel(store: store)
        await practice.load()
        await store.fail(with: .saveFailed("injected"))
        let result = await practice.deleteMessage(id: message!.id)
        XCTAssertEqual(result, GuestPracticeViewModel.deleteFailedMessage)
        XCTAssertEqual(practice.messages.map(\.id), [message!.id])
    }

    func testTagShowsSourceEntryOrOnItsOwn() {
        let entry = GuestJournalEntry(id: UUID(), originalWords: "My groupmate missed the deadline again and I froze",
                                      revision: 0, createdAt: Date(), updatedAt: Date())
        XCTAssertEqual(GuestPracticeTag.label(sourceEntryID: entry.id, entries: [entry]),
                       "From: My groupmate missed the deadline again a…")
        XCTAssertEqual(GuestPracticeTag.label(sourceEntryID: nil, entries: [entry]), "On its own")
    }
}
