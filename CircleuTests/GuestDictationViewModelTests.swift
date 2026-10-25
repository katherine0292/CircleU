import Foundation
import XCTest
@testable import Circleu

/// Saves in memory, so dictated words can be followed through to the Journal.
private actor MemoryJournalStore: GuestJournalStore {
    private var rows: [GuestJournalEntry] = []

    func loadAll() throws -> [GuestJournalEntry] { rows }
    func create(originalWords: String, draftID: UUID?) throws -> GuestJournalEntry {
        let entry = GuestJournalEntry(id: UUID(), originalWords: originalWords, revision: 0,
                                      createdAt: Date(), updatedAt: Date())
        rows.insert(entry, at: 0)
        return entry
    }
    func update(id: UUID, originalWords: String, expectedRevision: Int) throws -> GuestJournalEntry {
        throw GuestJournalError.notFound
    }
    func delete(id: UUID) throws {}
    func isDraftSaved(_ draftID: UUID) throws -> Bool { false }
}

/// Stands in for the Speech framework: the test decides access and sends recogniser events.
@MainActor
private final class FakeDictationEngine: GuestDictationEngine {
    var access: GuestDictationAccess = .granted
    var startError: Error?
    private(set) var startCount = 0
    private(set) var finishCount = 0
    private(set) var cancelCount = 0
    private var continuation: AsyncStream<GuestDictationEvent>.Continuation?
    /// When set, `requestAccess` waits until `grantAccess()` (the permission prompt is showing).
    var holdsAccessPrompt = false
    private var pendingAccess: CheckedContinuation<Void, Never>?

    func requestAccess() async -> GuestDictationAccess {
        if holdsAccessPrompt { await withCheckedContinuation { pendingAccess = $0 } }
        return access
    }

    func grantAccess() {
        pendingAccess?.resume()
        pendingAccess = nil
    }

    func start() throws -> AsyncStream<GuestDictationEvent> {
        if let startError { throw startError }
        startCount += 1
        let (stream, continuation) = AsyncStream.makeStream(of: GuestDictationEvent.self)
        self.continuation = continuation
        return stream
    }

    func finish() { finishCount += 1 }
    /// Like the real recogniser, a cancelled stream may still deliver a late callback.
    func cancel() {
        cancelCount += 1
        cancelled = continuation
        continuation = nil
    }
    private var cancelled: AsyncStream<GuestDictationEvent>.Continuation?

    func send(_ event: GuestDictationEvent) { continuation?.yield(event) }
    func sendLate(_ event: GuestDictationEvent) { cancelled?.yield(event) }
    func end() {
        continuation?.finish()
        continuation = nil
    }
}

private struct StartFailure: Error {}

@MainActor
final class GuestDictationViewModelTests: XCTestCase {
    private func make(_ given: FakeDictationEngine? = nil)
        -> (GuestJournalViewModel, GuestDictationViewModel, FakeDictationEngine) {
        let engine = given ?? FakeDictationEngine()
        let journal = GuestJournalViewModel(store: MemoryJournalStore())
        return (journal, GuestDictationViewModel(journal: journal, engine: engine), engine)
    }

    /// Lets the view model's listening task handle what the fake sent.
    private func settle() async {
        for _ in 0..<5 { await Task.yield() }
    }

    func testSpokenWordsAppearInTheDraftAsTheyAreRecognised() async {
        let (journal, dictation, engine) = make()
        await dictation.start()
        XCTAssertEqual(dictation.state, .listening)
        XCTAssertTrue(dictation.isActive, "the editor is read-only while listening")

        engine.send(.transcript("I froze", isFinal: false))
        await settle()
        XCTAssertEqual(journal.draft, "I froze")
        engine.send(.transcript("I froze in the meeting.", isFinal: false))
        await settle()
        XCTAssertEqual(journal.draft, "I froze in the meeting.", "partial results replace, not repeat")
    }

    func testDictationGoesAfterTypedTextAndKeepsIt() async {
        let (journal, dictation, engine) = make()
        journal.draft = "Typed first."
        await dictation.start()
        engine.send(.transcript("Then I spoke.", isFinal: false))
        await settle()
        XCTAssertEqual(journal.draft, "Typed first. Then I spoke.")

        let (journal2, dictation2, engine2) = make()
        journal2.draft = "Line one\n"
        await dictation2.start()
        engine2.send(.transcript("Line two", isFinal: false))
        await settle()
        XCTAssertEqual(journal2.draft, "Line one\nLine two", "no extra space after a line break")
    }

    func testStopKeepsTheWordsAndWaitsForTheFinalText() async {
        let (journal, dictation, engine) = make()
        await dictation.start()
        engine.send(.transcript("Almost", isFinal: false))
        await settle()
        dictation.stop()
        XCTAssertEqual(engine.finishCount, 1)
        XCTAssertEqual(dictation.state, .finishing)

        engine.send(.transcript("Almost there.", isFinal: true))
        engine.end()
        await settle()
        XCTAssertEqual(journal.draft, "Almost there.")
        XCTAssertEqual(dictation.state, .idle, "typing is available again")
        XCTAssertNil(dictation.message)
    }

    func testDictatedThenEditedWordsSaveToTheJournal() async {
        let (journal, dictation, engine) = make()
        await dictation.start()
        engine.send(.transcript("I said yes too fast", isFinal: true))
        engine.end()
        await settle()
        XCTAssertFalse(dictation.isActive)

        journal.draft += " and want to revisit it."
        let saved = await journal.saveDraft()
        XCTAssertTrue(saved)
        XCTAssertEqual(journal.entries.map(\.originalWords), ["I said yes too fast and want to revisit it."])
        XCTAssertEqual(journal.draft, "")
    }

    func testCancelRemovesOnlyTheSpokenWords() async {
        let (journal, dictation, engine) = make()
        journal.draft = "Keep this."
        await dictation.start()
        engine.send(.transcript("Not this", isFinal: false))
        await settle()
        dictation.cancel()
        XCTAssertEqual(engine.cancelCount, 1)
        XCTAssertEqual(journal.draft, "Keep this.")
        XCTAssertEqual(dictation.state, .idle)

        engine.sendLate(.transcript("late words", isFinal: true)) // A late callback must be ignored.
        engine.sendLate(.failed)
        await settle()
        XCTAssertEqual(journal.draft, "Keep this.")
        XCTAssertNil(dictation.message)
    }

    func testLateEventsFromACancelledDictationDontReachTheNextOne() async {
        let (journal, dictation, engine) = make()
        await dictation.start()
        engine.send(.transcript("First try", isFinal: false))
        await settle()
        dictation.cancel()

        journal.draft = "Typed."
        await dictation.start()
        XCTAssertEqual(engine.startCount, 2)
        engine.sendLate(.transcript("First try, late", isFinal: true))
        engine.sendLate(.interrupted)
        await settle()
        XCTAssertEqual(journal.draft, "Typed.")
        XCTAssertEqual(dictation.state, .listening, "the old stream can't end the new dictation")
        XCTAssertNil(dictation.message)

        engine.send(.transcript("Second try", isFinal: false))
        await settle()
        XCTAssertEqual(journal.draft, "Typed. Second try")
    }

    func testDeniedPermissionLeavesTypingAndOffersSettings() async {
        for denial in [GuestDictationAccess.speechDenied, .microphoneDenied] {
            let engine = FakeDictationEngine()
            engine.access = denial
            let (journal, dictation, _) = make(engine)
            journal.draft = "Typed"
            await dictation.start()
            XCTAssertEqual(engine.startCount, 0, "never listens without access")
            XCTAssertEqual(dictation.state, .idle)
            XCTAssertFalse(dictation.isActive, "typing still works")
            XCTAssertEqual(dictation.message, GuestDictationViewModel.deniedMessage)
            XCTAssertTrue(dictation.needsSettings)
            XCTAssertEqual(journal.draft, "Typed")
        }
    }

    func testNoOnDeviceSupportNeverListens() async {
        let engine = FakeDictationEngine()
        engine.access = .onDeviceUnavailable
        let (_, dictation, _) = make(engine)
        await dictation.start()
        XCTAssertEqual(engine.startCount, 0)
        XCTAssertEqual(dictation.message, GuestDictationViewModel.onDeviceUnavailableMessage)
        XCTAssertFalse(dictation.needsSettings)
        XCTAssertFalse(dictation.isActive)
    }

    func testStartFailureLeavesTypingAvailable() async {
        let engine = FakeDictationEngine()
        engine.startError = StartFailure()
        let (journal, dictation, _) = make(engine)
        journal.draft = "Typed"
        await dictation.start()
        XCTAssertEqual(dictation.state, .idle)
        XCTAssertEqual(dictation.message, GuestDictationViewModel.couldNotStartMessage)
        XCTAssertEqual(journal.draft, "Typed")
    }

    func testInterruptionKeepsTheWordsSoFar() async {
        let (journal, dictation, engine) = make()
        await dictation.start()
        engine.send(.transcript("Before the call", isFinal: false))
        engine.send(.interrupted)
        engine.end()
        await settle()
        XCTAssertEqual(journal.draft, "Before the call")
        XCTAssertEqual(dictation.message, GuestDictationViewModel.interruptedMessage)
        XCTAssertEqual(dictation.state, .idle)
    }

    func testRecogniserFailureKeepsTheWordsSoFar() async {
        let (journal, dictation, engine) = make()
        await dictation.start()
        engine.send(.transcript("Some words", isFinal: false))
        engine.send(.failed)
        engine.end()
        await settle()
        XCTAssertEqual(journal.draft, "Some words")
        XCTAssertEqual(dictation.message, GuestDictationViewModel.failedMessage)
        XCTAssertFalse(dictation.isActive)
    }

    func testLeavingTheAppStopsListeningAndKeepsTheWords() async {
        let (journal, dictation, engine) = make()
        await dictation.start()
        engine.send(.transcript("Halfway", isFinal: false))
        await settle()
        dictation.interrupt()
        XCTAssertEqual(engine.cancelCount, 1, "the microphone is released at once")
        engine.sendLate(.transcript("Halfway and more", isFinal: true))
        await settle()
        XCTAssertEqual(journal.draft, "Halfway")
        XCTAssertEqual(dictation.message, GuestDictationViewModel.interruptedMessage)
        XCTAssertFalse(dictation.isActive)
    }

    func testStoppingDuringThePermissionPromptNeverStartsListening() async {
        let engine = FakeDictationEngine()
        engine.holdsAccessPrompt = true
        let (_, dictation, _) = make(engine)
        let starting = Task { await dictation.start() }
        await settle()
        XCTAssertEqual(dictation.state, .requestingAccess)
        dictation.stop()
        engine.grantAccess()
        await starting.value
        XCTAssertEqual(engine.startCount, 0)
        XCTAssertEqual(dictation.state, .idle)
    }
}
