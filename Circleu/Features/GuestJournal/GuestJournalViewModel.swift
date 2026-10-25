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
    @Published private(set) var saveError: String?
    @Published private(set) var isSaving = false
    /// Lasting messages shown above every screen until dismissed. They add up, never replace.
    @Published private(set) var notices: [String] = []
    /// Set when the draft couldn't be restored or kept; shown on the Write screen.
    @Published private(set) var draftWarning: String?

    static let saveFailedMessage = "Couldn’t save. Try again."
    static let loadFailedMessage = "Couldn’t open your journal. Try again."
    static let savedButUnprotectedMessage = "Saved, but this phone couldn’t fully secure it."
    static let draftUnreadableMessage = "Your earlier draft couldn’t be opened, so it’s been left as it was. New writing won’t be kept after you close the app."
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

    /// A lasting message from elsewhere in the guest app (for example Practice).
    func addNotice(_ notice: String) { notices.append(notice) }

    /// Restores a kept draft. A draft that can't be read is left untouched on disk. A draft the
    /// store already saved (cleanup didn't finish) is removed rather than offered again; if the
    /// store can't be asked, the draft is restored and `create` refuses to save it twice.
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
        if (try? await store.isDraftSaved(kept.id)) == true {
            enqueueDraftOperation { try await drafts.remove(id: kept.id) }
            return
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
    /// Returns true once the entry is saved (or was already saved before).
    @discardableResult
    func saveDraft() async -> Bool {
        let words = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !words.isEmpty, !isSaving else { return false }
        isSaving = true
        defer { isSaving = false }
        let submittedID = draftID
        do {
            _ = try await store.create(originalWords: words, draftID: drafts == nil ? nil : submittedID)
            saveError = nil
        } catch GuestJournalError.savedButUnprotected {
            saveError = nil
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
        if draftID == submittedID { setDraftQuietly("") }
        removeKeptDraft(id: submittedID)
        await load()
        return true
    }

    /// Waits for pending draft writes and removals (tests and relaunch checks).
    func flushDraft() async {
        await lastDraftOperation?.value
    }

    private func setDraftQuietly(_ text: String) {
        settingDraftQuietly = true
        draft = text
        settingDraftQuietly = false
    }

    private func keepDraft() {
        guard let drafts, canKeepDraft else { return }
        let id = draftID
        let text = draft
        enqueueDraftOperation { try await drafts.save(id: id, text: text) }
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
