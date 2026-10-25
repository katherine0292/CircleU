import Foundation
import XCTest
@testable import Circleu

private actor EditorStubStore: GuestJournalStore {
    var updateError: GuestJournalError?
    func failUpdates(with error: GuestJournalError?) { updateError = error }

    func loadAll() throws -> [GuestJournalEntry] { [] }
    func create(originalWords: String) throws -> GuestJournalEntry { throw GuestJournalError.notFound }
    func update(id: UUID, originalWords: String, expectedRevision: Int) throws -> GuestJournalEntry {
        if let updateError { throw updateError }
        return GuestJournalEntry(id: id, originalWords: originalWords, revision: expectedRevision + 1,
                                 createdAt: Date(), updatedAt: Date())
    }
    func delete(id: UUID) throws {}
}

@MainActor
final class GuestEntryEditorViewModelTests: XCTestCase {
    private let entry = GuestJournalEntry(id: UUID(), originalWords: "Before", revision: 2,
                                          createdAt: Date(), updatedAt: Date())

    func testUnchangedTextHasNoChangesAndCannotSave() {
        let editor = GuestEntryEditorViewModel(entry: entry, store: EditorStubStore())
        XCTAssertFalse(editor.hasChanges)
        XCTAssertFalse(editor.canSave)
        editor.text = "  Before  "
        XCTAssertFalse(editor.hasChanges, "whitespace-only changes aren't unsaved edits")
    }

    func testEditingMarksChangesSoLeavingAsksFirst() {
        let editor = GuestEntryEditorViewModel(entry: entry, store: EditorStubStore())
        editor.text = "After"
        XCTAssertTrue(editor.hasChanges)
        XCTAssertTrue(editor.canSave)
        editor.text = ""
        XCTAssertFalse(editor.canSave, "can't save empty words")
    }

    func testSaveUsesOpenedRevisionAndClearsChanges() async {
        let editor = GuestEntryEditorViewModel(entry: entry, store: EditorStubStore())
        editor.text = "After"
        let saved = await editor.save()
        XCTAssertTrue(saved)
        XCTAssertEqual(editor.entry.revision, 3)
        XCTAssertFalse(editor.hasChanges)
        XCTAssertNil(editor.saveError)
    }

    func testFailedSaveKeepsTextAndShowsError() async {
        let store = EditorStubStore()
        await store.failUpdates(with: .saveFailed("injected"))
        let editor = GuestEntryEditorViewModel(entry: entry, store: store)
        editor.text = "Don't lose this"
        let saved = await editor.save()
        XCTAssertFalse(saved)
        XCTAssertEqual(editor.text, "Don't lose this")
        XCTAssertEqual(editor.saveError, GuestJournalViewModel.saveFailedMessage)
        XCTAssertTrue(editor.hasChanges, "still unsaved, so leaving asks first")
    }

    func testStaleAndDeletedEntriesKeepTextWithClearMessages() async {
        let store = EditorStubStore()
        let editor = GuestEntryEditorViewModel(entry: entry, store: store)
        editor.text = "My edit"
        await store.failUpdates(with: .staleRevision(current: 3, expected: 2))
        _ = await editor.save()
        XCTAssertEqual(editor.saveError, GuestEntryEditorViewModel.staleMessage)
        await store.failUpdates(with: .notFound)
        _ = await editor.save()
        XCTAssertEqual(editor.saveError, GuestEntryEditorViewModel.deletedMessage)
        XCTAssertEqual(editor.text, "My edit")
    }

    /// Save → "relaunch" (new store instance) → edit → relaunch, through the real store.
    func testSaveAndEditPersistAcrossRelaunch() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("GuestFlow-\(UUID())")
        defer { try? FileManager.default.removeItem(at: root) }
        let location = GuestJournalLocation(directory: root.appendingPathComponent("GuestJournal"),
                                            setupMarker: root.appendingPathComponent("Setup/initialized"))

        var journal: GuestJournalViewModel? = try await GuestComposition.local(at: location).makeViewModel()
        journal!.draft = "I held back in class."
        let saved = await journal!.saveDraft()
        XCTAssertTrue(saved)
        journal = nil

        let reopened = try await GuestComposition.local(at: location).makeViewModel()
        let entry = try XCTUnwrap(reopened.entries.first)
        XCTAssertEqual(entry.originalWords, "I held back in class.")
        let editor = GuestEntryEditorViewModel(entry: entry, store: reopened.store)
        editor.text = "I asked after class."
        let edited = await editor.save()
        XCTAssertTrue(edited)

        let again = try await GuestComposition.local(at: location).makeViewModel()
        XCTAssertEqual(again.entries.map(\.originalWords), ["I asked after class."])
    }
}
