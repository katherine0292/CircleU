import Combine
import Foundation

/// Screen state for the guest journal (Today, Write and Journal). Talks to `GuestJournalStore`
/// and `GuestDraftStore` only, so failures can be injected in tests.
@MainActor
final class GuestJournalViewModel: ObservableObject {
    enum LoadState: Equatable {
        case loading
        case loaded([GuestJournalEntry])
        /// Shown as an error with Try again, never as an empty journal.
        case failed(String)
    }

    @Published private(set) var loadState: LoadState = .loading
    /// The words being written. Kept on this phone as you type, and after a failed save.
    @Published var draft = "" {
        didSet {
            guard draft != oldValue, !settingDraftQuietly else { return }
            // Every version of the draft gets its own ID, so a saved version can never be
            // confused with text typed afterwards (including while a save is in progress).
            draftID = UUID()
            keepDraft()
        }
    }
    @Published var selectedQuestion: GuestWritingQuestion?
    @Published private(set) var saveError: String?
    @Published private(set) var isSaving = false
    /// The entry just saved without a reflection, so Journal can offer one ("Reflect on it").
    @Published private(set) var reflectionOfferID: UUID?
    /// Lasting messages shown above every screen until dismissed. They add up, never replace.
    @Published private(set) var notices: [String] = []
    /// Set when the draft couldn't be restored or kept; shown on the Write screen.
    @Published private(set) var draftWarning: String?

    static let saveFailedMessage = "Couldn’t save. Try again."
    static let loadFailedMessage = "Couldn’t open your journal. Try again."
    static let savedButUnprotectedMessage = "Saved, but this phone couldn’t fully secure it."
    static let draftUnreadableMessage = "An earlier draft couldn’t be opened. New writing isn’t kept, so save before closing."
    static let draftNotKeptMessage = "Your draft couldn’t be kept on this phone. Save it before you close the app."
    static let draftUnprotectedMessage = "Your draft is kept, but this phone couldn’t fully secure it."
    static let draftNotClearedMessage = "Saved. The draft copy couldn’t be removed, but it won’t be saved twice."
    static let draftAlreadySavedMessage = "This draft was already saved to your journal."

    /// What the guest root shows when the store can't be opened. Never an empty journal.
    static func openFailureMessage(for error: Error) -> String {
        switch error as? GuestJournalError {
        case .storeMissing:
            "Your saved journal is missing from this phone. Nothing new has been created."
        case .protectionFailed:
            "This phone couldn’t secure your journal, so it wasn’t opened."
        default:
            loadFailedMessage
        }
    }

    let store: any GuestJournalStore
    private let drafts: (any GuestDraftStore)?
    /// The identity of the current draft version; it changes whenever the text changes.
    private var draftID = UUID()
    /// False if a kept draft exists but couldn't be read: don't overwrite it.
    private var canKeepDraft: Bool
    private var settingDraftQuietly = false
    /// True while Delete all runs, so no draft write can recreate a file mid-way.
    private var draftsPaused = false
    /// Every draft write and removal runs in this order, one after another.
    private var lastDraftOperation: Task<Void, Never>?

    init(store: any GuestJournalStore, drafts: (any GuestDraftStore)? = nil) {
        self.store = store
        self.drafts = drafts
        canKeepDraft = drafts != nil
    }

    /// Saved entries, newest first, or none while loading or after a failed load.
    var entries: [GuestJournalEntry] {
        if case .loaded(let entries) = loadState { entries } else { [] }
    }

    func dismissNotices() { notices.removeAll() }

    /// "Not now".
    func dismissReflectionOffer() { reflectionOfferID = nil }

    /// The offer for this entry was taken up. A newer entry's offer stays.
    func reflectionAdded(to entryID: UUID) {
        if reflectionOfferID == entryID { reflectionOfferID = nil }
    }

    /// The just-saved entry, while it's still there and still has no reflection.
    var reflectionOffer: GuestJournalEntry? {
        guard let id = reflectionOfferID else { return nil }
        return entries.first { $0.id == id && $0.reflection == nil && $0.nextStep == nil }
    }

    /// An older draft couldn't be read; it's left as it was and new writing is kept separately.
    func noteUnreadableDraft() {
        // A warning that new writing won't be kept matters more; keep that one.
        if draftWarning == nil { draftWarning = Self.olderDraftUnreadableMessage }
    }

    static let olderDraftUnreadableMessage = "An earlier draft couldn’t be opened, so it’s been left as it was."

    /// A lasting message from elsewhere in the guest app (for example Practice).
    func addNotice(_ notice: String) { notices.append(notice) }

    /// Restores a kept draft. A draft that can't be read is left untouched on disk. A draft the
    /// store already saved, or that Delete all consumed, is removed rather than offered again; if
    /// the store can't be asked, the draft is left untouched and not shown (it fails closed).
    func restoreDraft() async {
        guard let drafts else { return }
        let kept: KeptDraft?
        do {
            kept = try await drafts.load()
        } catch {
            canKeepDraft = false
            draftWarning = Self.draftUnreadableMessage
            return
        }
        guard let kept else { return }
        switch try? await store.isDraftSaved(kept.id) {
        case true?:
            enqueueDraftOperation { try await drafts.remove(id: kept.id) } // Saved or deleted already.
            return
        case nil:
            // Can't tell whether it was saved or deleted: don't show it, and don't overwrite it.
            canKeepDraft = false
            draftWarning = Self.draftUnreadableMessage
            return
        case false?:
            break
        }
        if !kept.isProtected { draftWarning = Self.draftUnprotectedMessage }
        draftID = kept.id
        setDraftQuietly(kept.text)
    }

    /// Refreshes the list. Keeps showing the current entries while refreshing.
    func load() async {
        if case .loaded = loadState {} else { loadState = .loading }
        do {
            loadState = .loaded(try await store.loadAll())
        } catch {
            loadState = .failed(Self.loadFailedMessage)
        }
    }

    /// Saves the draft as a new entry. On failure the draft stays and an error is shown.
    /// Returns true once the entry is saved (or was already saved before). Only the words are
    /// saved; a reflection can be added afterwards ("Reflect on it").
    @discardableResult
    func saveDraft() async -> Bool {
        let words = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !words.isEmpty, !isSaving else { return false }
        isSaving = true
        defer { isSaving = false }
        let submittedID = draftID
        let draftIDToRecord = drafts == nil ? nil : submittedID
        var offer: UUID?
        do {
            offer = try await store.create(originalWords: words, draftID: draftIDToRecord).id
            saveError = nil
        } catch GuestJournalError.savedButUnprotected(let entryID) {
            saveError = nil
            offer = entryID
            notices.append(Self.savedButUnprotectedMessage) // Saved: retrying would duplicate it.
        } catch GuestJournalError.draftAlreadySaved {
            saveError = nil
            notices.append(Self.draftAlreadySavedMessage)
        } catch {
            saveError = Self.saveFailedMessage
            return false
        }
        // Clear only the exact version that was saved (same ID). Any edit while saving, even one
        // that returns to the same words, is a new version: it stays on screen and on the phone.
        reflectionOfferID = offer // A reflection is only ever offered, after saving.
        if draftID == submittedID { setDraftQuietly("") }
        removeKeptDraft(id: submittedID)
        await load()
        return true
    }

    /// Changes an entry's reflection or next step (nil removes it). Returns nil on success, or
    /// the message to show; the entry is unchanged on failure.
    func updateReflection(of entry: GuestJournalEntry, reflection: GuestReflection?, nextStep: String?,
                          nextStepDone: Bool) async -> String? {
        guard let reflections = store as? any GuestReflectionStore else { return Self.saveFailedMessage }
        do {
            _ = try await reflections.updateReflection(id: entry.id, reflection: reflection, nextStep: nextStep,
                                                       nextStepDone: nextStepDone, expectedRevision: entry.revision)
        } catch GuestJournalError.savedButUnprotected {
            addNotice(Self.savedButUnprotectedMessage) // Committed.
        } catch GuestJournalError.staleRevision {
            await load()
            return GuestEntryEditorViewModel.staleMessage
        } catch GuestJournalError.notFound {
            await load()
            return GuestEntryEditorViewModel.deletedMessage
        } catch {
            return Self.saveFailedMessage
        }
        await load()
        return nil
    }

    /// Delete all, before: no draft writes until `resumeDrafts`, and pending ones finish first.
    func pauseDrafts() async {
        draftsPaused = true
        await flushDraft()
    }

    /// Delete all, after: `deleted` clears the draft on screen (the store already removed the kept
    /// copy in the same transaction). Draft keeping resumes either way.
    func resumeDrafts(afterDeleting deleted: Bool) {
        if deleted {
            pendingDraftWrite = nil
            setDraftQuietly("")
            draftID = UUID()
            draftWarning = nil
            canKeepDraft = drafts != nil
        }
        draftsPaused = false
    }

    /// Waits for pending draft writes and removals (tests and relaunch checks).
    func flushDraft() async {
        await lastDraftOperation?.value
    }

    private func setDraftQuietly(_ text: String) {
        settingDraftQuietly = true
        draft = text
        if text.isEmpty { selectedQuestion = nil }
        settingDraftQuietly = false
    }

    /// The newest version waiting to be written; a burst of typing or dictation is one write.
    private var pendingDraftWrite: (id: UUID, text: String)?

    private func keepDraft() {
        guard let drafts, canKeepDraft, !draftsPaused else { return }
        let alreadyQueued = pendingDraftWrite != nil
        pendingDraftWrite = (draftID, draft)
        guard !alreadyQueued else { return }
        enqueueDraftOperation { [weak self] in
            guard let write = await self?.takePendingDraftWrite() else { return }
            try await drafts.save(id: write.id, text: write.text)
        }
    }

    private func takePendingDraftWrite() -> (id: UUID, text: String)? {
        defer { pendingDraftWrite = nil }
        return pendingDraftWrite
    }

    /// Removes the saved draft's file, after any earlier writes. A newer draft has another ID,
    /// so it's never removed by this.
    private func removeKeptDraft(id: UUID) {
        guard let drafts, canKeepDraft else { return }
        enqueueDraftOperation(onFailure: { [weak self] _ in
            self?.notices.append(Self.draftNotClearedMessage)
        }) {
            try await drafts.remove(id: id)
        }
    }

    private func enqueueDraftOperation(onFailure: ((Error) -> Void)? = nil,
                                       _ operation: @escaping @Sendable () async throws -> Void) {
        let previous = lastDraftOperation
        lastDraftOperation = Task { [weak self] in
            await previous?.value
            do {
                try await operation()
            } catch {
                if let onFailure {
                    onFailure(error)
                } else if case GuestJournalError.protectionFailed = error {
                    self?.draftWarning = Self.draftUnprotectedMessage
                } else {
                    self?.draftWarning = Self.draftNotKeptMessage
                }
            }
        }
    }
}
