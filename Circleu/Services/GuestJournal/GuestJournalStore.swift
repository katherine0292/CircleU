import Foundation

/// A saved guest journal entry. A value type, so views and ViewModels never depend on SwiftData.
nonisolated struct GuestJournalEntry: Identifiable, Equatable, Sendable {
    let id: UUID
    var originalWords: String
    let revision: Int
    let createdAt: Date
    var updatedAt: Date
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
}

/// Guest-local journal persistence for the new experience. Implementations serialize every
/// operation, never touch legacy UserDefaults keys and never construct Firebase services.
nonisolated protocol GuestJournalStore: Sendable {
    /// Saved entries, most recently updated first.
    func loadAll() async throws -> [GuestJournalEntry]
    func create(originalWords: String) async throws -> GuestJournalEntry
    /// Saves an edit only if `expectedRevision` is still current; returns the new revision.
    func update(id: UUID, originalWords: String, expectedRevision: Int) async throws -> GuestJournalEntry
    func delete(id: UUID) async throws
}
