import Foundation
import XCTest
@testable import Circleu

@MainActor
final class GuestImportTests: XCTestCase {
    private var root: URL!
    private var location: GuestJournalLocation!
    private var suite: String!
    private var defaults: UserDefaults!

    override func setUp() {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("GuestImport-\(UUID())")
        location = GuestJournalLocation(directory: root.appendingPathComponent("Journal"),
                                        setupMarker: root.appendingPathComponent("Setup/initialized"))
        suite = "GuestImportTests-\(UUID())"
        defaults = UserDefaults(suiteName: suite)
        GuestLegacyFixture.write(to: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suite)
        try? FileManager.default.removeItem(at: root)
    }

    private func oldBytes() -> [String: Data] {
        defaults.dictionaryRepresentation().compactMapValues { $0 as? Data }
            .filter { $0.key.hasPrefix("circleu.") }
    }

    func testScanFindsEveryBucketMergesDuplicatesAndExplainsSkips() {
        let scan = GuestLegacyImport.scan(defaults)
        XCTAssertEqual(scan.entries.count, 3, "device and account buckets, the shared entry once")
        XCTAssertEqual(scan.messages.count, 1)
        XCTAssertEqual(scan.skipped.map(\.reason).sorted { "\($0)" < "\($1)" }, [.noWords, .unreadable])

        let interrupted = try? XCTUnwrap(scan.entries.first { $0.originalWords.hasPrefix("My manager") })
        XCTAssertEqual(interrupted?.originalWords, "My manager cut me off in the meeting again.\n\nMy note: Talk to her on Friday.")
        XCTAssertEqual(interrupted?.reflection?.source, .imported)
        XCTAssertEqual(interrupted?.reflection?.feeling, "Frustrated")
        XCTAssertEqual(interrupted?.createdAt, Date(timeIntervalSince1970: 1_790_000_000), "original date kept")
        let shift = scan.entries.first { $0.originalWords.contains("extra shift") }
        XCTAssertEqual(shift?.reflection?.feeling, "Proud", "the person's own edit of the feeling wins")
        XCTAssertEqual(scan.messages.first?.situation, "Group project")
        XCTAssertEqual(scan.messages.first?.wording, "Could we split the group slides more evenly?")
    }

    func testImportCopiesOnceKeepsTheEarlierAppUntouchedAndNeverDuplicates() async throws {
        let before = oldBytes()
        let (journal, practice) = try await GuestComposition.local(at: location).makeSession()
        let store = try XCTUnwrap(practice.store as? any GuestImportStore)
        let model = GuestImportViewModel(defaults: defaults, store: store, journal: journal, practice: practice)
        await model.scan()
        guard case .preview(let scan, let already) = model.state else { return XCTFail("\(model.state)") }
        XCTAssertEqual(scan.entries.count, 3)
        XCTAssertEqual(already, 0)
        await model.importAll()
        XCTAssertEqual(model.state, .done(added: 4, skipped: 2))
        XCTAssertEqual(journal.entries.count, 3)
        XCTAssertEqual(practice.messages.count, 1)
        XCTAssertEqual(practice.messages.first?.sourceEntryID, nil, "on its own")
        XCTAssertEqual(journal.entries.map(\.createdAt).min(), Date(timeIntervalSince1970: 1_790_000_000))
        XCTAssertEqual(oldBytes(), before, "the earlier app's data is only read")

        // Again: nothing new, nothing duplicated.
        await model.scan()
        guard case .preview(let again, let alreadyAgain) = model.state else { return XCTFail("\(model.state)") }
        XCTAssertTrue(again.entries.isEmpty && again.messages.isEmpty)
        XCTAssertEqual(alreadyAgain, 4)
        XCTAssertFalse(model.canImport)
        let added = try await store.importLegacy(entries: scan.entries, messages: scan.messages)
        XCTAssertEqual(added, 0, "a direct re-run adds nothing")
        await journal.load()
        XCTAssertEqual(journal.entries.count, 3)
    }

    func testFailedImportAddsNothing() async throws {
        let failing = ImportFailSwitch()
        let store = try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in },
                                                              faults: failing.faults)
        let journal = GuestJournalViewModel(store: store)
        let practice = GuestPracticeViewModel(store: store)
        let model = GuestImportViewModel(defaults: defaults, store: store, journal: journal, practice: practice)
        await model.scan()
        failing.on = true
        await model.importAll()
        failing.on = false
        XCTAssertEqual(model.state, .failed(GuestImportViewModel.failedMessage))
        await journal.load()
        XCTAssertEqual(journal.entries, [])
        await model.scan()
        guard case .preview(let scan, let already) = model.state else { return XCTFail("\(model.state)") }
        XCTAssertEqual(scan.entries.count, 3, "still offered")
        XCTAssertEqual(already, 0)
    }

    func testNothingFoundIsSaidPlainly() async throws {
        let empty = UserDefaults(suiteName: "GuestImportEmpty-\(UUID())")!
        let (journal, practice) = try await GuestComposition.local(at: location).makeSession()
        let model = GuestImportViewModel(defaults: empty, store: try XCTUnwrap(practice.store as? any GuestImportStore),
                                         journal: journal, practice: practice)
        await model.scan()
        guard case .preview(let scan, 0) = model.state else { return XCTFail("\(model.state)") }
        XCTAssertTrue(scan.isEmpty)
        XCTAssertFalse(model.canImport)
    }
}

private final class ImportFailSwitch: @unchecked Sendable {
    private let lock = NSLock()
    private var value = false
    var on: Bool {
        get { lock.withLock { value } }
        set { lock.withLock { value = newValue } }
    }
    var faults: GuestJournalFaults {
        GuestJournalFaults(beforeSave: { [self] in if on { throw CocoaError(.fileWriteOutOfSpace) } })
    }
}
