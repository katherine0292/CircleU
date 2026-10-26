import XCTest

final class GuestFlowUITests: XCTestCase {
    var findings: [String] = []

    func launch(fresh: Bool = false) -> XCUIApplication { launchGuest(fresh: fresh) }
    func shot(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = name; add(shot)
    }
    func audit(_ app: XCUIApplication, _ screen: String) {
        try? app.performAccessibilityAudit { issue in
            self.findings.append("\(screen) | \(issue.compactDescription) | \(issue.element?.label ?? "-") | type \(issue.element?.elementType.rawValue ?? 0) | id \(issue.element?.identifier ?? "") | \(issue.element?.frame ?? .zero)"); return true
        }
    }

    func testWriteSaveRelaunchEditDiscard() throws {
        continueAfterFailure = false
        let words = "UI test moment \(Int.random(in: 1000...9999))"
        var app = launch(fresh: true)
        XCTAssertTrue(app.textViews["Your words"].waitForExistence(timeout: 15))
        audit(app, "today"); shot(app, "g1-today")
        let editor = app.textViews["Your words"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Save only my words"].isEnabled, "empty words can't be saved")
        editor.tap(); editor.typeText(words)
        audit(app, "write"); shot(app, "g2-write")
        app.buttons["Save only my words"].tap()
        XCTAssertTrue(app.staticTexts[words].waitForExistence(timeout: 5), "saved entry shown in Journal")
        audit(app, "journal"); shot(app, "g3-journal")

        app = launch() // Relaunch: the entry must still be there.
        app.tabBars.buttons["Journal"].tap()
        XCTAssertTrue(app.staticTexts[words].waitForExistence(timeout: 10), "entry survives relaunch")
        app.staticTexts[words].tap()
        XCTAssertTrue(app.buttons["Edit"].waitForExistence(timeout: 5))
        audit(app, "detail"); shot(app, "g4-detail")
        app.buttons["Edit"].tap()
        let edit = app.textViews["Your words"]
        XCTAssertTrue(edit.waitForExistence(timeout: 5))
        edit.tap()
        edit.typeText(" (edited \(words)) ")
        app.buttons["Back"].tap()
        XCTAssertTrue(app.staticTexts["Discard your changes?"].waitForExistence(timeout: 3) || app.buttons["Discard"].waitForExistence(timeout: 1), "unsaved edits ask first")
        shot(app, "g5-discard-prompt")
        app.buttons["Keep editing"].tap()
        app.buttons["Back"].tap()
        XCTAssertTrue(app.buttons["Discard"].waitForExistence(timeout: 3))
        app.buttons["Keep editing"].tap()
        XCTAssertTrue(edit.exists)
        audit(app, "edit")
        shot(app, "g5b-before-save")
        app.buttons["Save"].tap()
        sleep(2); shot(app, "g6-after-save")
        let edited = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "(edited \(words))")).firstMatch
        XCTAssertTrue(edited.waitForExistence(timeout: 5), "edit saved and shown")
        shot(app, "g6-after-edit")

        app = launch()
        app.tabBars.buttons["Journal"].tap()
        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "(edited \(words))")).firstMatch.waitForExistence(timeout: 10), "edit survives relaunch")
        attach(findings.joined(separator: "\n"), "guest-audit.txt")
    }
}
