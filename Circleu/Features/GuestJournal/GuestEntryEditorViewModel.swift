import Combine
import Foundation

/// Editing one saved entry. Save uses the revision it opened, so an edit can never overwrite a
/// newer version or bring back a deleted entry; on any failure the text stays on screen.
@MainActor
final class GuestEntryEditorViewModel: ObservableObject {
    @Published var text: String
    @Published private(set) var saveError: String?
    @Published private(set) var isSaving = false
    @Published private(set) var entry: GuestJournalEntry

    static let staleMessage = "This entry changed somewhere else. Go back and open it again. Your text is still here."
    static let deletedMessage = "This entry no longer exists. Your text is still here if you want to copy it."

    private let store: any GuestJournalStore

    init(entry: GuestJournalEntry, store: any GuestJournalStore) {
        self.entry = entry
        self.text = entry.originalWords
        self.store = store
    }

    var trimmedText: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }
    /// Leaving with these unsaved changes asks "Keep editing / Discard".
    var hasChanges: Bool { trimmedText != entry.originalWords }
    var canSave: Bool { hasChanges && !trimmedText.isEmpty && !isSaving }

    /// Returns true once the edit is saved (including "saved but not fully secured").
    func save() async -> Bool {
        guard canSave else { return false }
        isSaving = true
        defer { isSaving = false }
        do {
            entry = try await store.update(id: entry.id, originalWords: trimmedText, expectedRevision: entry.revision)
            saveError = nil
            text = entry.originalWords
            return true
        } catch GuestJournalError.savedButUnprotected {
            saveError = GuestJournalViewModel.savedButUnprotectedMessage
            return true
        } catch GuestJournalError.staleRevision {
            saveError = Self.staleMessage
        } catch GuestJournalError.notFound {
            saveError = Self.deletedMessage
        } catch {
            saveError = GuestJournalViewModel.saveFailedMessage
        }
        return false
    }
}
