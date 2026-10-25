import Foundation
import os
import XCTest
@testable import Circleu

final class GuestJournalStoreTests: XCTestCase {
    private var directory: URL!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("GuestJournalTests-\(UUID())").appendingPathComponent("Journal")
    }

    override func tearDownWithError() throws {
        let root = directory.deletingLastPathComponent()
        try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: root.path)
        try? FileManager.default.removeItem(at: root)
    }

    private func open() async throws -> SwiftDataGuestJournalStore {
        try await SwiftDataGuestJournalStore.open(directory: directory, protection: .init { _ in })
    }

    private func assertThrows<T>(_ expected: GuestJournalError, _ body: () async throws -> T,
                                 file: StaticString = #filePath, line: UInt = #line) async {
        do {
            _ = try await body()
            XCTFail("expected \(expected)", file: file, line: line)
        } catch {
            XCTAssertEqual(error as? GuestJournalError, expected, file: file, line: line)
        }
    }

    // MARK: Save, reopen, edit

    func testFirstLaunchIsEmpty() async throws {
        let entries = try await open().loadAll()
        XCTAssertEqual(entries, [])
    }

    func testCreateReopenAndEditKeepsIDAndBumpsRevision() async throws {
        var store: SwiftDataGuestJournalStore? = try await open()
        let created = try await store!.create(originalWords: "I held back in class.")
        XCTAssertEqual(created.revision, 0)
        store = nil

        let reopened = try await open() // Simulated relaunch: a fresh container on the same store.
        let edited = try await reopened.update(id: created.id, originalWords: "I asked after class.", expectedRevision: 0)
        XCTAssertEqual(edited.id, created.id)
        XCTAssertEqual(edited.revision, 1)
        let entries = try await reopened.loadAll()
        XCTAssertEqual(entries.map(\.originalWords), ["I asked after class."])
        await assertThrows(.staleRevision(current: 1, expected: 0)) {
            try await reopened.update(id: created.id, originalWords: "older edit", expectedRevision: 0)
        }
    }

    // MARK: Rule 2 — an edit can't bring back a deleted entry

    func testUpdateAfterDeleteDoesNotResurrectEntry() async throws {
        let store = try await open()
        let created = try await store.create(originalWords: "to delete")
        try await store.delete(id: created.id)
        await assertThrows(.notFound) {
            try await store.update(id: created.id, originalWords: "edited in another screen", expectedRevision: 0)
        }
        let entries = try await store.loadAll()
        XCTAssertEqual(entries, [])
        await assertThrows(.notFound) { try await store.delete(id: created.id) }
    }

    // MARK: Rule 3 — saves are serialized

    func testCompetingEditsCannotBothWin() async throws {
        let store = try await open()
        let created = try await store.create(originalWords: "original")
        async let first = Result { try await store.update(id: created.id, originalWords: "first", expectedRevision: 0) }
        async let second = Result { try await store.update(id: created.id, originalWords: "second", expectedRevision: 0) }
        let results = await [first, second]
        XCTAssertEqual(results.filter { (try? $0.get()) != nil }.count, 1, "exactly one edit wins")
        XCTAssertEqual(results.compactMap { result -> GuestJournalError? in
            if case .failure(let error) = result { return error as? GuestJournalError } else { return nil }
        }, [.staleRevision(current: 1, expected: 0)])
        let entries = try await store.loadAll()
        XCTAssertEqual(entries.map(\.revision), [1])
    }

    func testConcurrentCreatesKeepEveryEntry() async throws {
        let store = try await open()
        try await withThrowingTaskGroup(of: Void.self) { group in
            for index in 0..<20 {
                group.addTask { _ = try await store.create(originalWords: "entry \(index)") }
            }
            try await group.waitForAll()
        }
        let entries = try await store.loadAll()
        XCTAssertEqual(Set(entries.map(\.originalWords)).count, 20)
    }

    // MARK: Rule 1 — a storage problem is never an empty journal

    func testCorruptStoreIsAnErrorAndBytesArePreserved() async throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let storeURL = directory.appendingPathComponent("GuestJournal.store")
        let garbage = Data(repeating: 0x42, count: 4096)
        try garbage.write(to: storeURL)
        do {
            _ = try await open()
            XCTFail("a corrupt store must not open as an empty journal")
        } catch {
            guard case .storeUnavailable = error as? GuestJournalError else { return XCTFail("\(error)") }
        }
        XCTAssertEqual(try Data(contentsOf: storeURL), garbage)
    }

    func testVanishedStoreIsAnErrorNotAFreshStart() async throws {
        var store: SwiftDataGuestJournalStore? = try await open()
        _ = try await store!.create(originalWords: "saved")
        store = nil
        for suffix in ["", "-wal", "-shm"] {
            try? FileManager.default.removeItem(at: directory.appendingPathComponent("GuestJournal.store" + suffix))
        }
        await assertThrows(.storeMissing) { try await self.open() }
    }

    func testUnreachableFolderIsAnError() async throws {
        let root = directory.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        try FileManager.default.setAttributes([.posixPermissions: 0o000], ofItemAtPath: root.path)
        do {
            _ = try await open()
            XCTFail("an unreachable folder must not open as an empty journal")
        } catch {
            guard case .storeUnavailable = error as? GuestJournalError else { return XCTFail("\(error)") }
        }
    }

    // MARK: Data Protection

    func testProtectionIsAppliedToFolderStoreAndSidecars() async throws {
        let protected = OSAllocatedUnfairLock(initialState: Set<String>())
        let store = try await SwiftDataGuestJournalStore.open(directory: directory, protection: .init { url in
            protected.withLock { _ = $0.insert(url.lastPathComponent) }
        })
        _ = try await store.create(originalWords: "protected")
        let names = protected.withLock { $0 }
        XCTAssertTrue(names.isSuperset(of: ["Journal", "GuestJournal.store"]), "\(names)")
        let onDisk = try FileManager.default.contentsOfDirectory(atPath: directory.path)
        for sidecar in ["GuestJournal.store-wal", "GuestJournal.store-shm"] where onDisk.contains(sidecar) {
            XCTAssertTrue(names.contains(sidecar), "\(sidecar) not protected")
        }
    }

    /// Runs only on a physical iPhone; the Simulator doesn't enforce Data Protection.
    func testRealDataProtectionOnDevice() async throws {
        #if targetEnvironment(simulator)
        throw XCTSkip("Data Protection is only enforced on a physical device")
        #else
        let store = try await SwiftDataGuestJournalStore.open(directory: directory)
        _ = try await store.create(originalWords: "protected on device")
        for name in try FileManager.default.contentsOfDirectory(atPath: directory.path) where name.hasPrefix("GuestJournal.store") {
            let attributes = try FileManager.default.attributesOfItem(atPath: directory.appendingPathComponent(name).path)
            XCTAssertEqual(attributes[.protectionKey] as? FileProtectionType, .completeUnlessOpen, name)
        }
        #endif
    }

    func testOpenFailsIfProtectionCannotBeApplied() async throws {
        struct Denied: Error {}
        do {
            _ = try await SwiftDataGuestJournalStore.open(directory: directory, protection: .init { _ in throw Denied() })
            XCTFail("unprotected store must not be used")
        } catch {
            guard case .storeUnavailable = error as? GuestJournalError else { return XCTFail("\(error)") }
        }
    }
}

// MARK: - View model with injected failures

private actor StubJournalStore: GuestJournalStore {
    var entries: [GuestJournalEntry] = []
    var failLoad = false
    var failSave = false

    func configure(failLoad: Bool = false, failSave: Bool = false) {
        self.failLoad = failLoad
        self.failSave = failSave
    }

    func loadAll() throws -> [GuestJournalEntry] {
        if failLoad { throw GuestJournalError.storeUnavailable("injected") }
        return entries
    }

    func create(originalWords: String) throws -> GuestJournalEntry {
        if failSave { throw GuestJournalError.saveFailed("injected") }
        let entry = GuestJournalEntry(id: UUID(), originalWords: originalWords, revision: 0, createdAt: Date(), updatedAt: Date())
        entries.insert(entry, at: 0)
        return entry
    }

    func update(id: UUID, originalWords: String, expectedRevision: Int) throws -> GuestJournalEntry {
        throw GuestJournalError.notFound
    }

    func delete(id: UUID) throws { throw GuestJournalError.notFound }
}

@MainActor
final class GuestJournalViewModelTests: XCTestCase {
    func testFailedSaveKeepsDraftAndShowsError() async {
        let store = StubJournalStore()
        await store.configure(failSave: true)
        let viewModel = GuestJournalViewModel(store: store)
        viewModel.draft = "Words I don't want to lose"
        await viewModel.saveDraft()
        XCTAssertEqual(viewModel.draft, "Words I don't want to lose")
        XCTAssertEqual(viewModel.saveError, GuestJournalViewModel.saveFailedMessage)
    }

    func testFailedLoadIsAnErrorNotAnEmptyJournal() async {
        let store = StubJournalStore()
        await store.configure(failLoad: true)
        let viewModel = GuestJournalViewModel(store: store)
        await viewModel.load()
        XCTAssertEqual(viewModel.loadState, .failed(GuestJournalViewModel.loadFailedMessage))
    }

    func testSuccessfulSaveClearsDraftAndShowsEntry() async {
        let viewModel = GuestJournalViewModel(store: StubJournalStore())
        viewModel.draft = "  A moment worth keeping  "
        await viewModel.saveDraft()
        XCTAssertEqual(viewModel.draft, "")
        XCTAssertNil(viewModel.saveError)
        guard case .loaded(let entries) = viewModel.loadState else { return XCTFail("\(viewModel.loadState)") }
        XCTAssertEqual(entries.map(\.originalWords), ["A moment worth keeping"])
    }
}
