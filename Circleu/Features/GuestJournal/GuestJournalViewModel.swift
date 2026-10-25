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
        didSet { if draft != oldValue { keepDraft() } }
    }
    @Published private(set) var saveError: String?
    @Published private(set) var isSaving = false
    /// A lasting message for the Journal screen, such as a save that needs attention.
    @Published var notice: String?
    /// Set when the draft couldn't be restored or kept; shown on the Write screen.
    @Published private(set) var draftWarning: String?

    static let saveFailedMessage = "Couldn’t save. Try again."
    static let loadFailedMessage = "Couldn’t open your journal. Try again."
    static let savedButUnprotectedMessage = "Saved, but this phone couldn’t fully secure it."
    static let draftUnreadableMessage = "Your earlier draft couldn’t be opened, so it’s been left as it was. New writing won’t be kept after you close the app."
    static let draftNotKeptMessage = "Your draft couldn’t be kept on this phone. Save it before you close the app."
    static let draftUnprotectedMessage = "Your draft is kept, but this phone couldn’t fully secure it."
    static let draftNotClearedMessage = "Saved. The draft copy couldn’t be removed, so it won’t be offered again for saving."

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
    /// False if a kept draft exists but couldn't be read: don't overwrite it.
    private var canKeepDraft: Bool
    private var restoringDraft = false
    private var lastDraftWrite: Task<Void, Never>?

    init(store: any GuestJournalStore, drafts: (any GuestDraftStore)? = nil) {
        self.store = store
        self.drafts = drafts
        canKeepDraft = drafts != nil
    }

    /// Saved entries, newest first, or none while loading or after a failed load.
    var entries: [GuestJournalEntry] {
        if case .loaded(let entries) = loadState { entries } else { [] }
    }

    /// Restores a kept draft after `load()`. A draft that can't be read is left untouched on disk.
    /// A draft matching a saved entry was already saved (its cleanup didn't finish), so it's
    /// cleared rather than offered again, which would create a duplicate.
    func restoreDraft() async {
        guard let drafts else { return }
        let kept: String
        do {
            let loaded = try await drafts.load()
            kept = loaded?.text ?? ""
            if loaded?.isProtected == false { draftWarning = Self.draftUnprotectedMessage }
        } catch {
            canKeepDraft = false
            draftWarning = Self.draftUnreadableMessage
            return
        }
        let trimmed = kept.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty, entries.contains(where: { $0.originalWords == trimmed }) {
            await clearKeptDraft()
            return
        }
        setDraftWithoutKeeping(kept)
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
    /// Returns true once the entry is saved.
    @discardableResult
    func saveDraft() async -> Bool {
        let words = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !words.isEmpty, !isSaving else { return false }
        isSaving = true
        defer { isSaving = false }
        let submitted = draft
        do {
            _ = try await store.create(originalWords: words)
            saveError = nil
        } catch GuestJournalError.savedButUnprotected {
            saveError = nil
            notice = Self.savedButUnprotectedMessage // Saved: shown on Journal; retrying would duplicate it.
        } catch {
            saveError = Self.saveFailedMessage
            return false
        }
        // Text typed while the save was in progress is newer than what was saved; keep it.
        if draft == submitted {
            setDraftWithoutKeeping("")
            await clearKeptDraft()
        }
        await load()
        return true
    }

    private func setDraftWithoutKeeping(_ text: String) {
        restoringDraft = true
        draft = text
        restoringDraft = false
    }

    /// Removes the kept draft after it was saved as an entry, waiting for earlier draft writes.
    private func clearKeptDraft() async {
        guard let drafts, canKeepDraft else { return }
        await lastDraftWrite?.value
        do {
            try await drafts.save("")
        } catch {
            // Restore reconciles a leftover copy against saved entries, so it isn't saved twice.
            notice = Self.draftNotClearedMessage
        }
    }

    /// Writes the draft in order, after any earlier write.
    private func keepDraft() {
        guard let drafts, canKeepDraft, !restoringDraft else { return }
        let text = draft
        let previous = lastDraftWrite
        lastDraftWrite = Task { [weak self] in
            await previous?.value
            do {
                try await drafts.save(text)
            } catch GuestJournalError.protectionFailed {
                self?.draftWarning = Self.draftUnprotectedMessage
            } catch {
                self?.draftWarning = Self.draftNotKeptMessage
            }
        }
    }

    /// Waits for pending draft writes (tests and relaunch checks).
    func flushDraft() async {
        await lastDraftWrite?.value
    }
}
