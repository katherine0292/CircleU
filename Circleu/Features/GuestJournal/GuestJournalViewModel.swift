import Combine
import Foundation

/// Screen state for the guest journal (first slice). Talks to `GuestJournalStore` only, so
/// failures can be injected in tests. Not yet reachable from the app: the guest composition
/// root and its hidden developer switch come in the next step.
@MainActor
final class GuestJournalViewModel: ObservableObject {
    enum LoadState: Equatable {
        case loading
        case loaded([GuestJournalEntry])
        /// Shown as an error with Try again, never as an empty journal.
        case failed(String)
    }

    @Published private(set) var loadState: LoadState = .loading
    /// The words being written. Kept after a failed save so nothing typed is lost.
    @Published var draft = ""
    @Published private(set) var saveError: String?
    @Published private(set) var isSaving = false

    static let saveFailedMessage = "Couldn’t save. Try again."
    static let loadFailedMessage = "Couldn’t open your journal. Try again."
    static let savedButUnprotectedMessage = "Saved, but this phone couldn’t fully secure it."

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

    init(store: any GuestJournalStore) {
        self.store = store
    }

    func load() async {
        loadState = .loading
        do {
            loadState = .loaded(try await store.loadAll())
        } catch {
            loadState = .failed(Self.loadFailedMessage)
        }
    }

    /// Saved entries, newest first, or none while loading or after a failed load.
    var entries: [GuestJournalEntry] {
        if case .loaded(let entries) = loadState { entries } else { [] }
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
            saveError = Self.savedButUnprotectedMessage // Saved: retrying would duplicate it.
        } catch {
            saveError = Self.saveFailedMessage
            return false
        }
        // Text typed while the save was in progress is newer than what was saved; keep it.
        if draft == submitted { draft = "" }
        await load()
        return true
    }
}
