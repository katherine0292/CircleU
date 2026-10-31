import XCTest
import SwiftData
import os
@testable import Circleu

@MainActor
final class GuestEntryTagTests: XCTestCase {
    private var root: URL!
    private var location: GuestJournalLocation!
    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        location = GuestJournalLocation(directory: root.appendingPathComponent("Journal"),
                                        setupMarker: root.appendingPathComponent("Setup/initialized"))
    }
    override func tearDownWithError() throws { try? FileManager.default.removeItem(at: root) }
    private func open(faults: GuestJournalFaults = .none) async throws -> SwiftDataGuestJournalStore {
        try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in }, faults: faults)
    }

    func testTagsSurviveReopenAndWordEditsAndCanBeClearedIndependently() async throws {
        let id: UUID
        do {
            let store = try await open()
            let entry = try await store.create(originalWords: "My own words")
            id = entry.id
            XCTAssertNil(entry.context)
            XCTAssertNil(entry.feeling)
            let reflection = GuestReflection(summary: "A suggestion", feeling: "Uncertain", insight: "Pause",
                                              source: .guided, basedOnWords: entry.originalWords)
            let reflected = try await store.updateReflection(id: id, reflection: reflection, nextStep: "Ask",
                                                              nextStepDone: false, expectedRevision: 0)
            let tagged = try await store.updateTags(id: id, context: .study, feeling: .overloaded,
                                                   expectedRevision: reflected.revision)
            XCTAssertEqual(tagged.reflection, reflection)
            XCTAssertEqual(tagged.originalWords, entry.originalWords)
            XCTAssertEqual(tagged.nextStep, "Ask")
            _ = try await store.update(id: id, originalWords: "Edited words", expectedRevision: tagged.revision)
        }
        let reopened = try await open()
        let entries = try await reopened.loadAll()
        let saved = try XCTUnwrap(entries.first)
        XCTAssertEqual(saved.context, .study)
        XCTAssertEqual(saved.feeling, .overloaded)
        XCTAssertEqual(saved.originalWords, "Edited words")
        XCTAssertTrue(saved.isReflectionStale)
        XCTAssertTrue(GuestSearch.matches(saved, "study"))
        XCTAssertTrue(GuestSearch.matches(saved, "overloaded"))
        let export = GuestExport.text(entries: entries, messages: [])
        XCTAssertTrue(export.contains("Context: Study"))
        XCTAssertTrue(export.contains("My feeling: Overloaded"))
        let clearedContext = try await reopened.updateTags(id: id, context: nil, feeling: .calm,
                                                          expectedRevision: saved.revision)
        XCTAssertNil(clearedContext.context)
        XCTAssertEqual(clearedContext.feeling, .calm)
        let cleared = try await reopened.updateTags(id: id, context: nil, feeling: nil,
                                                    expectedRevision: clearedContext.revision)
        XCTAssertNil(cleared.feeling)
        _ = try await reopened.deleteAll()
        let empty = try await reopened.snapshot()
        XCTAssertTrue(empty.entries.isEmpty)
    }

    func testStaleDeletedAndFailedTagSavesNeverOverwriteSavedWords() async throws {
        let failSave = OSAllocatedUnfairLock(initialState: false)
        let store = try await open(faults: .init(beforeSave: {
            if failSave.withLock({ $0 }) { throw CocoaError(.fileWriteOutOfSpace) }
        }))
        let entry = try await store.create(originalWords: "Keep this")
        let updated = try await store.update(id: entry.id, originalWords: "Latest", expectedRevision: 0)
        do {
            _ = try await store.updateTags(id: entry.id, context: .work, feeling: .sad, expectedRevision: 0)
            XCTFail("Stale tag save must fail")
        } catch GuestJournalError.staleRevision { }
        failSave.withLock { $0 = true }
        do {
            _ = try await store.updateTags(id: entry.id, context: .work, feeling: .sad, expectedRevision: updated.revision)
            XCTFail("Injected failure must fail")
        } catch GuestJournalError.saveFailed { }
        failSave.withLock { $0 = false }
        let rows = try await store.loadAll()
        XCTAssertEqual(rows.first, updated)
        try await store.delete(id: entry.id)
        do {
            _ = try await store.updateTags(id: entry.id, context: .family, feeling: .happy, expectedRevision: updated.revision)
            XCTFail("Deleted entries must not be recreated")
        } catch GuestJournalError.notFound { }
    }

    func testV5MigrationPreservesEntriesReflectionConversationAndDraftsWithNoInventedTags() async throws {
        try FileManager.default.createDirectory(at: location.directory, withIntermediateDirectories: true)
        let id = UUID(), draftID = UUID()
        let conversation = GuestPracticeConversation(originalWords: "First", turns: [.init(kind: .theirReply, text: "Reply")])
        do {
            let container = try ModelContainer(for: Schema(versionedSchema: GuestJournalSchemaV5.self),
                                                configurations: ModelConfiguration(url: location.storeURL))
            let context = ModelContext(container)
            let row = GuestJournalSchemaV5.Entry(id: id, originalWords: "Original", revision: 4,
                                                  createdAt: Date(), updatedAt: Date())
            row.reflectionSource = "guided"
            row.reflectionSummary = "Kept reflection"
            row.reflectionBasedOn = "Original"
            context.insert(row)
            let practice = GuestJournalSchemaV5.PracticeMessage(id: UUID(), situation: "Work", goal: "Ask",
                wording: "Next", sourceEntryID: id, revision: 2, createdAt: Date(), updatedAt: Date())
            practice.conversationData = try JSONEncoder().encode(conversation)
            context.insert(practice)
            context.insert(GuestJournalSchemaV5.SavedDraft(id: draftID, savedAt: Date()))
            context.insert(GuestJournalSchemaV5.KeptDraftRecord(slot: "write", id: UUID(), text: "Unsaved", updatedAt: Date()))
            try context.save()
        }
        let store = try await open()
        let snapshot = try await store.snapshot()
        let row = try XCTUnwrap(snapshot.entries.first)
        XCTAssertEqual(row.id, id)
        XCTAssertEqual(row.revision, 4)
        XCTAssertEqual(row.originalWords, "Original")
        XCTAssertEqual(row.reflection?.summary, "Kept reflection")
        XCTAssertNil(row.context)
        XCTAssertNil(row.feeling)
        XCTAssertEqual(snapshot.messages.first?.conversation, conversation)
        XCTAssertEqual(snapshot.messages.first?.sourceEntryID, id)
        let receipt = try await store.isDraftSaved(draftID)
        XCTAssertTrue(receipt)
        let draft = try await store.keptDraft(slot: "write")
        XCTAssertEqual(draft?.text, "Unsaved")
    }
}
