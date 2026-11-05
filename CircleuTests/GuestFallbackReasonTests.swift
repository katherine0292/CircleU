import Foundation
import XCTest
@testable import Circleu

/// Item 2 of the AI next steps: when Apple Intelligence isn't used, the guided result still
/// arrives and says why in one plain line.
final class GuestFallbackReasonTests: XCTestCase {
    func testEachReasonHasItsOwnShortPlainLine() {
        let lines = GuestFallbackReason.allCases.map(\.line)
        XCTAssertEqual(Set(lines).count, lines.count, "every reason reads differently")
        for line in lines {
            XCTAssertLessThanOrEqual(line.count, 60, "\(line) fits a supporting line")
            XCTAssertFalse(line.lowercased().contains("analysis"), "no claim of analysing the person")
            XCTAssertFalse(line.contains("!"))
        }
        XCTAssertEqual(GuestFallbackReason.deviceNotEligible.line, "This iPhone can’t run Apple Intelligence.")
        XCTAssertEqual(GuestFallbackReason.appleIntelligenceOff.line, "Apple Intelligence is off in Settings.")
        XCTAssertEqual(GuestFallbackReason.modelNotReady.line, "Apple Intelligence is still getting ready.")
    }

    func testReflectionIsStillGuidedAndKeepsTheReason() async throws {
        for reason in GuestFallbackReason.allCases where reason != .modelDidNotAnswer {
            let engine = LocalFirstSuggestionEngine(modelUnavailableReason: { reason })
            let reflection = try await engine.reflection(for: "I felt stressed before the group meeting")
            XCTAssertEqual(reflection.source, .guided)
            XCTAssertEqual(reflection.fallbackReason, reason)
            XCTAssertFalse(reflection.summary.isEmpty, "the guided result is still returned")
        }
    }

    func testWordingIsStillGuidedAndKeepsTheReason() async throws {
        let engine = LocalFirstSuggestionEngine(modelUnavailableReason: { .appleIntelligenceOff })
        let wording = try await engine.wordingOptions(situation: "The group project", goal: "Split the work fairly",
                                                      draft: "")
        XCTAssertEqual(wording.source, .guided)
        XCTAssertEqual(wording.fallbackReason, .appleIntelligenceOff)
        XCTAssertEqual(wording.options.map(\.tone), ["Gentle", "Clear", "Firm"])

        let conversation = try await engine.conversationOptions(situation: "The group project", goal: "Split the work",
                                                                draft: "", conversation: GuestPracticeConversation())
        XCTAssertEqual(conversation.fallbackReason, .appleIntelligenceOff)
    }

    func testUITestModeShowsNoReason() async throws {
        let engine = LocalFirstSuggestionEngine(guidedOnly: true, modelUnavailableReason: { .deviceNotEligible })
        let reflection = try await engine.reflection(for: "I felt stressed before the group meeting")
        XCTAssertEqual(reflection.source, .guided)
        XCTAssertNil(reflection.fallbackReason, "the guided-only test mode isn't a device limit")
    }
}
