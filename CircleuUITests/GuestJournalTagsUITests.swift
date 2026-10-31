import XCTest

final class GuestJournalTagsUITests: XCTestCase {
    private func seed(_ app: XCUIApplication) {
        let editor = app.textViews["Your words"]
        XCTAssertTrue(editor.waitForExistence(timeout: 15))
        editor.tap(); editor.typeText("I asked for more time on the assignment")
        app.buttons["Save"].tap()
        XCTAssertTrue(app.buttons["Not now"].waitForExistence(timeout: 10))
        app.buttons["Not now"].tap()
    }
    private func shot(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }
    func testTagsSaveCancelClearAndReopen() throws {
        continueAfterFailure = false
        var app = launchGuest(fresh: true)
        seed(app)
        app.buttons["Add context"].tap()
        app.buttons["Study"].tap(); app.buttons["Overloaded"].tap()
        shot(app, "journal-tags-picker")
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["Context: Study"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Feeling: Overloaded"].exists)
        shot(app, "journal-tagged-card")
        app.buttons["Feeling: Overloaded"].tap()
        app.buttons["Happy"].tap(); app.buttons["Cancel tags"].tap()
        XCTAssertTrue(app.buttons["Feeling: Overloaded"].exists)
        app.terminate(); app = launchGuest(fresh: false)
        app.tabBars.buttons["Journal"].tap()
        XCTAssertTrue(app.buttons["Context: Study"].waitForExistence(timeout: 10))
        app.buttons["Feeling: Overloaded"].tap()
        app.buttons["Overloaded"].tap(); app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["Add feeling"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Context: Study"].exists)
        app.staticTexts["I asked for more time on the assignment"].tap()
        XCTAssertTrue(app.buttons["Edit"].waitForExistence(timeout: 5))
    }
    func testTagPickerAtLargestText() throws {
        continueAfterFailure = false
        let app = launchGuest(fresh: true,
                              ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"])
        seed(app)
        let context = app.buttons["Add context"]
        for _ in 0..<8 where !context.isHittable { app.swipeUp() }
        context.tap()
        let family = app.buttons["Family"]
        for _ in 0..<8 {
            if family.isHittable && family.frame.maxY <= app.buttons["Done"].frame.minY { break }
            app.swipeUp()
        }
        family.tap()
        XCTAssertTrue(family.isSelected)
        let frustrated = app.buttons["Frustrated"]
        for _ in 0..<10 where !frustrated.isHittable { app.swipeUp() }
        XCTAssertTrue(frustrated.isHittable)
        frustrated.tap()
        XCTAssertTrue(app.buttons["Done"].isHittable)
        shot(app, "journal-tags-ax5")
        app.buttons["Done"].tap()
        let feeling = app.buttons["Feeling: Frustrated"]
        for _ in 0..<8 where !feeling.isHittable { app.swipeUp() }
        XCTAssertTrue(feeling.isHittable)
        XCTAssertTrue(app.buttons["Context: Family"].exists)
        shot(app, "journal-card-ax5")
    }
    func testLongEntryAtLargestTextKeepsTagActionsAndFullWords() throws {
        continueAfterFailure = false
        let app = launchGuest(fresh: true,
                              ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"])
        let text = Array(repeating: "I wanted more time to explain my point.", count: 12).joined(separator: " ")
        let editor = app.textViews["Your words"]
        XCTAssertTrue(editor.waitForExistence(timeout: 15))
        editor.tap(); editor.typeText(text)
        XCTAssertTrue(app.buttons["Save"].isHittable)
        app.buttons["Save"].tap()
        XCTAssertTrue(app.buttons["Not now"].waitForExistence(timeout: 10))
        app.buttons["Not now"].tap()
        let preview = app.staticTexts.containing(NSPredicate(format: "label BEGINSWITH %@", "I wanted more time")).firstMatch
        XCTAssertLessThan(preview.frame.height, app.frame.height * 0.75, "history is a preview; the full entry belongs in detail")
        let context = app.buttons["Add context"]
        for _ in 0..<6 where !context.isHittable { app.swipeUp() }
        XCTAssertTrue(context.isHittable, "a long history preview must not bury the tag actions")
        shot(app, "journal-long-entry-ax5")
        context.tap(); app.buttons["Study"].tap(); app.buttons["Done"].tap()
        let row = app.staticTexts.containing(NSPredicate(format: "label BEGINSWITH %@", "I wanted more time")).firstMatch
        for _ in 0..<6 where !row.isHittable { app.swipeDown() }
        row.tap()
        app.buttons["Edit"].tap()
        XCTAssertEqual(app.textViews["Your words"].value as? String, text, "preview truncation must never truncate saved words")
    }

}
