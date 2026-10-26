import XCTest

/// Empty and first-run states from docs/product/user-stories.md (W1.1, W1.2, W1.5, J3.3, P2.1, S1.1, S4.2, S4.3).
final class GuestStatesUITests: XCTestCase {

    func has(_ app: XCUIApplication, _ text: String, _ timeout: TimeInterval = 5) -> Bool {
        app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", text)).firstMatch.waitForExistence(timeout: timeout)
    }

    func shot(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = name; shot.lifetime = .keepAlways; add(shot)
    }

    func openSettings(_ app: XCUIApplication) {
        app.tabBars.buttons["Today"].tap()
        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: 10))
        app.buttons["Settings"].tap()
    }

    func deleteAll(_ app: XCUIApplication) {
        openSettings(app)
        let delete = app.buttons["Delete all data"]
        for _ in 0..<6 where !delete.isHittable { app.swipeUp() }
        delete.tap()
        app.buttons["Delete all"].tap()
        XCTAssertTrue(has(app, "was deleted from this iPhone", 10))
        app.navigationBars.buttons.element(boundBy: 0).tap()
    }

    /// W1.2: Get started opens Today, and Welcome isn't shown on the next launch.
    func testWelcomeShowsOnlyUntilGetStarted() throws {
        continueAfterFailure = false
        var app = launchGuest(fresh: true, welcomeSeen: nil)
        XCTAssertTrue(app.buttons["Skip"].waitForExistence(timeout: 10))
        app.buttons["Skip"].tap()
        XCTAssertTrue(app.buttons["Get started"].waitForExistence(timeout: 5))
        app.buttons["Get started"].tap()
        XCTAssertTrue(app.textViews["Your words"].waitForExistence(timeout: 10), "Today opens")
        app = launchGuest(fresh: false, welcomeSeen: nil) // No override: the app's own saved choice decides.
        XCTAssertTrue(app.textViews["Your words"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.buttons["Get started"].exists, "Welcome isn't shown again")
    }

    /// Waits until the element is inside the window, not just in the tree: every Welcome page is built
    /// at once, and the others sit off to the side. (Text in a scroll view isn't reported as hittable.)
    func onScreen(_ app: XCUIApplication, _ element: XCUIElement, _ timeout: TimeInterval = 5) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            if element.exists, !element.frame.isEmpty, app.windows.firstMatch.frame.contains(element.frame) { return true }
            usleep(200_000)
        } while Date() < deadline
        return false
    }

    func onPage(_ app: XCUIApplication, _ number: Int, _ title: String) -> Bool {
        let dots = app.descendants(matching: .any).matching(NSPredicate(format: "label == %@", "Page \(number) of 3")).firstMatch
        return onScreen(app, app.staticTexts[title]) && dots.waitForExistence(timeout: 5)
    }

    /// W1.1 and W1.5: three pages with Skip; swiping, Next and Skip all move the shown page, and both
    /// routes reach Get started and Log in.
    func testWelcomePagesNextAndSkip() throws {
        continueAfterFailure = false
        var app = launchGuest(fresh: true, welcomeSeen: nil)
        XCTAssertTrue(app.buttons["Skip"].waitForExistence(timeout: 10))
        XCTAssertTrue(onPage(app, 1, "Something on your mind?"))
        XCTAssertFalse(app.buttons["Get started"].exists, "Get started waits for the last page")
        shot(app, "w1-page1")
        app.swipeLeft()
        XCTAssertTrue(onPage(app, 2, "Write or talk it through"), "swiping pages forward")
        app.swipeRight()
        XCTAssertTrue(onPage(app, 1, "Something on your mind?"), "and back")
        app.buttons["Next"].tap()
        XCTAssertTrue(onPage(app, 2, "Write or talk it through"))
        XCTAssertFalse(onScreen(app, app.staticTexts["Something on your mind?"], 1), "page 1 has moved away")
        sleep(1); shot(app, "w2-page2")
        app.buttons["Next"].tap()
        XCTAssertTrue(onPage(app, 3, "Find your words"))
        XCTAssertTrue(onScreen(app, app.buttons["Get started"]))
        XCTAssertTrue(onScreen(app, app.buttons["Log in"]))
        XCTAssertFalse(app.buttons["Skip"].exists, "the last page has no Skip")
        XCTAssertFalse(app.buttons["Next"].exists)
        sleep(1); shot(app, "w3-page3")

        app = launchGuest(fresh: true, welcomeSeen: nil)
        XCTAssertTrue(app.buttons["Skip"].waitForExistence(timeout: 10))
        app.buttons["Skip"].tap()
        XCTAssertTrue(onPage(app, 3, "Find your words"), "Skip goes to the last page")
        XCTAssertTrue(onScreen(app, app.buttons["Get started"]))
        XCTAssertTrue(onScreen(app, app.buttons["Log in"]))
        XCTAssertFalse(app.buttons["Skip"].exists)
    }

    /// W1.5 at the largest text size: the scene is a short banner and both actions are reachable.
    func testWelcomeLastPageAtLargestText() throws {
        continueAfterFailure = false
        let app = launchGuest(fresh: true, welcomeSeen: nil,
                              ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"])
        XCTAssertTrue(app.buttons["Skip"].waitForExistence(timeout: 10))
        shot(app, "w1-page1-ax5")
        app.buttons["Skip"].tap()
        XCTAssertTrue(app.buttons["Get started"].waitForExistence(timeout: 5))
        sleep(1); shot(app, "w3-page3-ax5")
        XCTAssertTrue(onPage(app, 3, "Find your words"))
        XCTAssertTrue(onScreen(app, app.staticTexts["Practise what you want to say, when you’re ready."]), "the line is readable")
        XCTAssertTrue(app.buttons["Get started"].isHittable)
        XCTAssertTrue(app.buttons["Log in"].isHittable)
    }

    /// J1.1, P2.1 and J3.3: empty Journal, empty Practice, and a calendar day with nothing.
    func testEmptyJournalPracticeAndCalendarDay() throws {
        continueAfterFailure = false
        let calendar = Calendar.current, today = Date()
        let other = calendar.date(byAdding: .day, value: calendar.component(.day, from: today) == 1 ? 1 : -1, to: today)!
        let app = launchGuest(fresh: true)
        XCTAssertTrue(app.textViews["Your words"].waitForExistence(timeout: 15))
        deleteAll(app)
        app.tabBars.buttons["Journal"].tap()
        XCTAssertTrue(has(app, "Nothing saved yet.", 10))
        shot(app, "journal-empty")
        app.tabBars.buttons["Practice"].tap()
        XCTAssertTrue(has(app, "Nothing practised yet."))
        shot(app, "practice-empty")

        app.tabBars.buttons["Today"].tap()
        let editor = app.textViews["Your words"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.tap(); editor.typeText("Only entry today")
        app.buttons["Save"].tap()
        XCTAssertTrue(has(app, "Only entry today"))
        app.buttons["Show calendar"].tap()
        let day = app.buttons[other.formatted(.dateTime.day().month(.wide))]
        XCTAssertTrue(day.waitForExistence(timeout: 5))
        day.tap()
        XCTAssertTrue(has(app, "Nothing written that day."))
        shot(app, "calendar-empty-day")
    }

    /// S1.1: the privacy promise stays in words, with the detail in the "Kept on this iPhone" sheet.
    func testPrivacySummaryAndLearnMore() throws {
        continueAfterFailure = false
        let app = launchGuest(fresh: true)
        openSettings(app)
        XCTAssertTrue(has(app, "Not uploaded or synced.", 10))
        XCTAssertFalse(app.staticTexts["Restoring an older backup can bring back deleted items."].exists, "detail starts hidden")
        let chip = app.buttons["Kept on this iPhone"]
        XCTAssertTrue(chip.waitForExistence(timeout: 5))
        chip.tap()
        XCTAssertTrue(has(app, "Restoring an older backup can bring back deleted items."))
        XCTAssertTrue(has(app, "Suggestions and dictation stay here; no audio is saved."))
        XCTAssertTrue(has(app, "iCloud or computer backups of your iPhone may include your journal."))
        XCTAssertTrue(has(app, "Exports you saved elsewhere aren’t deleted here."))
        shot(app, "privacy-sheet")
        app.buttons["Done"].tap()
        XCTAssertTrue(chip.waitForExistence(timeout: 5), "back in Settings")
    }

    /// S4.2 and S4.3: the chosen Pingu is kept across launches, and opening the picker stops dictation.
    func testPinguChoiceIsKeptAndThePickerStopsDictation() throws {
        continueAfterFailure = false
        var app = launchGuest(fresh: true, ["-CircleUScriptedDictation", "Spoken before choosing"])
        let editor = app.textViews["Your words"]
        XCTAssertTrue(editor.waitForExistence(timeout: 15))
        app.buttons["Start dictation"].tap()
        XCTAssertTrue(app.buttons["Stop dictation"].waitForExistence(timeout: 5), "listening")
        let avatar = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Your Pingu")).firstMatch
        avatar.tap()
        XCTAssertTrue(app.navigationBars["Choose your Pingu"].waitForExistence(timeout: 5))
        app.buttons["Pingu reading"].tap()
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["Start dictation"].waitForExistence(timeout: 5), "dictation stopped")
        XCTAssertFalse(app.buttons["Stop dictation"].exists)
        XCTAssertTrue((editor.value as? String ?? "").contains("Spoken before choosing"), "the words so far are kept")

        app = launchGuest(fresh: false)
        XCTAssertTrue(app.buttons["Your Pingu: Pingu reading"].waitForExistence(timeout: 10), "kept across launches")
        shot(app, "pingu-kept")
    }
}
