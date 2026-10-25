import Foundation
import SwiftData
import XCTest
@testable import StorageSpike

/// Spike evidence, not app tests. "SPIKE:" lines record observed behaviour for the results doc.
final class StorageSpikeTests: XCTestCase {
    private var directory: URL!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent("spike-\(UUID())")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: directory.path)
        try? FileManager.default.removeItem(at: directory)
    }

    private func note(_ text: String) { print("SPIKE: \(text)") }

    // MARK: Shared behaviour (both options)

    private func assertRoundTrip(_ make: () throws -> EntryRepository, file: StaticString = #filePath, line: UInt = #line) throws {
        var repo = try make()
        XCTAssertEqual(try repo.loadAll(), [], "first launch is empty", file: file, line: line)
        let saved = try repo.save(SpikeEntry(originalWords: "I held back in class."))
        XCTAssertEqual(saved.revision, 0, file: file, line: line)

        repo = try make() // Simulated relaunch: a fresh instance on the same files.
        var edited = try XCTUnwrap(repo.loadAll().first, file: file, line: line)
        edited.originalWords = "I held back in class, then asked after."
        edited.updatedAt = Date()
        let afterEdit = try repo.save(edited)
        XCTAssertEqual(afterEdit.revision, 1, "edit bumps revision", file: file, line: line)
        XCTAssertEqual(afterEdit.id, saved.id, "edit keeps the stable ID", file: file, line: line)

        XCTAssertThrowsError(try repo.save(edited), "stale revision is rejected", file: file, line: line) { error in
            XCTAssertEqual(error as? RepositoryError, .staleRevision(expected: 1, found: 0), file: file, line: line)
        }

        repo = try make()
        XCTAssertEqual(try repo.loadAll().map(\.originalWords), ["I held back in class, then asked after."], file: file, line: line)
        try repo.delete(id: saved.id)
        XCTAssertEqual(try make().loadAll(), [], file: file, line: line)
        XCTAssertThrowsError(try repo.delete(id: saved.id), file: file, line: line)
    }

    func testFileRoundTripRelaunchEditDelete() throws {
        try assertRoundTrip { FileEntryRepository(directory: directory) }
    }

    func testSwiftDataRoundTripRelaunchEditDelete() throws {
        try assertRoundTrip { try SwiftDataEntryRepository(directory: directory) }
    }

    // MARK: File option specifics

    func testFileCorruptStoreIsReportedAndNeverOverwritten() throws {
        let repo = FileEntryRepository(directory: directory)
        let garbage = Data("{not json".utf8)
        try garbage.write(to: repo.fileURL)
        XCTAssertThrowsError(try repo.loadAll()) { XCTAssertEqual(($0 as? RepositoryError).map { "\($0)" }?.hasPrefix("unreadable"), true) }
        XCTAssertThrowsError(try repo.save(SpikeEntry(originalWords: "new")))
        XCTAssertEqual(try Data(contentsOf: repo.fileURL), garbage, "corrupt bytes preserved for recovery")
        note("file: corrupt store -> unreadable error on load and save; original bytes untouched")
    }

    func testFileInterruptedWriteLeavesPreviousVersion() throws {
        let repo = FileEntryRepository(directory: directory)
        try repo.save(SpikeEntry(originalWords: "kept"))
        // An interrupted atomic write leaves at most a stray temp file; the rename never happened.
        try Data("{\"schemaVersion\":2,\"entries\":[".utf8)
            .write(to: directory.appendingPathComponent(".dat.nosync.journal.json.tmp"))
        XCTAssertEqual(try FileEntryRepository(directory: directory).loadAll().map(\.originalWords), ["kept"])
        note("file: simulated interrupted write (partial temp, no rename) -> previous version loads")
    }

    func testFileWriteFailureKeepsPreviousVersionAndReportsError() throws {
        let repo = FileEntryRepository(directory: directory)
        try repo.save(SpikeEntry(originalWords: "kept"))
        try FileManager.default.setAttributes([.posixPermissions: 0o555], ofItemAtPath: directory.path)
        XCTAssertThrowsError(try repo.save(SpikeEntry(originalWords: "lost?"))) {
            XCTAssertEqual(($0 as? RepositoryError).map { "\($0)" }?.hasPrefix("writeFailed"), true)
        }
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: directory.path)
        XCTAssertEqual(try repo.loadAll().map(\.originalWords), ["kept"])
        note("file: write failure (read-only folder) -> writeFailed; previous version intact")
    }

    func testFileMigratesSchema1AndRejectsUnknownSchema() throws {
        let repo = FileEntryRepository(directory: directory)
        let id = UUID()
        try Data("""
        {"schemaVersion":1,"entries":[{"id":"\(id.uuidString)","words":"old words","createdAt":"2026-10-01T09:00:00Z"}]}
        """.utf8).write(to: repo.fileURL)
        let migrated = try repo.loadAll()
        XCTAssertEqual(migrated.map(\.originalWords), ["old words"])
        XCTAssertEqual(migrated.first?.id, id)
        try repo.save(SpikeEntry(originalWords: "new"))
        XCTAssertTrue(try String(contentsOf: repo.fileURL, encoding: .utf8).contains("\"schemaVersion\":2"))

        try Data("{\"schemaVersion\":9,\"entries\":[]}".utf8).write(to: repo.fileURL)
        XCTAssertThrowsError(try repo.loadAll()) { XCTAssertEqual($0 as? RepositoryError, .unsupportedSchema(9)) }
        note("file: schema 1 -> 2 migrated with stable IDs; unknown future schema refused (not emptied)")
    }

    func testFileProtectionClass() throws {
        let repo = FileEntryRepository(directory: directory)
        try repo.save(SpikeEntry(originalWords: "protected"))
        let protection = try FileManager.default.attributesOfItem(atPath: repo.fileURL.path)[.protectionKey]
        note("file: protection attribute = \(String(describing: protection))")
        #if os(iOS) && !targetEnvironment(simulator)
        XCTAssertEqual(protection as? FileProtectionType, .complete)
        #else
        note("file: Simulator/macOS don't report Data Protection; verify on a physical device")
        #endif
    }

    // MARK: SwiftData option specifics

    func testSwiftDataLightweightMigrationFromSchema1() throws {
        let id = UUID()
        let url = directory.appendingPathComponent("journal.store")
        do {
            let v1 = try ModelContainer(for: Schema(versionedSchema: SpikeSchemaV1.self),
                                        configurations: ModelConfiguration(url: url))
            let context = ModelContext(v1)
            context.insert(SpikeSchemaV1.Entry(id: id, words: "old words", createdAt: Date()))
            try context.save()
        }
        let repo = try SwiftDataEntryRepository(directory: directory)
        let migrated = try repo.loadAll()
        XCTAssertEqual(migrated.map(\.originalWords), ["old words"])
        XCTAssertEqual(migrated.first?.id, id)
        note("swiftdata: V1 -> V2 lightweight migration (renamed field, new defaults) kept data and IDs")
    }

    func testSwiftDataCorruptStoreBehaviour() throws {
        let url = directory.appendingPathComponent("journal.store")
        let garbage = Data(repeating: 0x42, count: 4096)
        try garbage.write(to: url)
        var outcome: String
        do {
            let repo = try SwiftDataEntryRepository(directory: directory)
            let rows = try repo.loadAll()
            outcome = "opened without error, \(rows.count) rows"
        } catch {
            outcome = "error surfaced: \(error)"
        }
        let bytesPreserved = (try? Data(contentsOf: url)) == garbage
        note("swiftdata: corrupt store -> \(outcome.prefix(160)); original bytes preserved = \(bytesPreserved)")
    }

    func testSwiftDataWriteFailureBehaviour() throws {
        let repo = try SwiftDataEntryRepository(directory: directory)
        try repo.save(SpikeEntry(originalWords: "kept"))
        // SQLite writes into existing files, so make the store files (not the folder) read-only.
        let files = (try? FileManager.default.contentsOfDirectory(atPath: directory.path)) ?? []
        for name in files { try FileManager.default.setAttributes([.posixPermissions: 0o444], ofItemAtPath: directory.appendingPathComponent(name).path) }
        var outcome = "save succeeded"
        do { try repo.save(SpikeEntry(originalWords: "second")) } catch { outcome = "error: \(error)".prefix(160).description }
        for name in files { try FileManager.default.setAttributes([.posixPermissions: 0o644], ofItemAtPath: directory.appendingPathComponent(name).path) }
        let words = (try? SwiftDataEntryRepository(directory: directory).loadAll().map(\.originalWords)) ?? []
        note("swiftdata: write after making store files read-only -> \(outcome); after relaunch = \(words) (open SQLite handles ignore later permission changes, so this does not provoke a failure)")
    }

    func testSwiftDataProtectionClassIncludingSidecars() throws {
        let repo = try SwiftDataEntryRepository(directory: directory)
        try repo.save(SpikeEntry(originalWords: "protected"))
        let files = (try? FileManager.default.contentsOfDirectory(atPath: directory.path)) ?? []
        for name in files.sorted() {
            let protection = try? FileManager.default.attributesOfItem(atPath: directory.appendingPathComponent(name).path)[.protectionKey]
            note("swiftdata: \(name) protection = \(String(describing: protection))")
        }
    }
}
