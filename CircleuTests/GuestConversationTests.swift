import XCTest
import SwiftData
@testable import Circleu

@MainActor
final class GuestConversationTests: XCTestCase {
    private var root: URL!
    private var location: GuestJournalLocation!
    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        location = GuestJournalLocation(directory: root.appendingPathComponent("Journal"),
                                        setupMarker: root.appendingPathComponent("Setup/initialized"))
    }
    override func tearDownWithError() throws { try? FileManager.default.removeItem(at: root) }
    private func open() async throws -> SwiftDataGuestJournalStore {
        try await SwiftDataGuestJournalStore.open(location: location, protection: .init { _ in })
    }

    func testReplyPreservesAttributedHistoryAndSurvivesReopenAndExport() async throws {
        var store: SwiftDataGuestJournalStore? = try await open()
        let entry = try await store!.create(originalWords: "A difficult meeting")
        let model = GuestPracticeComposerViewModel(store: store!, sourceEntryID: entry.id)
        model.wording = "Could we talk tomorrow?"
        model.prepareRefinement()
        let didSave = await model.save()
        XCTAssertTrue(didSave)
        let id = try XCTUnwrap(model.saved?.id)
        model.edit()
        model.replyText = "Tomorrow works"
        model.replyContext = "After lunch"
        model.continueReply()
        XCTAssertEqual(model.conversation?.turns.map(\.text),
                       ["Could we talk tomorrow?", "Tomorrow works", "After lunch"])
        XCTAssertEqual(model.conversation?.turns.map(\.kind), [.wording, .theirReply, .context])
        XCTAssertEqual(model.wording, "")
        model.wording = "Let's meet at two"
        let didSaveReply = await model.save()
        XCTAssertTrue(didSaveReply)
        let saved = try XCTUnwrap(model.saved)
        XCTAssertEqual(saved.id, id)
        XCTAssertEqual(saved.revision, 1)
        XCTAssertEqual(saved.sourceEntryID, entry.id)
        store = nil
        let reopened = try await open()
        let rows = try await reopened.loadPractice()
        XCTAssertEqual(rows.first?.conversation, saved.conversation)
        XCTAssertTrue(GuestSearch.matches(saved, "Tomorrow works"))
        let export = GuestExport.text(entries: [entry], messages: rows)
        XCTAssertTrue(export.contains("Their reply: Tomorrow works"))
        XCTAssertTrue(export.contains("Let's meet at two"))
        try await reopened.deleteEntry(id: entry.id, linkedPractice: .keepMessages)
        let kept = try await reopened.loadPractice()
        XCTAssertEqual(kept.first?.conversation, saved.conversation)
        XCTAssertNil(kept.first?.sourceEntryID)
    }

    func testGuidedReplyDoesNotEchoTheirWordsOrMetadataAsMine() async throws {
        let conversation = GuestPracticeConversation(turns: [.init(kind: .theirReply, text: "Private reply")])
        let options = try await LocalFirstSuggestionEngine(guidedOnly: true).conversationOptions(
            situation: "Work", goal: "Agree on a time", draft: "", conversation: conversation)
        XCTAssertEqual(options.source, .guided)
        XCTAssertEqual(options.options.count, 3)
        for option in options.options {
            XCTAssertFalse(option.text.contains("Private reply"))
            XCTAssertFalse(option.text.contains("Scene:"))
            XCTAssertFalse(option.text.contains("Draft a reply"))
        }
    }

    func testContextOnlyDoesNotInventAnIncomingReply() async throws {
        let conversation = GuestPracticeConversation(turns: [
            .init(kind: .theirReply, text: "Earlier reply"),
            .init(kind: .wording, text: "Earlier wording"),
            .init(kind: .context, text: "More information about the meeting")])
        let options = try await LocalFirstSuggestionEngine(guidedOnly: true).conversationOptions(
            situation: "Work", goal: "", draft: "", conversation: conversation)
        XCTAssertFalse(options.options.contains { $0.text.contains("your reply") || $0.text.contains("getting back") })
    }

    func testConversationReopensAndStaleUpdateCannotReplaceHistory() async throws {
        let conversation = GuestPracticeConversation(originalWords: "First", turns: [.init(kind: .theirReply, text: "Reply")])
        let id: UUID
        do {
            let store = try await open()
            let row = try await store.createConversation(situation: "Work", goal: "", wording: "Next",
                sourceEntryID: nil, draftID: nil, conversation: conversation)
            id = row.id
        }
        let reopened = try await open()
        let rows = try await reopened.loadPractice()
        XCTAssertEqual(rows.first?.conversation, conversation)
        var changed = conversation
        changed.turns.append(.init(kind: .context, text: "New context"))
        _ = try await reopened.updateConversation(id: id, situation: "Work", goal: "", wording: "Updated",
            expectedRevision: 0, conversation: changed)
        do {
            _ = try await reopened.updateConversation(id: id, situation: "", goal: "", wording: "Stale",
                expectedRevision: 0, conversation: conversation)
            XCTFail("Stale write must fail")
        } catch GuestJournalError.staleRevision { }
        let latest = try await reopened.loadPractice()
        XCTAssertEqual(latest.first?.conversation, changed)
        XCTAssertEqual(latest.first?.wording, "Updated")
        try await reopened.deletePractice(id: id)
        let empty = try await reopened.loadPractice()
        XCTAssertTrue(empty.isEmpty)
    }

    func testUnreadableConversationIsAnErrorInsteadOfEmptyHistory() async throws {
        try FileManager.default.createDirectory(at: location.directory, withIntermediateDirectories: true)
        do {
            let schema = Schema(versionedSchema: GuestJournalSchemaV5.self)
            let container = try ModelContainer(for: schema, configurations: ModelConfiguration(url: location.storeURL))
            let context = ModelContext(container)
            let row = GuestJournalSchemaV5.PracticeMessage(id: UUID(), situation: "", goal: "",
                wording: "Kept", sourceEntryID: nil, revision: 0, createdAt: Date(), updatedAt: Date())
            row.conversationData = Data("unreadable".utf8)
            context.insert(row)
            try context.save()
        }
        let store = try await open()
        do {
            _ = try await store.loadPractice()
            XCTFail("Unreadable history must surface an error")
        } catch GuestJournalError.storeUnavailable { }
    }

    func testDraftRoundTripPreservesPendingReplyAndOriginalWords() throws {
        let conversation = GuestPracticeConversation(originalWords: "First", turns: [.init(kind: .wording, text: "Prepared")],
            pendingReply: "Their words", pendingContext: "My context")
        let draft = GuestPracticeDraft(wording: "Next", conversation: conversation)
        let restored = try JSONDecoder().decode(GuestPracticeDraft.self, from: JSONEncoder().encode(draft))
        XCTAssertEqual(restored, draft)
        XCTAssertFalse(restored.isEmpty)
    }

    func testBlankReplyDoesNotEraseCurrentWordingAndOldDraftDecodes() async throws {
        let model = GuestPracticeComposerViewModel(store: try await open(), sourceEntryID: nil)
        model.wording = "Original"
        model.continueReply()
        XCTAssertEqual(model.wording, "Original")
        XCTAssertNil(model.conversation)
        let old = Data("{\"id\":\"00000000-0000-0000-0000-000000000001\",\"situation\":\"Work\",\"goal\":\"\",\"wording\":\"Hi\"}".utf8)
        XCTAssertNil(try JSONDecoder().decode(GuestPracticeDraft.self, from: old).conversation)
    }

    func testV4MigrationPreservesOldMessageWithoutInventingHistory() async throws {
        try FileManager.default.createDirectory(at: location.directory, withIntermediateDirectories: true)
        let id = UUID()
        do {
            let schema = Schema(versionedSchema: GuestJournalSchemaV4.self)
            let container = try ModelContainer(for: schema, configurations: ModelConfiguration(url: location.storeURL))
            let context = ModelContext(container)
            context.insert(GuestJournalSchemaV4.PracticeMessage(id: id, situation: "Work", goal: "Be clear",
                wording: "Original", sourceEntryID: nil, revision: 3, createdAt: Date(), updatedAt: Date()))
            try context.save()
        }
        let store = try await open()
        let rows = try await store.loadPractice()
        XCTAssertEqual(rows.first?.id, id)
        XCTAssertEqual(rows.first?.revision, 3)
        XCTAssertEqual(rows.first?.wording, "Original")
        XCTAssertNil(rows.first?.conversation)
    }
}

@MainActor
private final class ReviewSpeechEngine: GuestDictationEngine {
    var access: GuestDictationAccess = .granted
    var continuation: AsyncStream<GuestDictationEvent>.Continuation?
    func requestAccess() async -> GuestDictationAccess { access }
    func start() throws -> AsyncStream<GuestDictationEvent> {
        let (stream, continuation) = AsyncStream.makeStream(of: GuestDictationEvent.self)
        self.continuation = continuation
        return stream
    }
    func finish() { continuation?.finish() }
    func cancel() {}
}

@MainActor
final class GuestVoiceReviewTests: XCTestCase {
    func testTranscriptIsReviewedAndCancelledLateEventsAreIgnored() async {
        let engine = ReviewSpeechEngine()
        let model = GuestVoiceReviewModel(engine: engine)
        await model.start()
        engine.continuation?.yield(.transcript("A thought", isFinal: false))
        for _ in 0..<50 { await Task.yield() }
        XCTAssertEqual(model.transcript, "A thought")
        XCTAssertFalse(model.canUse)
        model.stop()
        for _ in 0..<50 { await Task.yield() }
        XCTAssertTrue(model.canUse)
        model.cancel()
        engine.continuation?.yield(.transcript("Late", isFinal: true))
        for _ in 0..<50 { await Task.yield() }
        XCTAssertEqual(model.transcript, "A thought")
    }
    func testDeniedPermissionKeepsTypingAvailable() async {
        let engine = ReviewSpeechEngine()
        engine.access = .microphoneDenied
        let model = GuestVoiceReviewModel(engine: engine)
        await model.start()
        XCTAssertFalse(model.isActive)
        XCTAssertNotNil(model.error)
        model.transcript = "Typed instead"
        XCTAssertTrue(model.canUse)
    }
}
