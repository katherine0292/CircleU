import XCTest

final class GuestFindControlUITests: XCTestCase {
    var findings: [String] = []
    func shot(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = name; shot.lifetime = .keepAlways; add(shot)
    }
    func audit(_ app: XCUIApplication, _ screen: String) {
        try? app.performAccessibilityAudit { issue in
            self.findings.append("\(screen) | \(issue.compactDescription) | \(issue.element?.label ?? "-") | \(issue.element?.frame ?? .zero)"); return true
        }
    }
    func has(_ app: XCUIApplication, _ text: String, _ timeout: TimeInterval = 5) -> Bool {
        app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", text)).firstMatch.waitForExistence(timeout: timeout)
    }
    func launch(fresh: Bool = false) -> XCUIApplication { launchGuest(fresh: fresh) }

    func testSearchCalendarDraftExportAndDeleteAll() throws {
        continueAfterFailure = false
        let tag = Int.random(in: 1000...9999)
        var app = launch(fresh: true)
        for words in ["Alpha moment \(tag)", "Beta moment \(tag)"] {
            app.tabBars.buttons["Today"].tap()
            XCTAssertTrue(app.textViews["Your words"].waitForExistence(timeout: 10))
            let editor = app.textViews["Your words"]; XCTAssertTrue(editor.waitForExistence(timeout: 5))
            editor.tap(); editor.typeText(words)
            app.buttons["Save"].tap()
            XCTAssertTrue(has(app, words))
            app.buttons["Not now"].tap() // The reflection offer; keeps the calendar's rows on screen.
        }
        // Search
        let search = app.searchFields["Search your journal"]
        if !search.exists { app.swipeDown() }
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap(); search.typeText("beta moment \(tag)")
        XCTAssertTrue(has(app, "Beta moment \(tag)"))
        XCTAssertFalse(app.staticTexts["Alpha moment \(tag)"].exists, "filtered")
        shot(app, "f1-search")
        let dismiss = app.buttons.matching(NSPredicate(format: "label IN %@", ["Cancel", "Close", "Done"])).firstMatch
        if dismiss.exists { dismiss.tap() } else {
            findings.append("search buttons: \(app.buttons.allElementsBoundByIndex.prefix(8).map(\.label))")
        }
        // Calendar
        app.buttons["Show calendar"].tap()
        XCTAssertTrue(app.buttons["Previous month"].waitForExistence(timeout: 3))
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: Date())!.formatted(.dateTime.month(.wide).year())
        XCTAssertFalse(app.staticTexts[lastMonth].exists)
        app.buttons["Previous month"].tap()
        XCTAssertTrue(app.staticTexts[lastMonth].waitForExistence(timeout: 3), "moved to last month")
        app.buttons["Go to today"].tap()
        XCTAssertFalse(app.staticTexts[lastMonth].waitForExistence(timeout: 2), "back to this month")
        XCTAssertTrue(has(app, "Showing"))
        XCTAssertTrue(has(app, "Alpha moment \(tag)"))
        shot(app, "f2-calendar"); audit(app, "calendar")
        app.buttons["Show all"].tap()
        app.buttons["Hide calendar"].tap()

        // Practice draft survives relaunch
        app.tabBars.buttons["Practice"].tap()
        app.buttons["Practice a message"].tap()
        let wording = app.textViews["Your wording"]; XCTAssertTrue(wording.waitForExistence(timeout: 5))
        wording.tap(); wording.typeText("Draft wording \(tag)")
        app.buttons["Back"].tap()
        XCTAssertTrue(app.buttons["Continue your draft"].waitForExistence(timeout: 5))
        app = launch()
        app.tabBars.buttons["Practice"].tap()
        XCTAssertTrue(app.buttons["Continue your draft"].waitForExistence(timeout: 10), "kept across relaunch")
        app.buttons["Continue your draft"].tap()
        XCTAssertTrue((app.textViews["Your wording"].value as? String ?? "").contains("Draft wording \(tag)"))
        app.buttons["Back"].tap()

        // Settings: export and delete all
        app.tabBars.buttons["Today"].tap()
        app.buttons["Settings"].tap()
        XCTAssertTrue(has(app, "Kept on this iPhone"))
        shot(app, "f3-settings"); audit(app, "settings")
        app.buttons["Export my data"].tap()
        let close = app.buttons["Close"].firstMatch
        XCTAssertTrue(close.waitForExistence(timeout: 10) || app.otherElements["ActivityListView"].waitForExistence(timeout: 2), "share sheet")
        shot(app, "f4-share")
        if close.exists { close.tap() } else { app.swipeDown() }
        app.buttons["Delete all data"].tap()
        XCTAssertTrue(app.buttons["Delete all"].waitForExistence(timeout: 3))
        shot(app, "f5-delete-confirm")
        app.buttons["Delete all"].tap()
        sleep(3); shot(app, "f6-after-delete")
        let texts = app.staticTexts.allElementsBoundByIndex.map(\.label).filter { $0.lowercased().contains("delet") }
        attach(texts.joined(separator: " | "), "delete-texts.txt")
        XCTAssertTrue(has(app, "was deleted from this iPhone", 10))
        app = launch()
        app.tabBars.buttons["Journal"].tap()
        XCTAssertTrue(has(app, "Nothing saved yet.", 10), "nothing comes back after relaunch")
        app.tabBars.buttons["Practice"].tap()
        XCTAssertFalse(app.buttons["Continue your draft"].waitForExistence(timeout: 2))
        attach(findings.joined(separator: "\n"), "find-audit.txt")
    }
}
