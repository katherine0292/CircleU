import Combine
import Foundation

/// Editing one saved entry. Save uses the revision it opened, so an edit can never overwrite a
/// newer version or bring back a deleted entry; on any failure the text stays on screen.
@MainActor
final class GuestEntryEditorViewModel: ObservableObject {
    enum SaveOutcome: Equatable {
        /// Saved and nothing newer was typed: the editor can close.
        case saved
        /// Saved, but stay: newer text was typed meanwhile, or there's a warning to read.
        case savedStay
        case failed
    }

    @Published var text: String
    @Published private(set) var saveError: String?
    @Published private(set) var isSaving = false
    /// The last saved version: the baseline for "unsaved changes".
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
    /// Leaving (Back or Discard) waits until a save in progress has finished.
    var canLeave: Bool { !isSaving }

    func save() async -> SaveOutcome {
        guard canSave else { return .failed }
        isSaving = true
        defer { isSaving = false }
        let submitted = text
        let words = trimmedText
        var warning: String?
        do {
            entry = try await store.update(id: entry.id, originalWords: words, expectedRevision: entry.revision)
        } catch GuestJournalError.savedButUnprotected {
            // Committed: move the baseline so it isn't saved twice, and keep the warning visible.
            entry = GuestJournalEntry(id: entry.id, originalWords: words, revision: entry.revision + 1,
                                      createdAt: entry.createdAt, updatedAt: Date())
            warning = GuestJournalViewModel.savedButUnprotectedMessage
        } catch GuestJournalError.staleRevision {
            saveError = Self.staleMessage
            return .failed
        } catch GuestJournalError.notFound {
            saveError = Self.deletedMessage
            return .failed
        } catch {
            saveError = GuestJournalViewModel.saveFailedMessage
            return .failed
        }
        saveError = warning
        // Text typed while saving is newer than what was saved; keep it as an unsaved change.
        if text == submitted { text = entry.originalWords }
        return warning == nil && !hasChanges ? .saved : .savedStay
    }
}
