import Foundation

/// Option B: one versioned JSON document, replaced atomically on every write.
public final class FileEntryRepository: EntryRepository {
    public static let currentSchema = 2

    private struct EnvelopeV2: Codable {
        var schemaVersion: Int
        var entries: [SpikeEntry]
    }

    /// Schema 1 stored the text as `words` and had no revision.
    private struct EntryV1: Codable {
        var id: UUID
        var words: String
        var createdAt: Date
    }

    private struct EnvelopeV1: Codable {
        var schemaVersion: Int
        var entries: [EntryV1]
    }

    private struct VersionProbe: Decodable { var schemaVersion: Int }

    public let fileURL: URL
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    public init(directory: URL) {
        fileURL = directory.appendingPathComponent("journal.json")
    }

    public func loadAll() throws -> [SpikeEntry] {
        try readEntries().sorted { $0.updatedAt > $1.updatedAt }
    }

    @discardableResult
    public func save(_ entry: SpikeEntry) throws -> SpikeEntry {
        var entries = try readEntries() // Refuses to overwrite a store it can't read.
        var stored = entry
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            guard entries[index].revision == entry.revision else {
                throw RepositoryError.staleRevision(expected: entries[index].revision, found: entry.revision)
            }
            stored.revision = entry.revision + 1
            stored.createdAt = entries[index].createdAt
            entries[index] = stored
        } else {
            stored.revision = 0
            entries.append(stored)
        }
        try write(entries)
        return stored
    }

    public func delete(id: UUID) throws {
        var entries = try readEntries()
        guard let index = entries.firstIndex(where: { $0.id == id }) else { throw RepositoryError.notFound }
        entries.remove(at: index)
        try write(entries)
    }

    private func readEntries() throws -> [SpikeEntry] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data: Data
        do { data = try Data(contentsOf: fileURL) } catch {
            throw RepositoryError.unreadable("read: \(error.localizedDescription)")
        }
        guard let probe = try? decoder.decode(VersionProbe.self, from: data) else {
            throw RepositoryError.unreadable("not a journal document")
        }
        switch probe.schemaVersion {
        case 1:
            guard let old = try? decoder.decode(EnvelopeV1.self, from: data) else {
                throw RepositoryError.unreadable("schema 1 decode failed")
            }
            // Migration in memory; the upgraded document is written on the next successful save.
            return old.entries.map { SpikeEntry(id: $0.id, revision: 0, originalWords: $0.words,
                                                createdAt: $0.createdAt, updatedAt: $0.createdAt) }
        case Self.currentSchema:
            guard let current = try? decoder.decode(EnvelopeV2.self, from: data) else {
                throw RepositoryError.unreadable("schema 2 decode failed")
            }
            return current.entries
        default:
            throw RepositoryError.unsupportedSchema(probe.schemaVersion)
        }
    }

    private func write(_ entries: [SpikeEntry]) throws {
        do {
            let data = try encoder.encode(EnvelopeV2(schemaVersion: Self.currentSchema, entries: entries))
            #if os(iOS)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
            #else
            try data.write(to: fileURL, options: [.atomic])
            #endif
        } catch {
            throw RepositoryError.writeFailed(error.localizedDescription)
        }
    }
}
