import Foundation
import SwiftData

/// Option A: SwiftData with a versioned schema and a lightweight migration.
public enum SpikeSchemaV1: VersionedSchema {
    public static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }
    public static var models: [any PersistentModel.Type] { [Entry.self] }

    @Model public final class Entry {
        @Attribute(.unique) public var id: UUID
        public var words: String
        public var createdAt: Date

        public init(id: UUID, words: String, createdAt: Date) {
            self.id = id
            self.words = words
            self.createdAt = createdAt
        }
    }
}

public enum SpikeSchemaV2: VersionedSchema {
    public static var versionIdentifier: Schema.Version { Schema.Version(2, 0, 0) }
    public static var models: [any PersistentModel.Type] { [Entry.self] }

    @Model public final class Entry {
        @Attribute(.unique) public var id: UUID
        @Attribute(originalName: "words") public var originalWords: String
        public var revision: Int = 0
        public var createdAt: Date
        public var updatedAt: Date = Date.distantPast

        public init(id: UUID, originalWords: String, revision: Int, createdAt: Date, updatedAt: Date) {
            self.id = id
            self.originalWords = originalWords
            self.revision = revision
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }
}

public enum SpikeMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] { [SpikeSchemaV1.self, SpikeSchemaV2.self] }
    public static var stages: [MigrationStage] {
        [.lightweight(fromVersion: SpikeSchemaV1.self, toVersion: SpikeSchemaV2.self)]
    }
}

public final class SwiftDataEntryRepository: EntryRepository {
    public typealias Entry = SpikeSchemaV2.Entry
    public let storeURL: URL
    private let container: ModelContainer

    public init(directory: URL) throws {
        storeURL = directory.appendingPathComponent("journal.store")
        do {
            container = try ModelContainer(
                for: Schema(versionedSchema: SpikeSchemaV2.self),
                migrationPlan: SpikeMigrationPlan.self,
                configurations: ModelConfiguration(url: storeURL)
            )
        } catch {
            throw RepositoryError.unreadable("container: \(error)")
        }
    }

    private func context() -> ModelContext { ModelContext(container) }

    public func loadAll() throws -> [SpikeEntry] {
        do {
            let rows = try context().fetch(FetchDescriptor<Entry>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]))
            return rows.map { SpikeEntry(id: $0.id, revision: $0.revision, originalWords: $0.originalWords,
                                         createdAt: $0.createdAt, updatedAt: $0.updatedAt) }
        } catch {
            throw RepositoryError.unreadable("fetch: \(error)")
        }
    }

    @discardableResult
    public func save(_ entry: SpikeEntry) throws -> SpikeEntry {
        let context = context()
        let id = entry.id
        let existing: [Entry]
        do { existing = try context.fetch(FetchDescriptor<Entry>(predicate: #Predicate { $0.id == id })) } catch {
            throw RepositoryError.unreadable("fetch: \(error)")
        }
        var stored = entry
        if let row = existing.first {
            guard row.revision == entry.revision else {
                throw RepositoryError.staleRevision(expected: row.revision, found: entry.revision)
            }
            stored.revision = entry.revision + 1
            stored.createdAt = row.createdAt
            row.originalWords = stored.originalWords
            row.revision = stored.revision
            row.updatedAt = stored.updatedAt
        } else {
            stored.revision = 0
            context.insert(Entry(id: id, originalWords: entry.originalWords, revision: 0,
                                 createdAt: entry.createdAt, updatedAt: entry.updatedAt))
        }
        do { try context.save() } catch { throw RepositoryError.writeFailed("\(error)") }
        return stored
    }

    public func delete(id: UUID) throws {
        let context = context()
        guard let row = try? context.fetch(FetchDescriptor<Entry>(predicate: #Predicate { $0.id == id })).first else {
            throw RepositoryError.notFound
        }
        context.delete(row)
        do { try context.save() } catch { throw RepositoryError.writeFailed("\(error)") }
    }
}
