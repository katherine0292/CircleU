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

    private let store: any GuestJournalStore

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

    /// Saves the draft as a new entry. On failure the draft stays and an error is shown.
    func saveDraft() async {
        let words = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !words.isEmpty, !isSaving else { return }
        isSaving = true
        defer { isSaving = false }
        do {
            _ = try await store.create(originalWords: words)
            draft = ""
            saveError = nil
            await load()
        } catch {
            saveError = Self.saveFailedMessage
        }
    }
}
