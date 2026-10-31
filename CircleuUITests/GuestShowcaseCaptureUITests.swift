import XCTest

/// Exact screen captures for showcase material (poster, slides): a seeded Journal with three
/// tagged entries, the empty Today screen and a Practice result. Guided suggestions keep the
/// Practice capture deterministic. Not a behaviour test; the assertions only confirm each screen
/// reached the state being captured.
final class GuestShowcaseCaptureUITests: XCTestCase {
    func shot(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = name; shot.lifetime = .keepAlways; add(shot)
    }
    func has(_ app: XCUIApplication, _ text: String, _ timeout: TimeInterval = 5) -> Bool {
        app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", text)).firstMatch.waitForExistence(timeout: timeout)
    }

    private func save(_ app: XCUIApplication, _ words: String, context: String?, feeling: String?) {
        app.tabBars.buttons["Today"].tap()
        let editor = app.textViews["Your words"]
        XCTAssertTrue(editor.waitForExistence(timeout: 10))
        editor.tap(); editor.typeText(words)
        app.buttons["Save"].tap()
        XCTAssertTrue(app.buttons["Not now"].waitForExistence(timeout: 10))
        app.buttons["Not now"].tap()
        guard context != nil || feeling != nil else { return }
        XCTAssertTrue(app.buttons["Add context"].waitForExistence(timeout: 10))
        app.buttons["Add context"].tap()
        if let context { app.buttons[context].tap() }
        if let feeling { app.buttons[feeling].tap() }
        app.buttons["Done"].tap()
        if let context { XCTAssertTrue(app.buttons["Context: \(context)"].waitForExistence(timeout: 5)) }
    }

    func testCaptureShowcaseScreens() throws {
        continueAfterFailure = false
        let app = launchGuest(fresh: true, ["-CircleUGuidedSuggestions", "YES"])
        save(app, "Talked with my sister about our holiday plans.", context: "Family", feeling: nil)
        save(app, "I said no to the extra shift and felt okay about it.", context: "Work", feeling: "Calm")
        save(app, "A quiet walk helped me slow down before the group meeting.", context: nil, feeling: "Calm")
        app.tabBars.buttons["Journal"].tap()
        XCTAssertTrue(has(app, "A quiet walk helped me slow down", 10))
        // Let the Saved banner go before the capture.
        let close = app.buttons["Not now"]
        if close.waitForExistence(timeout: 2) { close.tap() }
        shot(app, "showcase-journal")

        app.tabBars.buttons["Today"].tap()
        XCTAssertTrue(app.textViews["Your words"].waitForExistence(timeout: 5))
        shot(app, "showcase-today")

        app.tabBars.buttons["Practice"].tap()
        XCTAssertTrue(app.buttons["Practice a message"].waitForExistence(timeout: 10))
        app.buttons["Practice a message"].tap()
        let wording = app.textViews["Your wording"]
        XCTAssertTrue(wording.waitForExistence(timeout: 5))
        wording.tap(); wording.typeText("Can you take a fair share of the slides before Friday?")
        app.buttons["Review wording"].tap()
        XCTAssertTrue(has(app, "Suggested wording", 10))
        shot(app, "showcase-practice")
    }
}
