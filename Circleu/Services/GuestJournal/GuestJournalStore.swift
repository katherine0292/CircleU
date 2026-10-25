import Foundation

/// A saved guest journal entry. A value type, so views and ViewModels never depend on SwiftData.
nonisolated struct GuestJournalEntry: Identifiable, Equatable, Sendable {
    let id: UUID
    var originalWords: String
    let revision: Int
    let createdAt: Date
    var updatedAt: Date
    /// A suggestion the person kept (and may have edited), shown apart from their own words.
    var reflection: GuestReflection? = nil
    /// One optional next step; nil when skipped.
    var nextStep: String? = nil
    var nextStepDone = false
}

/// Where a suggestion came from, so a template is never presented as a personal AI analysis.
nonisolated enum GuestSuggestionSource: String, Sendable, Equatable {
    /// Apple Intelligence's on-device model.
    case onDevice
    /// Built-in guided prompts (no model).
    case guided
}

/// A short, tentative reflection: what happened, a possible feeling, and one thing to consider.
nonisolated struct GuestReflection: Equatable, Sendable {
    var summary: String
    var feeling: String
    var insight: String
    var source: GuestSuggestionSource
    /// The words it was made from. After an edit it's shown as based on an earlier version.
    var basedOnWords: String
}

extension GuestJournalEntry {
    /// The words changed after the reflection was made.
    var isReflectionStale: Bool {
        guard let reflection else { return false }
        return reflection.basedOnWords != originalWords
    }
}

nonisolated enum GuestJournalError: Error, Equatable, Sendable {
    /// The store couldn't be opened or read. Never present this as an empty journal.
    case storeUnavailable(String)
    /// A store that was set up before has disappeared; don't silently start a new one.
    case storeMissing
    /// The entry doesn't exist, for example because it was deleted. Updates never recreate it.
    case notFound
    /// Someone saved a newer version first.
    case staleRevision(current: Int, expected: Int)
    /// The change wasn't saved; previously saved data is unchanged.
    case saveFailed(String)
    /// Data Protection couldn't be applied while opening; the store isn't used.
    case protectionFailed(String)
    /// The change **was** saved, but protecting a new store file failed. Don't retry the save.
    case savedButUnprotected(entryID: UUID)
    /// This draft was already saved as an entry (it may since have been edited or deleted).
    case draftAlreadySaved
}

/// Guest-local journal persistence for the new experience. Implementations serialize every
/// operation, never touch legacy UserDefaults keys and never construct Firebase services.
nonisolated protocol GuestJournalStore: Sendable {
    /// Saved entries, most recently updated first.
    func loadAll() async throws -> [GuestJournalEntry]
    /// Creates an entry. With a `draftID`, records that draft as saved in the same transaction and
    /// refuses a draft that was saved before, so a leftover draft can never duplicate or resurrect.
    func create(originalWords: String, draftID: UUID?) async throws -> GuestJournalEntry
    /// Whether a draft with this ID was already saved as an entry.
    func isDraftSaved(_ draftID: UUID) async throws -> Bool
    /// Saves an edit only if `expectedRevision` is still current; returns the new revision.
    func update(id: UUID, originalWords: String, expectedRevision: Int) async throws -> GuestJournalEntry
    func delete(id: UUID) async throws
}

extension GuestJournalStore {
    func create(originalWords: String) async throws -> GuestJournalEntry {
        try await create(originalWords: originalWords, draftID: nil)
    }
}

/// Wording practised in Practice, saved on this phone and never sent.
nonisolated struct GuestPracticeMessage: Identifiable, Equatable, Sendable {
    let id: UUID
    var situation: String
    var goal: String
    var wording: String
    /// The journal entry it was practised from, or nil when it stands on its own.
    var sourceEntryID: UUID?
    let revision: Int
    let createdAt: Date
    var updatedAt: Date
}

/// What happens to practice messages linked to a journal entry that's being deleted.
nonisolated enum GuestLinkedPracticeChoice: Sendable {
    /// Keep the messages; they become "On its own". The default.
    case keepMessages
    case deleteBoth
}

/// Practice messages, in the same store as the journal. Same rules: serialized, local only.
nonisolated protocol GuestPracticeStore: Sendable {
    /// Saved messages, most recently updated first.
    func loadPractice() async throws -> [GuestPracticeMessage]
    /// Fails with `notFound` if `sourceEntryID` names an entry that no longer exists. With a
    /// `draftID`, records that draft as saved in the same transaction and refuses one saved before.
    func createPractice(situation: String, goal: String, wording: String, sourceEntryID: UUID?,
                        draftID: UUID?) async throws -> GuestPracticeMessage
    /// Whether a draft with this ID was already saved (journal or practice).
    func isDraftSaved(_ draftID: UUID) async throws -> Bool
    func updatePractice(id: UUID, situation: String, goal: String, wording: String,
                        expectedRevision: Int) async throws -> GuestPracticeMessage
    func deletePractice(id: UUID) async throws
    /// Deletes a journal entry and, in the same transaction, unlinks or deletes its messages.
    func deleteEntry(id: UUID, linkedPractice: GuestLinkedPracticeChoice) async throws
}

extension GuestPracticeStore {
    func createPractice(situation: String, goal: String, wording: String,
                        sourceEntryID: UUID?) async throws -> GuestPracticeMessage {
        try await createPractice(situation: situation, goal: goal, wording: wording, sourceEntryID: sourceEntryID,
                                 draftID: nil)
    }
}

/// Data controls for everything in the guest store.
nonisolated protocol GuestDataStore: Sendable {
    /// Deletes every entry, reflection, next step, practice message and saved-draft receipt, in
    /// one transaction: all of it or none of it. `consumedDraftIDs` are recorded as used in the
    /// same transaction, so drafts moved aside for deletion can never come back after a crash.
    /// Never touches the earlier app's data.
    func deleteAll(consumedDraftIDs: [UUID]) async throws
    /// Entries and practice messages read together, for a consistent export.
    func snapshot() async throws -> (entries: [GuestJournalEntry], messages: [GuestPracticeMessage])
}

/// Entries with an optional reflection and next step. Same store, same rules.
nonisolated protocol GuestReflectionStore: Sendable {
    /// Like `GuestJournalStore.create`, with an accepted reflection and next step saved alongside.
    func create(originalWords: String, draftID: UUID?, reflection: GuestReflection?,
                nextStep: String?) async throws -> GuestJournalEntry
    /// Replaces the reflection and next step (nil removes them) if `expectedRevision` is current.
    func updateReflection(id: UUID, reflection: GuestReflection?, nextStep: String?, nextStepDone: Bool,
                          expectedRevision: Int) async throws -> GuestJournalEntry
}
