import Foundation
import XCTest
@testable import Circleu

/// Counts how often a reflection is asked for, so tests can show that too little text never
/// reaches the engine.
private final class CountingSuggester: GuestSuggesting, @unchecked Sendable {
    private let lock = NSLock()
    private var count = 0
    var reflectionCalls: Int { lock.withLock { count } }

    func reflection(for words: String) async throws -> GuestReflectionSuggestion {
        lock.withLock { count += 1 }
        return GuestReflectionSuggestion(summary: "Summary", feeling: "Calm", insight: "Insight",
                                         nextStep: "Step", source: .guided)
    }

    func wordingOptions(situation: String, goal: String, draft: String) async throws -> GuestWordingSuggestions {
        GuestWordingSuggestions(options: [], source: .guided)
    }
}

/// Item 1 of the AI next steps; rows refer to `docs/qa/ai-acceptance-cases.md`.
final class GuestReflectionInputCheckTests: XCTestCase {
    func testTooLittleToReflectOn() {
        let tooLittle = [
            "",                              // A1
            "   \n  ",                       // A2
            "bad day",                       // A3
            "um hello test testing okay",    // A4
            "?!?! ...",                      // A5
            "fuck fuck shit damn fuck",      // B1
            "fucking hell mate",             // B2: only two words once the swearing is left out
            "你好",                           // two characters without spaces
        ]
        for text in tooLittle {
            XCTAssertFalse(TranscriptQuality.hasEnoughToReflect(text), "\(text.debugDescription) is too little")
        }
    }

    func testEnoughToReflectOn() {
        let enough = [
            "I felt stressed before the group meeting",
            "A moment to reflect on",
            "My flatmate left the kitchen a mess again and I am so fucking sick of cleaning up after him.", // B3
            "A teammate took credit for my slides in the meeting today and I felt frustrated and invisible.", // C1
            "我今天和室友吵架了，因为她总是很晚回来还很吵。", // E2: Chinese has no spaces between words
        ]
        for text in enough {
            XCTAssertTrue(TranscriptQuality.hasEnoughToReflect(text), "\(text.debugDescription) is enough")
        }
    }

    @MainActor
    func testTooFewWordsNeverReachTheEngineAndKeepTheEntry() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("GuestInputCheck-\(UUID())")
        defer { try? FileManager.default.removeItem(at: root) }
        let location = GuestJournalLocation(directory: root.appendingPathComponent("Journal"),
                                            setupMarker: root.appendingPathComponent("Setup/initialized"))
        let (journal, _) = try await GuestComposition.local(at: location).makeSession()
        journal.draft = "bad day"
        let ok = await journal.saveDraft()
        XCTAssertTrue(ok)
        let entry = try XCTUnwrap(journal.entries.first)

        let suggester = CountingSuggester()
        let review = GuestReflectionReviewViewModel(entry: entry, journal: journal, suggester: suggester)
        await review.load()

        XCTAssertEqual(review.state, .needsMoreWords)
        XCTAssertEqual(suggester.reflectionCalls, 0, "the engine is never asked")
        XCTAssertFalse(review.canSave, "nothing to add")
        XCTAssertEqual(journal.entries.first?.originalWords, "bad day", "the words stay as written")
        XCTAssertNil(journal.entries.first?.reflection)
    }

    @MainActor
    func testEnoughWordsStillAskTheEngine() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("GuestInputCheck-\(UUID())")
        defer { try? FileManager.default.removeItem(at: root) }
        let location = GuestJournalLocation(directory: root.appendingPathComponent("Journal"),
                                            setupMarker: root.appendingPathComponent("Setup/initialized"))
        let (journal, _) = try await GuestComposition.local(at: location).makeSession()
        journal.draft = "I felt stressed before the group meeting"
        _ = await journal.saveDraft()
        let entry = try XCTUnwrap(journal.entries.first)

        let suggester = CountingSuggester()
        let review = GuestReflectionReviewViewModel(entry: entry, journal: journal, suggester: suggester)
        await review.load()

        XCTAssertEqual(review.state, .ready)
        XCTAssertEqual(suggester.reflectionCalls, 1)
    }

    func testPromptFitsTheScreenRules() {
        XCTAssertLessThanOrEqual(GuestReflectionReviewViewModel.needsMoreWordsMessage.count, 100)
    }
}
