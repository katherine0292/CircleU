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

    func testCaptureShowcaseScreens() throws {
        continueAfterFailure = false
        // The app seeds three dated, tagged entries (today, two and four days ago) at launch.
        let app = launchGuest(fresh: true, ["-CircleUGuidedSuggestions", "YES", "-CircleUSeedShowcase", "YES"])
        app.tabBars.buttons["Journal"].tap()
        XCTAssertTrue(has(app, "A quiet walk helped me slow down", 10))
        XCTAssertTrue(has(app, "Talked with my sister"))
        XCTAssertTrue(app.buttons["Context: Family"].exists && app.buttons["Feeling: Calm"].exists, "seeded tags")
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
