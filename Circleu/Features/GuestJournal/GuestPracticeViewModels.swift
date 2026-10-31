import Combine
import Foundation

/// An unsaved new practice message, kept on this phone across relaunches.
nonisolated struct GuestPracticeDraft: Codable, Equatable, Sendable {
    var id = UUID()
    var situation = ""
    var goal = ""
    var wording = ""
    var sourceEntryID: UUID?
    var conversation: GuestPracticeConversation? = nil

    var isEmpty: Bool {
        [situation, goal, wording, conversation?.originalWords ?? "", conversation?.pendingReply ?? "",
         conversation?.pendingContext ?? "", conversation?.turns.map(\.text).joined() ?? ""].allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
}

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
    var makeDictationEngine: () -> any GuestDictationEngine = { SpeechDictationEngine() }
    /// Opt-in wording suggestions; nil hides "Get a suggestion".
    let suggester: (any GuestSuggesting)?
    /// The unsaved new message, if there is one ("Continue your draft").
    @Published private(set) var keptDraft: GuestPracticeDraft?
    @Published private(set) var draftWarning: String?
    /// Changes when Delete all runs; open Practice screens close, and their late draft writes are ignored.
    @Published private(set) var dataGeneration = 0
    private let drafts: (any GuestDraftStore)?
    private var lastDraftOperation: Task<Void, Never>?
    /// False when a kept draft exists but couldn't be read: it's left untouched, not overwritten.
    private var canKeepDraft: Bool
    private var draftsPaused = false
    /// The screen currently allowed to write the kept draft.
    private var draftOwner: ObjectIdentifier?

    /// The newest screen opened for a new message takes over writing its draft.
    func claimDraft(by owner: ObjectIdentifier) { draftOwner = owner }

    /// Whether this screen still owns the kept draft (an older screen doesn't).
    func ownsDraft(_ owner: ObjectIdentifier) -> Bool { draftOwner == nil || draftOwner == owner }

    static let draftNotKeptMessage = "Your practice draft couldn’t be kept on this phone. Save it before you close the app."
    static let otherDraftMessage = "Another practice draft is kept. Save this one, or go back to choose."
    static let draftUnprotectedMessage = "Your practice draft is kept, but this phone couldn’t fully secure it."
    static let draftUnreadableMessage = "An earlier practice draft couldn’t be opened. New writing here isn’t kept, so save before closing."

    init(store: any GuestPracticeStore, suggester: (any GuestSuggesting)? = nil, drafts: (any GuestDraftStore)? = nil) {
        self.store = store
        self.suggester = suggester
        self.drafts = drafts
        canKeepDraft = drafts != nil
    }

    /// Restores a kept draft. One that was already saved (cleanup didn't finish) is removed, not
    /// offered again; one that can't be read is left untouched and never overwritten.
    func loadDraft() async {
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
        guard let data = kept.text.data(using: .utf8),
              var draft = try? JSONDecoder().decode(GuestPracticeDraft.self, from: data) else {
            canKeepDraft = false
            draftWarning = Self.draftUnreadableMessage
            return
        }
        switch try? await store.isDraftSaved(kept.id) {
        case true?:
            enqueue { try await drafts.remove(id: kept.id) } // Saved (or deleted) already.
            return
        case nil:
            // Can't tell whether it was saved: don't offer it, and don't overwrite it.
            canKeepDraft = false
            draftWarning = Self.draftUnreadableMessage
            return
        case false?:
            break
        }
        draft.id = kept.id
        keptDraft = draft.isEmpty ? nil : draft
        if !kept.isProtected { draftWarning = Self.draftUnprotectedMessage }
    }

    /// Keeps the latest version of a new message; empty text removes the kept copy. Writes from a
    /// screen opened before Delete all (an older `generation`) are ignored.
    func keepDraft(_ draft: GuestPracticeDraft, generation: Int? = nil, owner: ObjectIdentifier? = nil) {
        guard generation == nil || generation == dataGeneration, !draftsPaused else { return }
        // Only the newest screen for a draft may write it, so an older screen can't overwrite newer text.
        if let owner, let current = draftOwner, current != owner {
            draftWarning = Self.otherDraftMessage
            return
        }
        // One draft is kept at a time; another screen never replaces it silently.
        if let current = keptDraft, current.id != draft.id {
            draftWarning = Self.otherDraftMessage
            return
        }
        keptDraft = draft.isEmpty ? nil : draft
        guard let drafts, canKeepDraft else { return }
        let text = draft.isEmpty ? "" : (try? JSONEncoder().encode(draft)).flatMap { String(data: $0, encoding: .utf8) } ?? ""
        let alreadyQueued = pendingDraftWrite != nil
        pendingDraftWrite = (draft.id, text) // A burst of edits is one write.
        guard !alreadyQueued else { return }
        enqueue { [weak self] in
            guard let write = await self?.takePendingDraftWrite() else { return }
            try await drafts.save(id: write.id, text: write.text)
        }
    }

    private var pendingDraftWrite: (id: UUID, text: String)?

    private func takePendingDraftWrite() -> (id: UUID, text: String)? {
        defer { pendingDraftWrite = nil }
        return pendingDraftWrite
    }

    /// An older practice draft couldn't be read; it's left as it was.
    func noteUnreadableDraft() {
        if draftWarning == nil { draftWarning = GuestJournalViewModel.olderDraftUnreadableMessage }
    }

    /// The message was saved or discarded: remove that draft (a newer one has another ID).
    func clearDraft(id: UUID) {
        if keptDraft?.id == id { keptDraft = nil }
        guard let drafts else { return }
        enqueue { try await drafts.remove(id: id) }
    }

    /// Delete all, before: no draft writes until `resumeDrafts`, and pending ones finish first.
    func pauseDrafts() async {
        draftsPaused = true
        await lastDraftOperation?.value
    }

    /// Delete all, after: `deleted` closes open Practice screens, whose later writes are ignored
    /// (the kept draft went in the same transaction). Draft keeping resumes either way.
    func resumeDrafts(afterDeleting deleted: Bool) {
        if deleted {
            pendingDraftWrite = nil
            keptDraft = nil
            draftWarning = nil
            draftOwner = nil
            canKeepDraft = drafts != nil
            dataGeneration += 1
        }
        draftsPaused = false
    }

    func flushDraft() async { await lastDraftOperation?.value }

    private func enqueue(_ operation: @escaping @Sendable () async throws -> Void) {
        let previous = lastDraftOperation
        lastDraftOperation = Task { [weak self] in
            await previous?.value
            do { try await operation() } catch GuestJournalError.protectionFailed {
                self?.draftWarning = Self.draftUnprotectedMessage // Kept, but not fully secured.
            } catch {
                self?.draftWarning = Self.draftNotKeptMessage
            }
        }
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
    @Published var wording: String {
        didSet {
            // Typing, clearing or Undo changes what Copy would place on the clipboard.
            if wording != oldValue { didCopy = false }
        }
    }
    /// Message first: write, optionally ask for guidance, review the result, then refine and save.
    enum Stage { case prepare, guide, result, refine, reply }
    @Published var stage: Stage = .prepare
    @Published var conversation: GuestPracticeConversation?
    var scene: String {
        get { conversation?.scene ?? "Work" }
        set { var value = conversation ?? GuestPracticeConversation(); value.scene = newValue; conversation = value }
    }
    var tone: String {
        get { conversation?.tone ?? "Balanced" }
        set { var value = conversation ?? GuestPracticeConversation(); value.tone = newValue; conversation = value }
    }
    var replyText: String {
        get { conversation?.pendingReply ?? "" }
        set { var value = conversation ?? GuestPracticeConversation(); value.pendingReply = newValue; conversation = value }
    }
    var replyContext: String {
        get { conversation?.pendingContext ?? "" }
        set { var value = conversation ?? GuestPracticeConversation(); value.pendingContext = newValue; conversation = value }
    }
    var canContinueReply: Bool { !Self.trim(replyText).isEmpty || !Self.trim(replyContext).isEmpty }

    func prepareRefinement() {
        guard !Self.trim(wording).isEmpty else { return }
        var value = conversation ?? GuestPracticeConversation()
        if value.originalWords.isEmpty { value.originalWords = Self.trim(wording) }
        conversation = value
        stage = .refine
    }

    func openReply() { edit(); stage = .reply }

    // MARK: Message-first entry (P9)

    /// Words alone are enough to ask for a review; no situation, goal or tone is required.
    var canReviewWording: Bool { !Self.trim(wording).isEmpty && !isSuggesting }

    /// "Review wording": keep my first words, then ask for a suggestion on the result screen.
    func reviewWording() async {
        guard canReviewWording else { return }
        var value = conversation ?? GuestPracticeConversation()
        if value.originalWords.isEmpty { value.originalWords = Self.trim(wording) }
        conversation = value
        resultIsFromIntent = false
        startReview()
        await suggest()
    }

    /// A new review: earlier options can't be used while it runs, and an older Undo no longer
    /// applies to the words being reviewed.
    private func startReview() {
        suggestions = nil
        suggestedFrom = nil
        suggestionError = nil
        wordingBeforeSuggestion = nil
        stage = .result
    }

    /// Blank start: an intent from guidance, and no words yet, can ask for words.
    var canFindWordsFromIntent: Bool { Self.trim(wording).isEmpty && !Self.trim(goal).isEmpty && !isSuggesting }

    /// "Find words from my intent": the result is labelled as made from intent, never as my message.
    func findWordsFromIntent() async {
        guard canFindWordsFromIntent else { return }
        resultIsFromIntent = true
        startReview()
        await suggest()
    }

    /// The result came from an intent only, so it must not be shown as words I wrote.
    @Published private(set) var resultIsFromIntent = false

    /// "Help me get started": optional, and it never requests anything by itself.
    func openGuidance() { stage = .guide }
    var canContinueGuidance: Bool { !Self.trim(goal).isEmpty }
    /// Back to my words with the intent kept; nothing is requested.
    func continueGuidance() {
        guard canContinueGuidance else { return }
        stage = .prepare
    }
    func closeGuidance() { stage = .prepare }

    /// The one wording shown first on the result screen: the chosen tone, when there is one.
    var suggestedWording: GuestWordingOption? { suggestions?.options.first }
    /// The other tones, for "Compare with mine".
    var otherWordings: [GuestWordingOption] { Array(suggestions?.options.dropFirst() ?? []) }

    /// "Use this wording": the suggestion goes into my words to edit; Undo restores them.
    func useSuggestedWording() {
        guard let option = suggestedWording else { return }
        use(option)
        stage = .refine
    }

    /// "Keep my wording": nothing changes, and a review still running is let go.
    func keepMyWording() {
        suggestionRequest += 1 // A late result is ignored.
        if !Self.trim(wording).isEmpty {
            var value = conversation ?? GuestPracticeConversation()
            if value.originalWords.isEmpty { value.originalWords = Self.trim(wording) }
            conversation = value
        }
        stage = .refine
    }

    /// "Save without feedback": my words, as they are, with no request made and no review history.
    @discardableResult
    func saveWithoutFeedback() async -> Bool {
        guard !Self.trim(wording).isEmpty else { return false }
        return await save()
    }

    /// Freeze the previous prepared wording, keeping attribution. The new wording starts empty.
    func continueReply() {
        guard canContinueReply else { return }
        var value = conversation ?? GuestPracticeConversation()
        if value.originalWords.isEmpty { value.originalWords = Self.trim(wording) }
        if !Self.trim(wording).isEmpty { value.turns.append(.init(kind: .wording, text: Self.trim(wording))) }
        if !Self.trim(replyText).isEmpty { value.turns.append(.init(kind: .theirReply, text: Self.trim(replyText))) }
        if !Self.trim(replyContext).isEmpty { value.turns.append(.init(kind: .context, text: Self.trim(replyContext))) }
        value.pendingReply = ""
        value.pendingContext = ""
        conversation = value
        wording = ""
        suggestions = nil
        suggestedFrom = nil
        wordingBeforeSuggestion = nil
        suggestionRequest += 1
        stage = .refine
    }

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
    /// The situation, goal and wording the options were made from (wording follows "Use this").
    private var suggestedFrom: (String, String, String)?
    /// Ignores a slow result when a newer request was made.
    private var suggestionRequest = 0

    static let suggestionFailedMessage = "Suggestions couldn’t be made right now. Your words are unchanged."

    static let saveFailedMessage = "Couldn’t save. Try again. Your words are still here."
    static let staleMessage = "This message changed somewhere else. Go back and open it again. Your words are still here."
    static let closedByDeleteMessage = "Everything was deleted after this screen opened, so this wasn’t saved."
    static let alreadySavedMessage = "This draft was already saved in Practice, so it wasn’t saved again."
    static let missingMessage = "This message or its journal entry no longer exists. Your words are still here to copy."

    let sourceEntryID: UUID?
    private let store: any GuestPracticeStore
    let suggester: (any GuestSuggesting)?
    /// A new message's draft identity; nil for saved messages (edits aren't drafted).
    let draftID: UUID?
    private var draftObserver: AnyCancellable?
    private weak var practiceModel: GuestPracticeViewModel?
    /// Delete all closes this screen; a save from it afterwards is refused.
    private var generationAtCreation: Int?

    /// This screen still owns the kept draft, so saving records and clears it. An older screen
    /// saves its text as its own message and leaves the newer draft alone.
    var ownsDraft: Bool { practiceModel?.ownsDraft(ObjectIdentifier(self)) ?? true }

    /// A new message, on its own or practised from a journal entry, optionally restoring a kept
    /// draft. With `practice`, every change is kept on this phone until saved or discarded.
    init(store: any GuestPracticeStore, sourceEntryID: UUID?, suggester: (any GuestSuggesting)? = nil,
         restoring draft: GuestPracticeDraft? = nil, practice: GuestPracticeViewModel? = nil) {
        self.store = store
        self.suggester = suggester
        self.sourceEntryID = sourceEntryID
        draftID = draft?.id ?? UUID()
        situation = draft?.situation ?? ""
        goal = draft?.goal ?? ""
        wording = draft?.wording ?? ""
        conversation = draft?.conversation
        if draft?.conversation?.originalWords.isEmpty == false { stage = .refine }
        isEditing = true
        guard let practice, let draftID else { return }
        practiceModel = practice
        generationAtCreation = practice.dataGeneration
        let generation = practice.dataGeneration
        let owner = ObjectIdentifier(self)
        practice.claimDraft(by: owner)
        draftObserver = Publishers.CombineLatest4($situation, $goal, $wording, $conversation)
            .dropFirst()
            .sink { [weak self, weak practice] situation, goal, wording, conversation in
                guard let self, self.saved == nil else { return }
                practice?.keepDraft(GuestPracticeDraft(id: draftID, situation: situation, goal: goal,
                                                       wording: wording, sourceEntryID: sourceEntryID, conversation: conversation),
                                    generation: generation, owner: owner)
            }
    }

    /// A saved message.
    init(store: any GuestPracticeStore, message: GuestPracticeMessage, suggester: (any GuestSuggesting)? = nil) {
        self.store = store
        self.suggester = suggester
        draftID = nil
        sourceEntryID = message.sourceEntryID
        saved = message
        situation = message.situation
        goal = message.goal
        wording = message.wording
        conversation = message.conversation
        stage = .refine
        isEditing = false
    }

    private static func trim(_ text: String) -> String { text.trimmingCharacters(in: .whitespacesAndNewlines) }

    var hasChanges: Bool {
        guard let saved else { return [situation, goal, wording].contains { !Self.trim($0).isEmpty } || conversation != nil }
        return Self.trim(situation) != saved.situation || Self.trim(goal) != saved.goal
            || Self.trim(wording) != saved.wording || conversation != saved.conversation
    }

    var canSave: Bool { !Self.trim(wording).isEmpty && hasChanges && !isSaving }
    var canCopy: Bool { !Self.trim(wording).isEmpty }
    var canLeave: Bool { !isSaving }

    func edit() {
        stage = .refine
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
        let inputs = suggestionInputs
        do {
            let result: GuestWordingSuggestions
            if let conversation {
                result = try await suggester.conversationOptions(situation: Self.trim(situation), goal: Self.trim(goal),
                    draft: Self.trim(wording), conversation: conversation)
            } else {
                result = try await suggester.wordingOptions(situation: inputs.0, goal: inputs.1, draft: inputs.2)
            }
            guard request == suggestionRequest else { return }
            suggestions = Self.preferredFirst(result, tone: tone)
            suggestedFrom = inputs
        } catch {
            guard request == suggestionRequest else { return }
            suggestionError = Self.suggestionFailedMessage
        }
    }

    /// The chosen tone leads; the engine's own order is kept for the rest.
    static func preferredFirst(_ result: GuestWordingSuggestions, tone: String) -> GuestWordingSuggestions {
        let preferred = tone == "Soft" ? "Gentle" : tone == "Firm" ? "Firm" : "Clear"
        guard result.options.contains(where: { $0.tone == preferred }) else { return result }
        var value = result
        value.options = result.options.filter { $0.tone == preferred } + result.options.filter { $0.tone != preferred }
        return value
    }

    /// The situation, goal or wording changed after the options were made (using an option doesn't count).
    var suggestionsAreStale: Bool {
        guard suggestions != nil, let suggestedFrom else { return false }
        return suggestedFrom != suggestionInputs
    }

    private var suggestionInputs: (String, String, String) {
        let context = conversation.map { "\(Self.trim(situation))\n\($0.suggestionContext)" } ?? Self.trim(situation)
        let intent = conversation.map { "\(Self.trim(goal))\nPreferred tone: \($0.tone)" } ?? Self.trim(goal)
        return (context, intent, Self.trim(wording))
    }

    /// Puts an option in the wording box to edit; the previous wording can be restored.
    func use(_ option: GuestWordingOption) {
        if wordingBeforeSuggestion == nil { wordingBeforeSuggestion = wording }
        wording = option.text
        suggestedFrom?.2 = Self.trim(option.text)
        didCopy = false
    }

    func undoSuggestion() {
        guard let previous = wordingBeforeSuggestion else { return }
        wording = previous
        wordingBeforeSuggestion = nil
        suggestedFrom?.2 = Self.trim(previous)
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
        if let practiceModel, let generationAtCreation, practiceModel.dataGeneration != generationAtCreation {
            saveError = Self.closedByDeleteMessage // Everything was deleted after this screen opened.
            return false
        }
        isSaving = true
        defer { isSaving = false }
        let submitted = (situation, goal, wording)
        let submittedConversation = conversation
        let fields = (Self.trim(situation), Self.trim(goal), Self.trim(wording))
        var warning: String?
        do {
            if let conversation = submittedConversation {
                guard let extended = store as? any GuestConversationStore else { throw GuestJournalError.saveFailed("Conversation storage unavailable") }
                if let saved {
                    self.saved = try await extended.updateConversation(id: saved.id, situation: fields.0, goal: fields.1,
                        wording: fields.2, expectedRevision: saved.revision, conversation: conversation)
                } else {
                    self.saved = try await extended.createConversation(situation: fields.0, goal: fields.1, wording: fields.2,
                        sourceEntryID: sourceEntryID, draftID: ownsDraft ? draftID : nil, conversation: conversation)
                }
            } else if let saved {
                self.saved = try await store.updatePractice(id: saved.id, situation: fields.0, goal: fields.1,
                                                            wording: fields.2, expectedRevision: saved.revision)
            } else {
                self.saved = try await store.createPractice(situation: fields.0, goal: fields.1, wording: fields.2,
                                                            sourceEntryID: sourceEntryID,
                                                            draftID: ownsDraft ? draftID : nil)
            }
        } catch GuestJournalError.savedButUnprotected(let id) {
            // Committed: record it so it isn't saved twice, and keep the warning visible.
            warning = GuestJournalViewModel.savedButUnprotectedMessage
            let now = Date()
            self.saved = GuestPracticeMessage(id: id, situation: fields.0, goal: fields.1, wording: fields.2,
                                              sourceEntryID: sourceEntryID, revision: (saved?.revision ?? -1) + 1,
                                              createdAt: saved?.createdAt ?? now, updatedAt: now, conversation: submittedConversation)
        } catch GuestJournalError.staleRevision {
            saveError = Self.staleMessage
            return false
        } catch GuestJournalError.draftAlreadySaved {
            saveError = Self.alreadySavedMessage // Not saved twice.
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
        if (situation, goal, wording) == submitted && conversation == submittedConversation {
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
