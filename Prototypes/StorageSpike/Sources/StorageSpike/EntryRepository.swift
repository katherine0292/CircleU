import Foundation

/// Invented journal entry used only by this spike.
public struct SpikeEntry: Codable, Equatable, Identifiable, Sendable {
    public var id: UUID
    public var revision: Int
    public var originalWords: String
    public var createdAt: Date
    public var updatedAt: Date

    public init(id: UUID = UUID(), revision: Int = 0, originalWords: String,
                createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.revision = revision
        self.originalWords = originalWords
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// Explicit outcomes the plan requires: a failed read is never an empty journal.
public enum RepositoryError: Error, Equatable {
    case unreadable(String)
    case unsupportedSchema(Int)
    case writeFailed(String)
    case staleRevision(expected: Int, found: Int)
    case notFound
}

public protocol EntryRepository {
    /// Entries newest first. A missing store on first launch is empty; an unreadable one throws.
    func loadAll() throws -> [SpikeEntry]
    /// Inserts a new entry (revision 0) or saves an edit of `entry.revision`, returning the stored revision.
    @discardableResult func save(_ entry: SpikeEntry) throws -> SpikeEntry
    func delete(id: UUID) throws
}
