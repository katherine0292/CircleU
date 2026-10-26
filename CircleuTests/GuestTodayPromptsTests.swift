import XCTest
@testable import Circleu

/// Today's question chips and "Need a nudge?" (user stories T8 and T9).
@MainActor
final class GuestTodayPromptsTests: XCTestCase {
    func testThreeStarterChipsEachAddOnlyTheirStarter() {
        XCTAssertEqual(GuestTodayPrompts.starters.map(\.question),
                       ["What happened?", "Who was it with?", "What do you wish you’d said?"])
        let started = GuestTodayPrompts.starters.map { GuestTodayPrompts.inserting($0.starter, into: "") }
        XCTAssertEqual(started, ["What happened was ", "I was with ", "I wish I’d said "],
                       "an empty box starts with the chip's starter, never its question")
        XCTAssertEqual(GuestTodayPrompts.inserting("I wish I’d said ", into: "  \n"), "I wish I’d said ")
    }

    func testAStarterGoesOnANewLineAfterExistingWords() {
        XCTAssertEqual(GuestTodayPrompts.inserting("Right after, I felt ", into: "I froze in the meeting.  \n"),
                       "I froze in the meeting.\nRight after, I felt ")
    }

    func testNudgeShowsOnceThereAreWordsAndNotWhileDictating() {
        let nudge = GuestNudgeModel()
        XCTAssertFalse(nudge.isShown(for: "", isDictating: false), "the chips show instead")
        XCTAssertFalse(nudge.isShown(for: "I froze in the", isDictating: false), "four words isn't enough yet")
        XCTAssertTrue(nudge.isShown(for: "I froze in the meeting", isDictating: false))
        XCTAssertFalse(nudge.isShown(for: "I froze in the meeting", isDictating: true), "not over the microphone")
    }

    func testAnotherQuestionCyclesAndAddMovesOn() {
        let prompts = GuestTodayPrompts.followUps
        let nudge = GuestNudgeModel()
        XCTAssertEqual(nudge.prompt, prompts[0])
        nudge.next()
        XCTAssertEqual(nudge.prompt, prompts[1], "Another question")
        let words = nudge.add(to: "My groupmate missed the deadline again")
        XCTAssertEqual(words, "My groupmate missed the deadline again\n" + prompts[1].starter,
                       "Add to my words adds the starter, never the question")
        XCTAssertEqual(nudge.prompt, prompts[2], "and the next question is different")
        for _ in 0..<prompts.count { nudge.next() }
        XCTAssertEqual(nudge.prompt, prompts[2], "wraps around")
    }

    func testHideLastsForThisEntryOnly() {
        let nudge = GuestNudgeModel()
        let words = "I froze in the meeting again"
        nudge.hide()
        XCTAssertFalse(nudge.isShown(for: words, isDictating: false))
        nudge.wordsChanged(to: words + " today")
        XCTAssertFalse(nudge.isShown(for: words + " today", isDictating: false), "still hidden while writing")
        nudge.wordsChanged(to: "") // Saved: the box is empty again.
        XCTAssertTrue(nudge.isShown(for: words, isDictating: false), "a new entry can be nudged again")
    }
}
