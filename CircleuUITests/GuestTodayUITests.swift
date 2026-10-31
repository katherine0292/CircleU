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

    func testQuestionGuidancePreservesWordsAndResetsAfterSave() throws {
        continueAfterFailure = false
        let app = launchGuest(fresh: true)
        let editor = app.textViews["Your words"]
        XCTAssertTrue(editor.waitForExistence(timeout: 15))
        shot(app, "today-aligned-empty")
        app.buttons["Suggest a question"].tap()
        app.buttons["What happened?"].tap()
        XCTAssertEqual(words(app), "")
        editor.tap(); editor.typeText("I wanted to say: no, thank you.")
        app.buttons["Change question"].tap()
        app.buttons["How did it make you feel?"].tap()
        XCTAssertEqual(words(app), "I wanted to say: no, thank you.")
        app.buttons["Remove question"].tap()
        XCTAssertEqual(words(app), "I wanted to say: no, thank you.")
        app.buttons["Suggest a question"].tap()
        app.buttons["Close questions"].tap()
        XCTAssertEqual(words(app), "I wanted to say: no, thank you.")
        app.buttons["Suggest a question"].tap()
        app.buttons["What would you like to say next?"].tap()
        shot(app, "today-aligned-question")
        app.buttons["Save"].tap()
        XCTAssertTrue(has(app, "Saved", 10))
        app.buttons["Not now"].tap()
        XCTAssertTrue(has(app, "I wanted to say: no, thank you."))
        app.tabBars.buttons["Today"].tap()
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        XCTAssertEqual(words(app), "")
        XCTAssertTrue(app.buttons["Suggest a question"].exists)
    }

    func testTodayAtLargestTextKeepsPromptsAvatarAndSaveReachable() throws {
        continueAfterFailure = false
        let app = launchGuest(fresh: true,
                              ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"])
        let editor = app.textViews["Your words"]
        XCTAssertTrue(editor.waitForExistence(timeout: 15))
        let avatar = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Your Pingu:")).firstMatch
        XCTAssertTrue(avatar.isHittable)
        avatar.tap()
        app.buttons["Done"].tap()
        let prompt = app.buttons["Suggest a question"]
        for _ in 0..<6 where !prompt.isHittable { app.swipeUp() }
        XCTAssertTrue(prompt.isHittable)
        XCTAssertTrue(app.buttons["Start dictation"].isHittable)
        shot(app, "today-aligned-ax5")
        prompt.tap()
        let question = app.buttons["What would you like to say next?"]
        for _ in 0..<6 where !question.isHittable { app.swipeUp() }
        question.tap()
        for _ in 0..<6 where !editor.isHittable { app.swipeDown() }
        editor.tap(); editor.typeText("I needed more time")
        XCTAssertTrue(app.buttons["Save"].isHittable)
        app.buttons["Save"].tap()
        XCTAssertTrue(has(app, "I needed more time", 10))
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
