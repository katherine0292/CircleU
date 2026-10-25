import Foundation
import os
import XCTest
@testable import Circleu

/// A thread-safe switch the fault hooks read, so a test can fail the next fetch or save.
private final class FaultSwitch: Sendable {
    private let state = OSAllocatedUnfairLock(initialState: (failFetch: false, failSave: false))
    func set(fetch: Bool = false, save: Bool = false) { state.withLock { $0 = (fetch, save) } }
    var faults: GuestJournalFaults {
        GuestJournalFaults(
            beforeFetch: { [state] in if state.withLock({ $0.failFetch }) { throw CocoaError(.fileReadUnknown) } },
            beforeSave: { [state] in if state.withLock({ $0.failSave }) { throw CocoaError(.fileWriteOutOfSpace) } })
    }
}

private struct InjectedProtectionFailure: Error {}

final class GuestJournalStoreTests: XCTestCase {
    private var root: URL!
    private var location: GuestJournalLocation!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("GuestJournalTests-\(UUID())")
        location = GuestJournalLocation(directory: root.appendingPathComponent("Journal"),
                                        setupMarker: root.appendingPathComponent("Setup/initialized"))
    }

    override func tearDownWithError() throws {
        try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: root.path)
        try? FileManager.default.removeItem(at: root)
    }

    private func open(faults: GuestJournalFaults = .none) async throws -> SwiftDataGuestJournalStore {
        try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in }, faults: faults)
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

    private func assertUnavailable<T>(_ body: () async throws -> T, file: StaticString = #filePath, line: UInt = #line) async {
        do {
            _ = try await body()
            XCTFail("expected storeUnavailable", file: file, line: line)
        } catch {
            guard case .storeUnavailable = error as? GuestJournalError else {
                return XCTFail("expected storeUnavailable, got \(error)", file: file, line: line)
            }
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

        var reopened: SwiftDataGuestJournalStore? = try await open() // Simulated relaunch.
        let edited = try await reopened!.update(id: created.id, originalWords: "I asked after class.", expectedRevision: 0)
        XCTAssertEqual(edited.id, created.id)
        XCTAssertEqual(edited.revision, 1)
        await assertThrows(.staleRevision(current: 1, expected: 0)) {
            try await reopened!.update(id: created.id, originalWords: "older edit", expectedRevision: 0)
        }
        reopened = nil

        let entries = try await open().loadAll() // Reopen again after the edit.
        XCTAssertEqual(entries.map(\.originalWords), ["I asked after class."])
        XCTAssertEqual(entries.map(\.revision), [1])
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

    // MARK: Rule 3 — one serialized writer per store

    func testSimultaneousOpensShareOneOwner() async throws {
        async let first = open()
        async let second = open()
        let stores = try await [first, second]
        XCTAssertTrue(stores[0] === stores[1], "two opens of one location must share one writer")
    }

    func testCompetingEditsThroughSeparateOpensCannotBothWin() async throws {
        let created = try await open().create(originalWords: "original")
        let storeA = try await open()
        let storeB = try await open()
        async let first = Result { try await storeA.update(id: created.id, originalWords: "first", expectedRevision: 0) }
        async let second = Result { try await storeB.update(id: created.id, originalWords: "second", expectedRevision: 0) }
        let results = await [first, second]
        XCTAssertEqual(results.filter { (try? $0.get()) != nil }.count, 1, "exactly one edit wins")
        let entries = try await storeA.loadAll()
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
        try FileManager.default.createDirectory(at: location.directory, withIntermediateDirectories: true)
        let garbage = Data(repeating: 0x42, count: 4096)
        try garbage.write(to: location.storeURL)
        await assertUnavailable { try await self.open() }
        XCTAssertEqual(try Data(contentsOf: location.storeURL), garbage)
    }

    func testVanishedStoreFileIsAnError() async throws {
        var store: SwiftDataGuestJournalStore? = try await open()
        _ = try await store!.create(originalWords: "saved")
        store = nil
        for file in location.storeFiles { try? FileManager.default.removeItem(at: file) }
        await assertThrows(.storeMissing) { try await self.open() }
    }

    func testLosingTheWholeJournalFolderIsAnError() async throws {
        var store: SwiftDataGuestJournalStore? = try await open()
        _ = try await store!.create(originalWords: "saved")
        store = nil
        try FileManager.default.removeItem(at: location.directory)
        await assertThrows(.storeMissing) { try await self.open() }
        XCTAssertFalse(FileManager.default.fileExists(atPath: location.storeURL.path), "must not recreate a fresh store")
    }

    func testUnreachableFolderIsAnError() async throws {
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        try FileManager.default.setAttributes([.posixPermissions: 0o000], ofItemAtPath: root.path)
        await assertUnavailable { try await self.open() }
    }

    func testFetchFailureIsUnavailableNotNotFound() async throws {
        let faults = FaultSwitch()
        let store = try await open(faults: faults.faults)
        let created = try await store.create(originalWords: "kept")
        faults.set(fetch: true)
        await assertUnavailable { try await store.loadAll() }
        await assertUnavailable { try await store.update(id: created.id, originalWords: "x", expectedRevision: 0) }
        await assertUnavailable { try await store.delete(id: created.id) }
    }

    // MARK: Failed saves in the real store roll back

    func testFailedCreateRollsBackAndRetryDoesNotDuplicate() async throws {
        let faults = FaultSwitch()
        var store: SwiftDataGuestJournalStore? = try await open(faults: faults.faults)
        faults.set(save: true)
        do {
            _ = try await store!.create(originalWords: "first try")
            XCTFail("expected saveFailed")
        } catch {
            guard case .saveFailed = error as? GuestJournalError else { return XCTFail("\(error)") }
        }
        faults.set()
        let afterFailure = try await store!.loadAll()
        XCTAssertEqual(afterFailure, [], "nothing half-saved")
        _ = try await store!.create(originalWords: "first try")
        store = nil
        let entries = try await open().loadAll()
        XCTAssertEqual(entries.map(\.originalWords), ["first try"], "retry saved exactly once")
    }

    func testFailedUpdateKeepsCommittedContent() async throws {
        let faults = FaultSwitch()
        var store: SwiftDataGuestJournalStore? = try await open(faults: faults.faults)
        let created = try await store!.create(originalWords: "committed")
        faults.set(save: true)
        do {
            _ = try await store!.update(id: created.id, originalWords: "not saved", expectedRevision: 0)
            XCTFail("expected saveFailed")
        } catch {
            guard case .saveFailed = error as? GuestJournalError else { return XCTFail("\(error)") }
        }
        faults.set()
        let inMemory = try await store!.loadAll()
        XCTAssertEqual(inMemory.map(\.originalWords), ["committed"])
        XCTAssertEqual(inMemory.map(\.revision), [0])
        store = nil
        let reopened = try await open().loadAll()
        XCTAssertEqual(reopened.map(\.originalWords), ["committed"])
    }

    func testFailedDeleteKeepsEntry() async throws {
        let faults = FaultSwitch()
        var store: SwiftDataGuestJournalStore? = try await open(faults: faults.faults)
        let created = try await store!.create(originalWords: "still here")
        faults.set(save: true)
        do {
            try await store!.delete(id: created.id)
            XCTFail("expected saveFailed")
        } catch {
            guard case .saveFailed = error as? GuestJournalError else { return XCTFail("\(error)") }
        }
        faults.set()
        let inMemory = try await store!.loadAll()
        XCTAssertEqual(inMemory.map(\.id), [created.id])
        store = nil
        let reopened = try await open().loadAll()
        XCTAssertEqual(reopened.map(\.id), [created.id])
    }

    // MARK: Data Protection

    func testProtectionIsAppliedToFolderStoreAndSidecars() async throws {
        let protected = OSAllocatedUnfairLock(initialState: Set<String>())
        let store = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { url in
            protected.withLock { _ = $0.insert(url.lastPathComponent) }
        })
        _ = try await store.create(originalWords: "protected")
        let names = protected.withLock { $0 }
        XCTAssertTrue(names.isSuperset(of: ["Journal", "GuestJournal.store"]), "\(names)")
        let onDisk = try FileManager.default.contentsOfDirectory(atPath: location.directory.path)
        for sidecar in ["GuestJournal.store-wal", "GuestJournal.store-shm"] where onDisk.contains(sidecar) {
            XCTAssertTrue(names.contains(sidecar), "\(sidecar) not protected")
        }
    }

    func testOpenFailsIfProtectionCannotBeApplied() async throws {
        do {
            _ = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in throw InjectedProtectionFailure() })
            XCTFail("unprotected store must not be used")
        } catch {
            guard case .protectionFailed = error as? GuestJournalError else { return XCTFail("\(error)") }
        }
    }

    func testProtectionFailureAfterSaveIsReportedButEntryIsSaved() async throws {
        let failAfterOpen = OSAllocatedUnfairLock(initialState: false)
        let store = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in
            if failAfterOpen.withLock({ $0 }) { throw InjectedProtectionFailure() }
        })
        failAfterOpen.withLock { $0 = true }
        do {
            _ = try await store.create(originalWords: "saved anyway")
            XCTFail("expected savedButUnprotected")
        } catch {
            guard case .savedButUnprotected = error as? GuestJournalError else { return XCTFail("\(error)") }
        }
        let entries = try await store.loadAll()
        XCTAssertEqual(entries.map(\.originalWords), ["saved anyway"], "saved once; no retry needed")
    }

    /// Runs only on a physical iPhone; the Simulator doesn't enforce Data Protection.
    func testRealDataProtectionOnDevice() async throws {
        #if targetEnvironment(simulator)
        throw XCTSkip("Data Protection is only enforced on a physical device")
        #else
        let store = try await SwiftDataGuestJournalStore.open(location: location)
        _ = try await store.create(originalWords: "protected on device")
        for url in [location.directory] + location.storeFiles where FileManager.default.fileExists(atPath: url.path) {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            XCTAssertEqual(attributes[.protectionKey] as? FileProtectionType, .completeUnlessOpen, url.lastPathComponent)
        }
        #endif
    }
}

// MARK: - View model with injected stores

private actor StubJournalStore: GuestJournalStore {
    var entries: [GuestJournalEntry] = []
    var failLoad = false
    var createError: GuestJournalError?

    func configure(failLoad: Bool = false, createError: GuestJournalError? = nil) {
        self.failLoad = failLoad
        self.createError = createError
    }

    func loadAll() throws -> [GuestJournalEntry] {
        if failLoad { throw GuestJournalError.storeUnavailable("injected") }
        return entries
    }

    func create(originalWords: String) throws -> GuestJournalEntry {
        let entry = GuestJournalEntry(id: UUID(), originalWords: originalWords, revision: 0, createdAt: Date(), updatedAt: Date())
        if let createError {
            if case .savedButUnprotected = createError { entries.insert(entry, at: 0) }
            throw createError
        }
        entries.insert(entry, at: 0)
        return entry
    }

    func update(id: UUID, originalWords: String, expectedRevision: Int) throws -> GuestJournalEntry {
        throw GuestJournalError.notFound
    }

    func delete(id: UUID) throws { throw GuestJournalError.notFound }
}

/// Holds `create` until the test releases it, to edit the draft mid-save.
private actor SuspendedSaveStore: GuestJournalStore {
    private var pending: CheckedContinuation<Void, Never>?
    var isWaiting: Bool { pending != nil }

    func release() { pending?.resume(); pending = nil }

    func loadAll() throws -> [GuestJournalEntry] { [] }

    func create(originalWords: String) async throws -> GuestJournalEntry {
        await withCheckedContinuation { pending = $0 }
        return GuestJournalEntry(id: UUID(), originalWords: originalWords, revision: 0, createdAt: Date(), updatedAt: Date())
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
        await store.configure(createError: .saveFailed("injected"))
        let viewModel = GuestJournalViewModel(store: store)
        viewModel.draft = "Words I don't want to lose"
        await viewModel.saveDraft()
        XCTAssertEqual(viewModel.draft, "Words I don't want to lose")
        XCTAssertEqual(viewModel.saveError, GuestJournalViewModel.saveFailedMessage)
    }

    func testSavedButUnprotectedClearsDraftSoItIsNotSavedTwice() async {
        let store = StubJournalStore()
        await store.configure(createError: .savedButUnprotected(entryID: UUID()))
        let viewModel = GuestJournalViewModel(store: store)
        viewModel.draft = "Saved once"
        await viewModel.saveDraft()
        XCTAssertEqual(viewModel.draft, "")
        XCTAssertEqual(viewModel.saveError, GuestJournalViewModel.savedButUnprotectedMessage)
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

    func testTextTypedDuringSaveIsKept() async {
        let store = SuspendedSaveStore()
        let viewModel = GuestJournalViewModel(store: store)
        viewModel.draft = "A"
        let saving = Task { await viewModel.saveDraft() }
        while await !store.isWaiting { await Task.yield() }
        viewModel.draft = "A, and then B"
        await store.release()
        await saving.value
        XCTAssertEqual(viewModel.draft, "A, and then B", "newer text must survive the earlier save")
    }
}
