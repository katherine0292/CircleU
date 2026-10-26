import XCTest

/// Today: question chips with icons, Pingu's "Need a nudge?" bubble, one Save and the optional
/// reflection after it (user stories T8, T9, T10 and T6).
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
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Save")).count, 1, "one Save")
        XCTAssertFalse(app.buttons["Save"].isEnabled, "nothing to save yet")
        XCTAssertTrue(app.buttons["Start dictation"].exists, "the big microphone, in Pingu's card")
        for gone in ["Type, or tap the microphone and talk.", "Tap to talk", "Not sure where to start?"] {
            XCTAssertFalse(app.staticTexts[gone].exists, "pictures instead of \(gone)")
        }
        for question in ["What happened?", "Who was it with?", "What do you wish you’d said?"] {
            XCTAssertTrue(app.buttons[question].exists, question)
        }
        shot(app, "t1-chips")
        app.buttons["What do you wish you’d said?"].tap()
        XCTAssertEqual(words(app), "I wish I’d said ", "the starter, not the question")
        XCTAssertFalse(app.buttons["What happened?"].exists, "chips go once there are words")

        app.typeText("that I needed more time on the slides")
        XCTAssertTrue(app.buttons["Another question"].waitForExistence(timeout: 5), "the nudge shows")
        XCTAssertFalse(app.staticTexts["Need a nudge?"].exists, "no label above the question")
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
        XCTAssertFalse(app.buttons["Another question"].waitForExistence(timeout: 1), "hidden")
        shot(app, "t3-hidden")

        app.buttons["Save"].tap()
        XCTAssertTrue(has(app, "Saved"))
        XCTAssertTrue(app.buttons["Not now"].exists)
        shot(app, "t4-offer")
        app.buttons["Not now"].tap()
        XCTAssertFalse(app.buttons["Reflect on it"].waitForExistence(timeout: 1), "Not now closes the offer")
        XCTAssertTrue(has(app, "I wish I’d said that I needed more time"), "saved as written")

        app.tabBars.buttons["Today"].tap()
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        XCTAssertEqual(words(app), "", "a fresh box after saving")
        XCTAssertTrue(app.buttons["What happened?"].exists, "the chips are back for the next entry")
        editor.tap(); editor.typeText("My flatmate left the dishes again")
        XCTAssertTrue(app.buttons["Another question"].waitForExistence(timeout: 5), "Hide lasted for the last entry only")
    }

    /// Delete all while a reflection is open closes it and leaves an empty Journal.
    func testDeleteAllClosesAnOpenReflection() throws {
        continueAfterFailure = false
        let app = launchGuest(fresh: true, ["-CircleUGuidedSuggestions", "YES"])
        let editor = app.textViews["Your words"]
        XCTAssertTrue(editor.waitForExistence(timeout: 15))
        editor.tap(); editor.typeText("A moment to reflect on")
        app.buttons["Save"].tap()
        app.buttons["Reflect on it"].tap()
        XCTAssertTrue(app.buttons["Save reflection"].waitForExistence(timeout: 10))
        app.tabBars.buttons["Today"].tap()
        app.buttons["Settings"].tap()
        let delete = app.buttons["Delete all data"]
        for _ in 0..<6 where !delete.isHittable { app.swipeUp() }
        delete.tap()
        app.buttons["Delete all"].tap()
        XCTAssertTrue(has(app, "was deleted from this iPhone", 10))
        app.tabBars.buttons["Journal"].tap()
        XCTAssertTrue(has(app, "Nothing saved yet.", 10), "the reflection closed with the journal")
        XCTAssertFalse(app.buttons["Save reflection"].exists)
    }
}
