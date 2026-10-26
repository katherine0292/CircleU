import XCTest

final class GuestPracticeUITests: XCTestCase {
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

    func testPracticeDirectFromEntryAndDeleteChoices() throws {
        continueAfterFailure = false
        let tag = Int.random(in: 1000...9999)
        let app = XCUIApplication()
        app.terminate(); app.launchArguments = ["-CircleUResetGuestData", "-circleu.guest.welcomeSeen.v1", "YES", "-CircleUGuestMode"]; app.launch()

        // Direct practice
        app.tabBars.buttons["Practice"].tap()
        XCTAssertTrue(app.buttons["Practice a message"].waitForExistence(timeout: 10))
        shot(app, "p1-home"); audit(app, "practice-home")
        app.buttons["Practice a message"].tap()
        XCTAssertTrue(has(app, "On its own"))
        app.buttons["Add situation"].tap() // Situation starts folded into a chip.
        let situation = app.descendants(matching: .any).matching(NSPredicate(format: "elementType == %d OR elementType == %d", XCUIElement.ElementType.textField.rawValue, XCUIElement.ElementType.textView.rawValue)).element(boundBy: 0); situation.tap(); situation.typeText("Group project \(tag)")
        let wording = app.textViews["Your wording"]; wording.tap(); wording.typeText("Can we split the slides \(tag)?")
        shot(app, "p2-compose"); audit(app, "compose")
        app.buttons["Copy"].tap()
        XCTAssertTrue(app.buttons["Copied"].waitForExistence(timeout: 3))
        XCTAssertTrue(has(app, "Copied. Not saved or sent."))
        XCTAssertTrue(app.buttons["Save"].isEnabled, "copy didn't save")
        app.buttons["Save"].tap()
        XCTAssertTrue(has(app, "Saved · not sent"))
        XCTAssertTrue(app.buttons["Copy"].exists, "Copy is the main action on a saved message")
        XCTAssertTrue(app.buttons["Edit"].exists, "Edit is a toolbar pencil")
        app.buttons["More"].tap()
        XCTAssertTrue(app.buttons["Delete message"].waitForExistence(timeout: 3), "Delete waits in the ••• menu")
        app.buttons["Delete message"].tap()
        XCTAssertTrue(app.alerts["Delete this message?"].waitForExistence(timeout: 3), "it asks first")
        app.alerts.buttons["Cancel"].tap()
        app.buttons["Copy"].tap()
        XCTAssertTrue(has(app, "Copied. Not sent."), "a saved message isn't called unsaved")
        XCTAssertFalse(has(app, "Not saved or sent.", 1))
        shot(app, "p3-saved"); audit(app, "saved")
        app.buttons["Back"].tap()
        XCTAssertTrue(has(app, "Can we split the slides \(tag)?"), "in history")
        shot(app, "p4-history")

        // From a journal entry
        app.tabBars.buttons["Today"].tap()
        let editor = app.textViews["Your words"]; XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.tap(); editor.typeText("Groupmate missed the deadline \(tag)")
        app.buttons["Save"].tap()
        let row = app.staticTexts["Groupmate missed the deadline \(tag)"]
        XCTAssertTrue(row.waitForExistence(timeout: 5)); row.tap()
        app.buttons["Practice what to say"].tap()
        XCTAssertTrue(has(app, "From: Groupmate missed the deadline"))
        let w2 = app.textViews["Your wording"]; w2.tap(); w2.typeText("Hey, can we talk about Friday \(tag)?")
        app.buttons["Save"].tap()
        XCTAssertTrue(has(app, "Saved · not sent"))
        shot(app, "p5-linked-saved")
        app.buttons["Back"].tap()
        XCTAssertTrue(has(app, "Hey, can we talk about Friday \(tag)?"), "linked message on the entry")
        shot(app, "p6-entry-with-practice"); audit(app, "entry-detail")

        // Delete the entry, keeping the message
        app.buttons["Delete entry"].tap()
        XCTAssertTrue(app.buttons["Keep message"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Delete both"].exists)
        shot(app, "p7-delete-choice")
        app.buttons["Keep message"].tap()
        XCTAssertTrue(app.navigationBars["Journal"].waitForExistence(timeout: 5), "back on Journal")
        XCTAssertFalse(app.staticTexts["Groupmate missed the deadline \(tag)"].exists)
        app.tabBars.buttons["Practice"].tap()
        XCTAssertTrue(has(app, "Hey, can we talk about Friday \(tag)?"), "kept")
        shot(app, "p8-kept-on-its-own")
        attach(findings.joined(separator: "\n"), "practice-audit.txt")
    }
}
