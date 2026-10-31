import XCTest
@testable import Circleu

/// Message-first Practice (P9): start with words, ask for guidance only when needed, and reach a
/// suggestion that can be used, compared or kept without retyping anything.
private struct ScriptedSuggester: GuestSuggesting {
    var fail = false
    func reflection(for words: String) async throws -> GuestReflectionSuggestion { throw GuestSuggestionError.noWords }
    func wordingOptions(situation: String, goal: String, draft: String) async throws -> GuestWordingSuggestions {
        if fail { throw GuestSuggestionError.noWords }
        return GuestWordingSuggestions(options: [
            .init(tone: "Gentle", text: "Gentle: \(draft.isEmpty ? goal : draft)"),
            .init(tone: "Clear", text: "Clear: \(draft.isEmpty ? goal : draft)"),
            .init(tone: "Firm", text: "Firm: \(draft.isEmpty ? goal : draft)"),
        ], source: .guided)
    }
}

private actor QuietPracticeStore: GuestPracticeStore {
    func loadPractice() throws -> [GuestPracticeMessage] { [] }
    func createPractice(situation: String, goal: String, wording: String, sourceEntryID: UUID?, draftID: UUID?) throws -> GuestPracticeMessage {
        GuestPracticeMessage(id: UUID(), situation: situation, goal: goal, wording: wording, sourceEntryID: sourceEntryID,
                             revision: 0, createdAt: Date(), updatedAt: Date())
    }
    func updatePractice(id: UUID, situation: String, goal: String, wording: String, expectedRevision: Int) throws -> GuestPracticeMessage {
        throw GuestJournalError.notFound
    }
    func isDraftSaved(_ draftID: UUID) throws -> Bool { false }
    func deletePractice(id: UUID) throws {}
    func deleteEntry(id: UUID, linkedPractice: GuestLinkedPracticeChoice) throws {}
}

@MainActor
final class GuestPracticeMessageFirstTests: XCTestCase {
    private func composer(fail: Bool = false) -> GuestPracticeComposerViewModel {
        GuestPracticeComposerViewModel(store: QuietPracticeStore(), sourceEntryID: nil, suggester: ScriptedSuggester(fail: fail))
    }

    func testStartsWithWordsAndNoRequiredForm() {
        let composer = composer()
        XCTAssertEqual(composer.stage, .prepare)
        XCTAssertFalse(composer.canReviewWording, "no words yet")
        composer.wording = "Can you take a fair share before Friday?"
        XCTAssertTrue(composer.canReviewWording, "words alone are enough; no situation or tone needed")
    }

    func testGuidanceRoundTripKeepsWording() {
        let composer = composer()
        composer.wording = "Can you take a fair share?"
        composer.openGuidance()
        XCTAssertEqual(composer.stage, .guide)
        XCTAssertFalse(composer.canContinueGuidance, "blank intent can't continue")
        composer.goal = "Agree on a fair split"
        composer.continueGuidance()
        XCTAssertEqual(composer.stage, .prepare)
        XCTAssertEqual(composer.wording, "Can you take a fair share?", "wording survives guidance")
        XCTAssertNil(composer.suggestions, "completing guidance requests nothing")
    }

    func testBlankStartNeedsIntentThenFindsWordsFromIt() async {
        let composer = composer()
        XCTAssertFalse(composer.canFindWordsFromIntent)
        composer.openGuidance()
        composer.goal = "Agree on a fair split"
        composer.continueGuidance()
        XCTAssertTrue(composer.canFindWordsFromIntent, "intent without wording offers to find words")
        await composer.findWordsFromIntent()
        XCTAssertEqual(composer.stage, .result)
        XCTAssertTrue(composer.resultIsFromIntent, "labelled as intent, never as a message I wrote")
        XCTAssertEqual(composer.suggestedWording?.text, "Clear: Agree on a fair split")
        XCTAssertEqual(composer.wording, "", "nothing is put in my words until I use it")
    }

    func testReviewOffersPreferredToneFirstAndUseCompareKeepAreSeparate() async {
        let composer = composer()
        composer.wording = "Can you take a fair share?"
        composer.tone = "Firm"
        await composer.reviewWording()
        XCTAssertEqual(composer.stage, .result)
        XCTAssertEqual(composer.suggestedWording?.tone, "Firm", "the chosen tone leads")
        XCTAssertEqual(composer.otherWordings.map(\.tone), ["Gentle", "Clear"], "compare shows the rest")
        composer.useSuggestedWording()
        XCTAssertEqual(composer.stage, .refine)
        XCTAssertEqual(composer.wording, "Firm: Can you take a fair share?")
        XCTAssertEqual(composer.conversation?.originalWords, "Can you take a fair share?", "my first words are kept")
        composer.undoSuggestion()
        XCTAssertEqual(composer.wording, "Can you take a fair share?")
    }

    func testKeepMyWordingLeavesWordsUnchanged() async {
        let composer = composer()
        composer.wording = "Can you take a fair share?"
        await composer.reviewWording()
        composer.keepMyWording()
        XCTAssertEqual(composer.stage, .refine)
        XCTAssertEqual(composer.wording, "Can you take a fair share?")
        XCTAssertNil(composer.wordingBeforeSuggestion, "nothing to undo")
    }

    func testFailedReviewKeepsWordsEditableAndSaveable() async {
        let composer = composer(fail: true)
        composer.wording = "Can you take a fair share?"
        await composer.reviewWording()
        XCTAssertEqual(composer.stage, .result)
        XCTAssertEqual(composer.suggestionError, GuestPracticeComposerViewModel.suggestionFailedMessage)
        XCTAssertNil(composer.suggestedWording)
        composer.keepMyWording()
        XCTAssertTrue(composer.canSave, "still my words, still saveable")
    }

    /// A new review hides the earlier options and drops an older Undo, so neither acts on newer words.
    func testNewReviewInvalidatesEarlierOptionsAndUndo() async {
        let composer = composer()
        composer.wording = "First try"
        await composer.reviewWording()
        composer.useSuggestedWording()
        XCTAssertNotNil(composer.wordingBeforeSuggestion)
        composer.wording = "Second try, edited by hand"
        await composer.reviewWording()
        XCTAssertEqual(composer.stage, .result)
        XCTAssertNil(composer.wordingBeforeSuggestion, "an Undo from the earlier review no longer applies")
        XCTAssertEqual(composer.suggestedWording?.text, "Clear: Second try, edited by hand", "only the new result can be used")
        XCTAssertEqual(composer.conversation?.originalWords, "First try", "my first words stay as the first words")
    }

    func testFailedNewReviewLeavesNothingToUse() async {
        let composer = composer(fail: true)
        composer.wording = "Only try"
        await composer.reviewWording()
        XCTAssertNil(composer.suggestedWording)
        XCTAssertTrue(composer.otherWordings.isEmpty)
        XCTAssertNil(composer.wordingBeforeSuggestion)
    }

    func testSaveWithoutFeedbackSavesMyWordsAsTheyAre() async {
        let composer = composer()
        composer.wording = "Can you take a fair share?"
        let saved = await composer.saveWithoutFeedback()
        XCTAssertTrue(saved)
        XCTAssertEqual(composer.saved?.wording, "Can you take a fair share?")
        XCTAssertNil(composer.suggestions, "no request was made")
    }
}
