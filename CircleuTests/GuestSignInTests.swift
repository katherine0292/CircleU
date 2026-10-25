import Foundation
import XCTest
@testable import Circleu

/// Test account service: the test decides every outcome.
@MainActor
private final class ScriptedAccount: GuestAccountService {
    var isAvailable = true
    var logInResults: [Result<(uid: String, project: String), GuestAccountError>] = []
    var deleteError: GuestAccountError?
    var resetError: GuestAccountError?
    private(set) var signedIn = false
    private(set) var signOuts = 0
    private(set) var discards = 0
    private(set) var deletedAccount = false
    var holdLogIn = false
    private var held: CheckedContinuation<Void, Never>?

    var discardFails = false
    func discardEarlierSession() throws {
        if discardFails { throw GuestAccountError.failed }
        discards += 1; signedIn = false
    }

    func logIn(email: String, password: String) async throws -> (uid: String, project: String) {
        if holdLogIn { await withCheckedContinuation { held = $0 } }
        let result = logInResults.isEmpty ? .success(("uid-1", "dev")) : logInResults.removeFirst()
        switch result {
        case .success(let session): signedIn = true; return session
        case .failure(let error): throw error
        }
    }

    func release() { held?.resume(); held = nil }

    func sendPasswordReset(email: String) async throws { if let resetError { throw resetError } }

    private(set) var deletedUID: String?
    func deleteAccount(uid: String) async throws {
        if let deleteError { throw deleteError }
        deletedAccount = true
        deletedUID = uid
    }

    @discardableResult
    func signOut() -> Bool { signedIn = false; signOuts += 1; return true }
}

@MainActor
private final class ScriptedReader: GuestCloudBackupReading {
    var backup = GuestCloudBackup()
    var readError: GuestAccountError?
    var deleteError: GuestAccountError?
    private(set) var readUIDs: [String] = []
    private(set) var deletedUIDs: [String] = []

    func readBackup(uid: String, project: String) async throws -> GuestCloudBackup {
        readUIDs.append(uid)
        if let readError { throw readError }
        return backup
    }

    var keptCircles = 0
    func deleteOwnedContent(uid: String) async throws -> Int {
        if let deleteError { throw deleteError }
        deletedUIDs.append(uid)
        return keptCircles
    }
}

@MainActor
final class GuestSignInTests: XCTestCase {
    private var root: URL!

    override func setUp() {
        root = FileManager.default.temporaryDirectory.appendingPathComponent("GuestSignIn-\(UUID())")
        GuestAccountGate.resetForTesting()
    }

    override func tearDown() {
        GuestAccountGate.resetForTesting() // A test may end while previewing (still holding it).
        try? FileManager.default.removeItem(at: root)
    }

    private func session() async throws -> (GuestJournalViewModel, GuestPracticeViewModel, any GuestImportStore) {
        let location = GuestJournalLocation(directory: root.appendingPathComponent("Journal"),
                                            setupMarker: root.appendingPathComponent("Setup/initialized"))
        let (journal, practice) = try await GuestComposition.local(at: location).makeSession()
        return (journal, practice, try XCTUnwrap(practice.store as? any GuestImportStore))
    }

    private func backup(uid: String = "uid-1") -> GuestCloudBackup {
        let journal: [[String: Any]] = [
            ["entryID": "AAAAAAAA-0000-0000-0000-000000000001", "transcript": "I asked for space, kindly.",
             "createdAt": Date(timeIntervalSince1970: 1_780_000_000), "engineName": "Apple Intelligence",
             "durationSeconds": 20,
             "result": ["title": "Space", "emotion": "Calm", "summary": "You asked for space.", "insight": "",
                        "expressionMoment": "", "quote": "", "confidenceScore": 0.8, "suggestedQuest": ""]],
            ["entryID": "broken"],
        ]
        return GuestCloudBackupMapper.map(journal: journal, practice: [], uid: uid, project: "dev")
    }

    private func make(_ account: ScriptedAccount, _ reader: ScriptedReader,
                      now: @escaping () -> Date = Date.init) async throws -> (GuestSignInViewModel, GuestJournalViewModel) {
        let (journal, practice, store) = try await session()
        let model = GuestSignInViewModel(factory: GuestAccountFactory { (account, reader) }, store: store,
                                         journal: journal, practice: practice, now: now)
        model.email = "person@example.com"
        model.password = "secret"
        return (model, journal)
    }

    func testLogInPreviewsOnlyThatAccountsBackupCopiesOnceAndSignsOut() async throws {
        let account = ScriptedAccount(), reader = ScriptedReader()
        reader.backup = backup()
        let (model, journal) = try await make(account, reader)
        await model.logIn()
        XCTAssertEqual(account.discards, 1, "a leftover session is never trusted")
        XCTAssertEqual(reader.readUIDs, ["uid-1"])
        XCTAssertEqual(model.password, "", "the password isn't kept")
        guard case .preview(let preview, 0) = model.step else { return XCTFail("\(model.step)") }
        XCTAssertEqual(preview.entries.count, 1)
        XCTAssertEqual(preview.skipped.map(\.reason), [.unreadable], "a broken record is counted, not dropped silently")
        XCTAssertTrue(journal.entries.isEmpty, "nothing copied until chosen")

        await model.copy()
        guard case .done(1, _, true, true) = model.step else { return XCTFail("\(model.step)") }
        XCTAssertFalse(account.signedIn, "signed out automatically")
        XCTAssertEqual(journal.entries.first?.reflection?.source, .imported)

        // Again, on a new Log in screen: nothing duplicated.
        let again = GuestSignInViewModel(factory: GuestAccountFactory { (account, reader) },
                                         store: try XCTUnwrap(journal.store as? any GuestImportStore),
                                         journal: journal, practice: GuestPracticeViewModel(store: try XCTUnwrap(journal.store as? any GuestPracticeStore)))
        again.email = "person@example.com"; again.password = "secret"
        await again.logIn()
        guard case .preview(let second, 1) = again.step else { return XCTFail("\(again.step)") }
        XCTAssertTrue(second.entries.isEmpty)
        XCTAssertFalse(again.canCopy)
    }

    func testFailuresAreGenericSignedOutAndBackOff() async throws {
        let account = ScriptedAccount(), reader = ScriptedReader()
        account.logInResults = Array(repeating: .failure(.couldNotLogIn), count: 3)
        var clock = Date(timeIntervalSince1970: 0)
        let (model, _) = try await make(account, reader, now: { clock })
        for _ in 0..<3 {
            model.password = "wrong"
            await model.logIn()
        }
        XCTAssertEqual(model.message, "Check your email and password. Your entries are unchanged.")
        XCTAssertEqual(model.step, .form)
        XCTAssertNotNil(model.retryAfter, "backs off after repeated failures")
        model.password = "right"
        await model.logIn()
        XCTAssertEqual(model.message, GuestSignInViewModel.lockedMessage)
        XCTAssertTrue(reader.readUIDs.isEmpty)
        clock = clock.addingTimeInterval(31)
        await model.logIn()
        guard case .preview = model.step else { return XCTFail("\(model.step)") }
    }

    func testOfflineAndUnavailableAreSaidPlainly() async throws {
        let account = ScriptedAccount(), reader = ScriptedReader()
        reader.readError = .offline
        let (model, _) = try await make(account, reader)
        await model.logIn()
        XCTAssertEqual(model.message, GuestAccountMessages.text(for: GuestAccountError.offline))
        XCTAssertFalse(account.signedIn, "a failed read signs out")

        let unavailable = ScriptedAccount()
        unavailable.isAvailable = false
        let (other, _) = try await make(unavailable, ScriptedReader())
        await other.logIn()
        XCTAssertEqual(other.message, "Logging in isn’t available in this version.")
    }

    func testCancellingDuringLogInIgnoresTheLateResult() async throws {
        let account = ScriptedAccount(), reader = ScriptedReader()
        account.holdLogIn = true
        reader.backup = backup()
        let (model, _) = try await make(account, reader)
        let task = Task { await model.logIn() }
        for _ in 0..<20 { await Task.yield() }
        model.cancel()
        model.cancel() // A second cancel doesn't let go early either.
        XCTAssertTrue(GuestAccountGate.isBusy, "the gate is held until the pending log in settles")
        account.release()
        await task.value
        XCTAssertFalse(GuestAccountGate.isBusy)
        XCTAssertEqual(model.step, .form, "the late result is dropped")
        XCTAssertFalse(account.signedIn, "a late log in is undone")
        XCTAssertTrue(reader.readUIDs.isEmpty, "nothing is read for a cancelled log in")
    }

    func testOneAccountActionAtATime() async throws {
        let account = ScriptedAccount(), reader = ScriptedReader()
        reader.backup = backup()
        let (model, _) = try await make(account, reader)
        await model.logIn() // Holds the gate while previewing (signed in).
        let deleter = GuestDeleteAccountViewModel(factory: GuestAccountFactory { (account, reader) })
        deleter.email = "person@example.com"; deleter.password = "secret"
        await deleter.delete()
        XCTAssertEqual(deleter.message, GuestAccountGate.busyMessage)
        XCTAssertFalse(account.deletedAccount)
        model.cancel() // Signs out and lets go.
        deleter.password = "secret"
        await deleter.delete()
        XCTAssertEqual(deleter.step, .done(keptCircles: 0))
        XCTAssertEqual(account.deletedUID, "uid-1", "deletes only the account just logged in to")
    }

    func testIfAnEarlierSessionCantBeClearedNothingHappens() async throws {
        let account = ScriptedAccount(), reader = ScriptedReader()
        account.discardFails = true
        let (model, _) = try await make(account, reader)
        await model.logIn()
        XCTAssertEqual(model.step, .form)
        XCTAssertTrue(reader.readUIDs.isEmpty)
        XCTAssertNotNil(model.message)
    }

    func testTheSameItemTwiceKeepsItsLatestEdit() {
        let id = "AAAAAAAA-0000-0000-0000-000000000009"
        func doc(_ words: String, edited: TimeInterval) -> [String: Any] {
            ["entryID": id, "transcript": words, "createdAt": Date(timeIntervalSince1970: 1_780_000_000),
             "updatedAt": Date(timeIntervalSince1970: edited), "engineName": "x", "durationSeconds": 1,
             "result": ["title": "", "emotion": "", "summary": "", "insight": "", "expressionMoment": "", "quote": "",
                        "confidenceScore": 0.0, "suggestedQuest": ""]]
        }
        let mapped = GuestCloudBackupMapper.map(journal: [doc("Newer", edited: 1_790_000_000), doc("Older", edited: 1_785_000_000)],
                                                practice: [], uid: "u", project: "p")
        XCTAssertEqual(mapped.entries.map(\.originalWords), ["Newer"])
        let reversed = GuestCloudBackupMapper.map(journal: [doc("Older", edited: 1_785_000_000), doc("Newer", edited: 1_790_000_000)],
                                                  practice: [], uid: "u", project: "p")
        XCTAssertEqual(reversed.entries.map(\.originalWords), ["Newer"], "whatever the order")
    }

    func testDeleteMyAccountNeedsAFreshLogInAndKeepsLocalEntries() async throws {
        let (journal, _, _) = try await session()
        journal.draft = "Local words"
        _ = await journal.saveDraft()

        let account = ScriptedAccount(), reader = ScriptedReader()
        let model = GuestDeleteAccountViewModel(factory: GuestAccountFactory { (account, reader) })
        model.email = "person@example.com"; model.password = "secret"
        reader.keptCircles = 1
        await model.delete()
        XCTAssertEqual(model.step, .done(keptCircles: 1), "a circle with others' posts is kept and said so")
        XCTAssertEqual(reader.deletedUIDs, ["uid-1"])
        XCTAssertTrue(account.deletedAccount)
        XCTAssertFalse(account.signedIn)
        await journal.load()
        XCTAssertEqual(journal.entries.map(\.originalWords), ["Local words"], "local entries stay")
    }

    func testDeleteFailuresNeverReportSuccess() async throws {
        let account = ScriptedAccount(), reader = ScriptedReader()
        reader.deleteError = .failed
        let model = GuestDeleteAccountViewModel(factory: GuestAccountFactory { (account, reader) })
        model.email = "person@example.com"; model.password = "secret"
        await model.delete()
        XCTAssertEqual(model.message, GuestDeleteAccountViewModel.backupNotDeletedMessage)
        XCTAssertFalse(account.deletedAccount, "the account isn't deleted when its backup wasn't")

        reader.deleteError = nil
        account.deleteError = .failed
        model.password = "secret"
        await model.delete()
        XCTAssertEqual(model.message, GuestDeleteAccountViewModel.accountNotDeletedMessage)
        XCTAssertEqual(model.step, .form)

        account.logInResults = [.failure(.couldNotLogIn)]
        account.deleteError = nil
        model.password = "wrong"
        await model.delete()
        XCTAssertEqual(model.message, "Check your email and password. Your entries are unchanged.")
    }

    func testScopedReceiptsSeparateProjectsAccountsAndKinds() {
        let id = UUID()
        let a = GuestScopedID.cloud(project: "dev", uid: "u1", kind: "journal", id: id)
        XCTAssertEqual(a, GuestScopedID.cloud(project: "dev", uid: "u1", kind: "journal", id: id), "stable")
        XCTAssertNotEqual(a, GuestScopedID.cloud(project: "prod", uid: "u1", kind: "journal", id: id))
        XCTAssertNotEqual(a, GuestScopedID.cloud(project: "dev", uid: "u2", kind: "journal", id: id))
        XCTAssertNotEqual(a, GuestScopedID.cloud(project: "dev", uid: "u1", kind: "practice", id: id))
        XCTAssertNotEqual(a, id)
    }

    func testOpeningTheGuestJournalNeverTouchesFirebase() async throws {
        let before = FirebaseRuntime.debugCloudAccessCount
        _ = try await session()
        XCTAssertEqual(FirebaseRuntime.debugCloudAccessCount, before, "Firebase is only reached when Log in is used")
    }
}
