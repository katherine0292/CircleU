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

        app.tabBars.buttons["Write"].tap()
        XCTAssertTrue(app.textViews["Your words"].waitForExistence(timeout: 5))
        shot(app, "showcase-today")

        startTalk(app, saying: "Can you take a fair share of the slides before Friday?")
        shot(app, "showcase-practice")
    }
}
