import Combine
import Foundation

/// Practice history, plus deleting things that practice messages can be linked to.
@MainActor
final class GuestPracticeViewModel: ObservableObject {
    enum LoadState: Equatable {
        case loading
        case loaded([GuestPracticeMessage])
        /// Shown as an error with Try again, never as an empty history.
        case failed(String)
    }

    @Published private(set) var loadState: LoadState = .loading

    static let loadFailedMessage = "Couldn’t open your practice. Try again."
    static let deleteFailedMessage = "Couldn’t delete. Try again."

    let store: any GuestPracticeStore
    /// Opt-in wording suggestions; nil hides "Get a suggestion".
    let suggester: (any GuestSuggesting)?

    init(store: any GuestPracticeStore, suggester: (any GuestSuggesting)? = nil) {
        self.store = store
        self.suggester = suggester
    }

    var messages: [GuestPracticeMessage] {
        if case .loaded(let messages) = loadState { messages } else { [] }
    }

    func message(id: UUID) -> GuestPracticeMessage? {
        messages.first { $0.id == id }
    }

    func linkedMessages(to entryID: UUID) -> [GuestPracticeMessage] {
        messages.filter { $0.sourceEntryID == entryID }
    }

    func load() async {
        if case .loaded = loadState {} else { loadState = .loading }
        do {
            loadState = .loaded(try await store.loadPractice())
        } catch {
            loadState = .failed(Self.loadFailedMessage)
        }
    }

    /// Returns nil when deleted, or the message to show. A failed delete keeps the message.
    /// A committed delete whose files couldn't be fully secured adds a lasting notice.
    func deleteMessage(id: UUID, journal: GuestJournalViewModel) async -> String? {
        do {
            try await store.deletePractice(id: id)
        } catch GuestJournalError.savedButUnprotected {
            journal.addNotice(GuestJournalViewModel.savedButUnprotectedMessage) // Committed: it's gone.
        } catch {
            return Self.deleteFailedMessage
        }
        await load()
        return nil
    }

    /// Deletes a journal entry, keeping or deleting its linked messages in the same transaction.
    /// Returns nil when deleted, or the message to show. A failed delete keeps everything.
    func deleteEntry(id: UUID, linkedPractice: GuestLinkedPracticeChoice,
                     journal: GuestJournalViewModel) async -> String? {
        do {
            try await store.deleteEntry(id: id, linkedPractice: linkedPractice)
        } catch GuestJournalError.savedButUnprotected {
            journal.addNotice(GuestJournalViewModel.savedButUnprotectedMessage) // Committed: it's gone.
        } catch GuestJournalError.notFound {
            // Already gone; refresh below.
        } catch {
            return Self.deleteFailedMessage
        }
        await journal.load()
        await load()
        return nil
    }
}

/// One practice message: written from scratch or from a journal entry, saved separately from
/// copying. Copying never saves or sends; saving never sends.
@MainActor
final class GuestPracticeComposerViewModel: ObservableObject {
    @Published var situation: String
    @Published var goal: String
    @Published var wording: String
    /// The last saved version, or nil for a new message.
    @Published private(set) var saved: GuestPracticeMessage?
    /// A saved message is shown read-only until Edit.
    @Published private(set) var isEditing: Bool
    @Published private(set) var isSaving = false
    @Published private(set) var saveError: String?
    @Published private(set) var didCopy = false
    /// Up to three suggested options, shown only after "Get a suggestion".
    @Published private(set) var suggestions: GuestWordingSuggestions?
    @Published private(set) var isSuggesting = false
    @Published private(set) var suggestionError: String?
    /// The wording before "Use this", so it can be undone.
    @Published private(set) var wordingBeforeSuggestion: String?
    /// The situation and goal the options were made from.
    private var suggestedFrom: (String, String)?
    /// Ignores a slow result when a newer request was made.
    private var suggestionRequest = 0

    static let suggestionFailedMessage = "Suggestions couldn’t be made right now. Your words are unchanged."

    static let saveFailedMessage = "Couldn’t save. Try again. Your words are still here."
    static let staleMessage = "This message changed somewhere else. Go back and open it again. Your words are still here."
    static let missingMessage = "This message or its journal entry no longer exists. Your words are still here to copy."

    let sourceEntryID: UUID?
    private let store: any GuestPracticeStore
    let suggester: (any GuestSuggesting)?

    /// A new message, on its own or practised from a journal entry.
    init(store: any GuestPracticeStore, sourceEntryID: UUID?, suggester: (any GuestSuggesting)? = nil) {
        self.store = store
        self.suggester = suggester
        self.sourceEntryID = sourceEntryID
        situation = ""
        goal = ""
        wording = ""
        isEditing = true
    }

    /// A saved message.
    init(store: any GuestPracticeStore, message: GuestPracticeMessage, suggester: (any GuestSuggesting)? = nil) {
        self.store = store
        self.suggester = suggester
        sourceEntryID = message.sourceEntryID
        saved = message
        situation = message.situation
        goal = message.goal
        wording = message.wording
        isEditing = false
    }

    private static func trim(_ text: String) -> String { text.trimmingCharacters(in: .whitespacesAndNewlines) }

    var hasChanges: Bool {
        guard let saved else { return [situation, goal, wording].contains { !Self.trim($0).isEmpty } }
        return Self.trim(situation) != saved.situation || Self.trim(goal) != saved.goal
            || Self.trim(wording) != saved.wording
    }

    var canSave: Bool { !Self.trim(wording).isEmpty && hasChanges && !isSaving }
    var canCopy: Bool { !Self.trim(wording).isEmpty }
    var canLeave: Bool { !isSaving }

    func edit() {
        isEditing = true
        didCopy = false
    }

    /// Opt-in: up to three options built from the situation, goal and draft. Changes nothing yet.
    func suggest() async {
        guard let suggester, !isSuggesting else { return }
        isSuggesting = true
        defer { isSuggesting = false }
        suggestionError = nil
        suggestionRequest += 1
        let request = suggestionRequest
        let inputs = (Self.trim(situation), Self.trim(goal))
        do {
            let result = try await suggester.wordingOptions(situation: inputs.0, goal: inputs.1,
                                                            draft: Self.trim(wording))
            guard request == suggestionRequest else { return }
            suggestions = result
            suggestedFrom = inputs
        } catch {
            guard request == suggestionRequest else { return }
            suggestionError = Self.suggestionFailedMessage
        }
    }

    /// The situation or goal changed after the options were made.
    var suggestionsAreStale: Bool {
        guard suggestions != nil, let suggestedFrom else { return false }
        return suggestedFrom != (Self.trim(situation), Self.trim(goal))
    }

    /// Puts an option in the wording box to edit; the previous wording can be restored.
    func use(_ option: GuestWordingOption) {
        if wordingBeforeSuggestion == nil { wordingBeforeSuggestion = wording }
        wording = option.text
        didCopy = false
    }

    func undoSuggestion() {
        guard let previous = wordingBeforeSuggestion else { return }
        wording = previous
        wordingBeforeSuggestion = nil
    }

    /// Puts the wording on the clipboard. Doesn't save, doesn't send.
    func copy(using pasteboard: (String) -> Void) {
        guard canCopy else { return }
        pasteboard(Self.trim(wording))
        didCopy = true
    }

    /// Saves only; nothing is sent. On failure every word stays on screen.
    @discardableResult
    func save() async -> Bool {
        guard canSave else { return false }
        isSaving = true
        defer { isSaving = false }
        let submitted = (situation, goal, wording)
        let fields = (Self.trim(situation), Self.trim(goal), Self.trim(wording))
        var warning: String?
        do {
            if let saved {
                self.saved = try await store.updatePractice(id: saved.id, situation: fields.0, goal: fields.1,
                                                            wording: fields.2, expectedRevision: saved.revision)
            } else {
                self.saved = try await store.createPractice(situation: fields.0, goal: fields.1, wording: fields.2,
                                                            sourceEntryID: sourceEntryID)
            }
        } catch GuestJournalError.savedButUnprotected(let id) {
            // Committed: record it so it isn't saved twice, and keep the warning visible.
            warning = GuestJournalViewModel.savedButUnprotectedMessage
            let now = Date()
            self.saved = GuestPracticeMessage(id: id, situation: fields.0, goal: fields.1, wording: fields.2,
                                              sourceEntryID: sourceEntryID, revision: (saved?.revision ?? -1) + 1,
                                              createdAt: saved?.createdAt ?? now, updatedAt: now)
        } catch GuestJournalError.staleRevision {
            saveError = Self.staleMessage
            return false
        } catch GuestJournalError.notFound {
            saveError = Self.missingMessage
            return false
        } catch {
            saveError = Self.saveFailedMessage
            return false
        }
        saveError = warning
        didCopy = false
        // Anything typed while saving is newer than what was saved: keep it, and keep editing.
        if (situation, goal, wording) == submitted {
            situation = fields.0
            goal = fields.1
            wording = fields.2
            isEditing = false
        }
        return true
    }
}

/// The "From: …" / "On its own" tag on a practice message.
enum GuestPracticeTag {
    static func label(sourceEntryID: UUID?, entries: [GuestJournalEntry]) -> String {
        guard let sourceEntryID, let entry = entries.first(where: { $0.id == sourceEntryID }) else {
            return "On its own"
        }
        let words = entry.originalWords.replacingOccurrences(of: "\n", with: " ")
        return "From: " + (words.count > 40 ? words.prefix(40).trimmingCharacters(in: .whitespaces) + "…" : words)
    }
}
