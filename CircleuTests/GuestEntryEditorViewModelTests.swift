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

/// Holds `update` until the test releases it, to type while an edit is saving.
private actor SuspendedUpdateStore: GuestJournalStore {
    private var pending: CheckedContinuation<Void, Never>?
    var isWaiting: Bool { pending != nil }
    func release() { pending?.resume(); pending = nil }

    func loadAll() throws -> [GuestJournalEntry] { [] }
    func create(originalWords: String) throws -> GuestJournalEntry { throw GuestJournalError.notFound }
    func update(id: UUID, originalWords: String, expectedRevision: Int) async throws -> GuestJournalEntry {
        await withCheckedContinuation { pending = $0 }
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
        let outcome = await editor.save()
        XCTAssertEqual(outcome, .saved)
        XCTAssertEqual(editor.entry.revision, 3)
        XCTAssertFalse(editor.hasChanges)
        XCTAssertNil(editor.saveError)
    }

    func testFailedSaveKeepsTextAndShowsError() async {
        let store = EditorStubStore()
        await store.failUpdates(with: .saveFailed("injected"))
        let editor = GuestEntryEditorViewModel(entry: entry, store: store)
        editor.text = "Don't lose this"
        let outcome = await editor.save()
        XCTAssertEqual(outcome, .failed)
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

    func testTextTypedDuringEditSaveIsKeptAsUnsavedChange() async {
        let store = SuspendedUpdateStore()
        let editor = GuestEntryEditorViewModel(entry: entry, store: store)
        editor.text = "A"
        let saving = Task { await editor.save() }
        while await !store.isWaiting { await Task.yield() }
        XCTAssertFalse(editor.canLeave, "Back and Discard wait while a save may still commit")
        editor.text = "A, then B"
        await store.release()
        let outcome = await saving.value
        XCTAssertEqual(outcome, .savedStay)
        XCTAssertEqual(editor.text, "A, then B")
        XCTAssertEqual(editor.entry.originalWords, "A")
        XCTAssertTrue(editor.hasChanges, "the newer text is still unsaved")
        XCTAssertTrue(editor.canLeave)
    }

    func testSavedButUnprotectedEditStaysWithWarningAndIsNotSavedTwice() async {
        let store = EditorStubStore()
        await store.failUpdates(with: .savedButUnprotected(entryID: entry.id))
        let editor = GuestEntryEditorViewModel(entry: entry, store: store)
        editor.text = "After"
        let outcome = await editor.save()
        XCTAssertEqual(outcome, .savedStay, "stay so the warning can be read")
        XCTAssertEqual(editor.saveError, GuestJournalViewModel.savedButUnprotectedMessage)
        XCTAssertFalse(editor.hasChanges, "committed, so Back won't offer to save it again")
        XCTAssertFalse(editor.canSave)
        XCTAssertEqual(editor.entry.revision, 3)
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
        await journal!.flushDraft()
        journal = nil

        let reopened = try await GuestComposition.local(at: location).makeViewModel()
        let entry = try XCTUnwrap(reopened.entries.first)
        XCTAssertEqual(entry.originalWords, "I held back in class.")
        let editor = GuestEntryEditorViewModel(entry: entry, store: reopened.store)
        editor.text = "I asked after class."
        let outcome = await editor.save()
        XCTAssertEqual(outcome, .saved)

        let again = try await GuestComposition.local(at: location).makeViewModel()
        XCTAssertEqual(again.entries.map(\.originalWords), ["I asked after class."])
    }

    // MARK: Draft kept on this phone

    private func makeLocation() -> (GuestJournalLocation, URL) {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("GuestDraft-\(UUID())")
        return (GuestJournalLocation(directory: root.appendingPathComponent("GuestJournal"),
                                     setupMarker: root.appendingPathComponent("Setup/initialized")), root)
    }

    func testDraftSurvivesRelaunchAndIsClearedAfterSaving() async throws {
        let (location, root) = makeLocation()
        defer { try? FileManager.default.removeItem(at: root) }
        var journal: GuestJournalViewModel? = try await GuestComposition.local(at: location).makeViewModel()
        journal!.draft = "Half a thought"
        await journal!.flushDraft()
        journal = nil

        let reopened = try await GuestComposition.local(at: location).makeViewModel()
        XCTAssertEqual(reopened.draft, "Half a thought", "draft restored after relaunch")
        let saved = await reopened.saveDraft()
        XCTAssertTrue(saved)
        await reopened.flushDraft()

        let again = try await GuestComposition.local(at: location).makeViewModel()
        XCTAssertEqual(again.draft, "", "a saved draft isn't restored again")
        XCTAssertEqual(again.entries.map(\.originalWords), ["Half a thought"])
    }

    func testUnreadableDraftIsLeftUntouched() async throws {
        let (location, root) = makeLocation()
        defer { try? FileManager.default.removeItem(at: root) }
        _ = try await GuestComposition.local(at: location).makeViewModel() // Creates the folder.
        let draftURL = location.directory.appendingPathComponent("Draft.txt")
        let unreadable = Data([0xFF, 0xFE, 0xFD]) // Not valid UTF-8.
        try unreadable.write(to: draftURL)

        let journal = try await GuestComposition.local(at: location).makeViewModel()
        XCTAssertEqual(journal.draftWarning, GuestJournalViewModel.draftUnreadableMessage)
        journal.draft = "new typing"
        await journal.flushDraft()
        XCTAssertEqual(try Data(contentsOf: draftURL), unreadable, "the unreadable draft isn't overwritten")
    }
}

// MARK: - Draft failure handling (Codex re-check R1/R2)

private actor FakeDraftStore: GuestDraftStore {
    var kept: KeptDraft?
    var failClear = false
    var protectionFails = false
    private(set) var saves: [String] = []

    init(kept: KeptDraft? = nil) { self.kept = kept }
    func configure(failClear: Bool = false, protectionFails: Bool = false) {
        self.failClear = failClear
        self.protectionFails = protectionFails
    }

    func load() throws -> KeptDraft? { kept }
    func save(_ text: String) throws {
        if text.isEmpty, failClear { throw GuestJournalError.saveFailed("injected") }
        saves.append(text)
        kept = text.isEmpty ? nil : KeptDraft(text: text, isProtected: !protectionFails)
        if protectionFails, !text.isEmpty { throw GuestJournalError.protectionFailed("draft") }
    }
}

private actor MemoryJournalStore: GuestJournalStore {
    var entries: [GuestJournalEntry] = []
    func loadAll() throws -> [GuestJournalEntry] { entries }
    func create(originalWords: String) throws -> GuestJournalEntry {
        let entry = GuestJournalEntry(id: UUID(), originalWords: originalWords, revision: 0, createdAt: Date(), updatedAt: Date())
        entries.insert(entry, at: 0)
        return entry
    }
    func update(id: UUID, originalWords: String, expectedRevision: Int) throws -> GuestJournalEntry { throw GuestJournalError.notFound }
    func delete(id: UUID) throws {}
}

@MainActor
final class GuestDraftFailureTests: XCTestCase {
    func testFailedDraftCleanupIsVisibleAndLeftoverIsNotOfferedAgain() async {
        let store = MemoryJournalStore()
        let drafts = FakeDraftStore()
        await drafts.configure(failClear: true)
        let journal = GuestJournalViewModel(store: store, drafts: drafts)
        journal.draft = "Saved words"
        await journal.flushDraft()
        let saved = await journal.saveDraft()
        XCTAssertTrue(saved)
        XCTAssertEqual(journal.notice, GuestJournalViewModel.draftNotClearedMessage, "shown on every screen")

        // Relaunch: the leftover draft matches a saved entry, so it isn't restored or saved twice.
        let reopened = GuestJournalViewModel(store: store, drafts: drafts)
        await reopened.load()
        await reopened.restoreDraft()
        XCTAssertEqual(reopened.draft, "")
        let entries = await store.entries
        XCTAssertEqual(entries.count, 1)
    }

    func testInterruptedCleanupIsReconciledOnRelaunch() async {
        let store = MemoryJournalStore()
        _ = try? await store.create(originalWords: "Already saved")
        let drafts = FakeDraftStore(kept: KeptDraft(text: "Already saved", isProtected: true))
        let journal = GuestJournalViewModel(store: store, drafts: drafts)
        await journal.load()
        await journal.restoreDraft()
        XCTAssertEqual(journal.draft, "")
        let kept = await drafts.kept
        XCTAssertNil(kept, "leftover cleared")
    }

    func testDraftKeptButUnprotectedSaysSoAccurately() async {
        let drafts = FakeDraftStore()
        await drafts.configure(protectionFails: true)
        let journal = GuestJournalViewModel(store: MemoryJournalStore(), drafts: drafts)
        journal.draft = "Kept anyway"
        await journal.flushDraft()
        XCTAssertEqual(journal.draftWarning, GuestJournalViewModel.draftUnprotectedMessage)
        let kept = await drafts.kept
        XCTAssertEqual(kept?.text, "Kept anyway", "the text was kept")

        let reopened = GuestJournalViewModel(store: MemoryJournalStore(), drafts: drafts)
        await reopened.load()
        await reopened.restoreDraft()
        XCTAssertEqual(reopened.draft, "Kept anyway", "restored even though protection wasn't confirmed")
        XCTAssertEqual(reopened.draftWarning, GuestJournalViewModel.draftUnprotectedMessage)
    }
}
