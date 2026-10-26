import XCTest

/// Today option B: question chips, "Need a nudge?", one Save and the optional reflection after it
/// (user stories T8, T9 and T6).
final class GuestTodayUITests: XCTestCase {
    func has(_ app: XCUIApplication, _ text: String, _ timeout: TimeInterval = 5) -> Bool {
        app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", text)).firstMatch.waitForExistence(timeout: timeout)
    }

    func shot(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = name; shot.lifetime = .keepAlways; add(shot)
    }

    func words(_ app: XCUIApplication) -> String { app.textViews["Your words"].value as? String ?? "" }

    func testChipsStartTheWordsAndTheNudgeHelpsWhileWriting() throws {
        continueAfterFailure = false
        let app = launchGuest(fresh: true)
        let editor = app.textViews["Your words"]
        XCTAssertTrue(editor.waitForExistence(timeout: 15))
        XCTAssertFalse(app.buttons["Get a suggestion"].exists, "replaced by the prompts")
        XCTAssertFalse(app.buttons["Save"].isEnabled, "nothing to save yet")
        for question in ["What happened?", "Who was it with?", "What do you wish you’d said?"] {
            XCTAssertTrue(app.buttons[question].exists, question)
        }
        shot(app, "t1-chips")
        app.buttons["What do you wish you’d said?"].tap()
        XCTAssertEqual(words(app), "I wish I’d said ", "the starter, not the question")
        XCTAssertFalse(app.buttons["What happened?"].exists, "chips go once there are words")

        app.typeText("that I needed more time on the slides")
        XCTAssertTrue(has(app, "Need a nudge?"))
        let first = "What did you want them to understand?"
        XCTAssertTrue(has(app, first))
        shot(app, "t2-nudge")
        app.buttons["Another question"].tap()
        XCTAssertTrue(has(app, "How did you feel right after?"))
        XCTAssertFalse(app.staticTexts[first].exists)
        app.buttons["Add to my words"].tap()
        XCTAssertTrue(words(app).hasSuffix("the slides\nRight after, I felt "), "the starter on a new line: \(words(app))")
        app.typeText("embarrassed")
        app.buttons["Hide"].tap()
        XCTAssertFalse(app.staticTexts["Need a nudge?"].waitForExistence(timeout: 1), "hidden")
        shot(app, "t3-hidden")

        app.buttons["Save"].tap()
        XCTAssertTrue(has(app, "Saved to your journal"))
        XCTAssertTrue(app.buttons["Not now"].exists)
        shot(app, "t4-offer")
        app.buttons["Not now"].tap()
        XCTAssertFalse(app.buttons["Reflect on it"].waitForExistence(timeout: 1), "Not now closes the offer")
        XCTAssertTrue(has(app, "I wish I’d said that I needed more time"), "saved as written")

        app.tabBars.buttons["Today"].tap()
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        XCTAssertEqual(words(app), "", "a fresh box after saving")
        XCTAssertTrue(app.buttons["What happened?"].exists, "the chips are back for the next entry")
    }
}
