import Foundation
import XCTest
@testable import Circleu

private actor EditorStubStore: GuestJournalStore {
    var updateError: GuestJournalError?
    func failUpdates(with error: GuestJournalError?) { updateError = error }

    func loadAll() throws -> [GuestJournalEntry] { [] }
    func create(originalWords: String, draftID: UUID?) throws -> GuestJournalEntry { throw GuestJournalError.notFound }
    func update(id: UUID, originalWords: String, expectedRevision: Int) throws -> GuestJournalEntry {
        if let updateError { throw updateError }
        return GuestJournalEntry(id: id, originalWords: originalWords, revision: expectedRevision + 1,
                                 createdAt: Date(), updatedAt: Date())
    }
    func delete(id: UUID) throws {}
    func isDraftSaved(_ draftID: UUID) throws -> Bool { false }
}

/// Holds `update` until the test releases it, to type while an edit is saving.
private actor SuspendedUpdateStore: GuestJournalStore {
    private var pending: CheckedContinuation<Void, Never>?
    var isWaiting: Bool { pending != nil }
    func release() { pending?.resume(); pending = nil }

    func loadAll() throws -> [GuestJournalEntry] { [] }
    func create(originalWords: String, draftID: UUID?) throws -> GuestJournalEntry { throw GuestJournalError.notFound }
    func update(id: UUID, originalWords: String, expectedRevision: Int) async throws -> GuestJournalEntry {
        await withCheckedContinuation { pending = $0 }
        return GuestJournalEntry(id: id, originalWords: originalWords, revision: expectedRevision + 1,
                                 createdAt: Date(), updatedAt: Date())
    }
    func delete(id: UUID) throws {}
    func isDraftSaved(_ draftID: UUID) throws -> Bool { false }
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
        let draftURL = location.directory.appendingPathComponent("Draft.json")
        let unreadable = Data([0xFF, 0xFE, 0xFD]) // Not a readable draft.
        try unreadable.write(to: draftURL)

        let journal = try await GuestComposition.local(at: location).makeViewModel()
        XCTAssertEqual(journal.draftWarning, GuestJournalViewModel.draftUnreadableMessage)
        journal.draft = "new typing"
        await journal.flushDraft()
        XCTAssertEqual(try Data(contentsOf: draftURL), unreadable, "the unreadable draft isn't overwritten")
    }
}

// MARK: - Draft identity and failure handling (Codex re-checks)

private actor FakeDraftStore: GuestDraftStore {
    var kept: KeptDraft?
    var failRemove = false
    var protectionFails = false

    init(kept: KeptDraft? = nil) { self.kept = kept }
    func configure(failRemove: Bool = false, protectionFails: Bool = false) {
        self.failRemove = failRemove
        self.protectionFails = protectionFails
    }

    func load() throws -> KeptDraft? { kept }
    func save(id: UUID, text: String) throws {
        kept = text.isEmpty ? nil : KeptDraft(id: id, text: text, isProtected: !protectionFails)
        if protectionFails, !text.isEmpty { throw GuestJournalError.protectionFailed("draft") }
    }
    func remove(id: UUID) throws {
        if failRemove { throw GuestJournalError.saveFailed("injected") }
        if kept?.id == id { kept = nil }
    }
}

/// Records saved draft IDs like the real store (survives edits and deletes of the entry).
private actor MemoryJournalStore: GuestJournalStore {
    var entries: [GuestJournalEntry] = []
    var savedDrafts: Set<UUID> = []
    var createResult: GuestJournalError?

    func failCreates(with error: GuestJournalError?) { createResult = error }
    func loadAll() throws -> [GuestJournalEntry] { entries }
    func create(originalWords: String, draftID: UUID?) throws -> GuestJournalEntry {
        if let draftID, savedDrafts.contains(draftID) { throw GuestJournalError.draftAlreadySaved }
        let entry = GuestJournalEntry(id: UUID(), originalWords: originalWords, revision: 0, createdAt: Date(), updatedAt: Date())
        entries.insert(entry, at: 0)
        if let draftID { savedDrafts.insert(draftID) }
        if let createResult { throw createResult }
        return entry
    }
    func update(id: UUID, originalWords: String, expectedRevision: Int) throws -> GuestJournalEntry {
        guard let index = entries.firstIndex(where: { $0.id == id }) else { throw GuestJournalError.notFound }
        entries[index].originalWords = originalWords
        return entries[index]
    }
    func delete(id: UUID) throws { entries.removeAll { $0.id == id } }
    func isDraftSaved(_ draftID: UUID) throws -> Bool { savedDrafts.contains(draftID) }
}

@MainActor
final class GuestDraftFailureTests: XCTestCase {
    func testLeftoverDraftOfAnEditedEntryIsNotRestoredOrSavedTwice() async throws {
        let store = MemoryJournalStore()
        let drafts = FakeDraftStore()
        await drafts.configure(failRemove: true)
        let journal = GuestJournalViewModel(store: store, drafts: drafts)
        journal.draft = "Saved words"
        await journal.flushDraft()
        let saved = await journal.saveDraft()
        XCTAssertTrue(saved)
        await journal.flushDraft()
        XCTAssertEqual(journal.notices, [GuestJournalViewModel.draftNotClearedMessage])

        // The entry is edited, so its text no longer matches the leftover draft.
        let entryID = try XCTUnwrap(journal.entries.first?.id)
        _ = try await store.update(id: entryID, originalWords: "Edited later", expectedRevision: 0)

        await drafts.configure()
        let reopened = GuestJournalViewModel(store: store, drafts: drafts)
        await reopened.load()
        await reopened.restoreDraft()
        await reopened.flushDraft()
        XCTAssertEqual(reopened.draft, "", "recognised by its ID, not its text")
        let kept = await drafts.kept
        XCTAssertNil(kept, "leftover removed")
        let count = await store.entries.count
        XCTAssertEqual(count, 1)
    }

    func testANewDraftRepeatingEarlierWordsIsKept() async throws {
        let store = MemoryJournalStore()
        _ = try await store.create(originalWords: "Same words", draftID: UUID())
        let drafts = FakeDraftStore(kept: KeptDraft(id: UUID(), text: "Same words", isProtected: true))
        let journal = GuestJournalViewModel(store: store, drafts: drafts)
        await journal.load()
        await journal.restoreDraft()
        XCTAssertEqual(journal.draft, "Same words", "a different draft isn't deleted for repeating text")
    }

    func testDraftThatCantBeCheckedIsRestoredButNeverSavedTwice() async throws {
        let store = MemoryJournalStore()
        let draftID = UUID()
        _ = try await store.create(originalWords: "Already saved", draftID: draftID)
        let entryID = await store.entries[0].id
        try await store.delete(id: entryID) // Saved, then deleted.
        let drafts = FakeDraftStore(kept: KeptDraft(id: draftID, text: "Already saved", isProtected: true))
        let journal = GuestJournalViewModel(store: store, drafts: drafts)
        await journal.load()
        await journal.restoreDraft()
        await journal.flushDraft()
        XCTAssertEqual(journal.draft, "", "a saved-then-deleted draft isn't resurrected")
    }

    func testTypingDuringCleanupIsKept() async {
        let store = MemoryJournalStore()
        let drafts = FakeDraftStore()
        let journal = GuestJournalViewModel(store: store, drafts: drafts)
        journal.draft = "First"
        await journal.flushDraft()
        let saving = Task { await journal.saveDraft() }
        await Task.yield()
        journal.draft = "First, then more" // Typed while saving and cleanup are in flight.
        _ = await saving.value
        await journal.flushDraft()
        let kept = await drafts.kept
        XCTAssertEqual(kept?.text, journal.draft, "the newest typing is what's kept on the phone")
    }

    func testProtectionAndCleanupWarningsBothShow() async {
        let store = MemoryJournalStore()
        await store.failCreates(with: .savedButUnprotected(entryID: UUID()))
        let drafts = FakeDraftStore()
        await drafts.configure(failRemove: true)
        let journal = GuestJournalViewModel(store: store, drafts: drafts)
        journal.draft = "Words"
        await journal.flushDraft()
        _ = await journal.saveDraft()
        await journal.flushDraft()
        XCTAssertEqual(journal.notices, [GuestJournalViewModel.savedButUnprotectedMessage,
                                         GuestJournalViewModel.draftNotClearedMessage])
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
