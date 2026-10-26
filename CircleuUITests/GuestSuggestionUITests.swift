import XCTest

final class GuestSuggestionUITests: XCTestCase {
    var findings: [String] = []
    func shot(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = name; add(shot)
    }
    func audit(_ app: XCUIApplication, _ screen: String) {
        try? app.performAccessibilityAudit { issue in
            self.findings.append("\(screen) | \(issue.compactDescription) | \(issue.element?.label ?? "-") | \(issue.element?.frame ?? .zero)"); return true
        }
    }
    func has(_ app: XCUIApplication, _ text: String, _ timeout: TimeInterval = 5) -> Bool {
        app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", text)).firstMatch.waitForExistence(timeout: timeout)
    }

    func testReflectionNextStepAndPracticeSuggestions() throws {
        continueAfterFailure = false
        let tag = Int.random(in: 1000...9999)
        let app = XCUIApplication()
        app.terminate(); app.launchArguments = ["-CircleUResetGuestData", "-circleu.guest.welcomeSeen.v1", "YES", "-CircleUGuestMode", "-CircleUGuidedSuggestions", "YES"]; app.launch()
        app.tabBars.buttons["Today"].tap()
        XCTAssertTrue(app.textViews["Your words"].waitForExistence(timeout: 10))
        let editor = app.textViews["Your words"]; XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.tap(); editor.typeText("I felt stressed when my groupmate missed the deadline \(tag)")
        app.buttons["Get a suggestion"].tap()
        XCTAssertTrue(has(app, "Guided prompts, not a personal analysis", 10))
        XCTAssertTrue(app.buttons["Save with reflection"].exists)
        XCTAssertTrue(app.buttons["Save only my words"].exists)
        shot(app, "s1-review"); audit(app, "review")
        let add = app.buttons["Add this step"]
        for _ in 0..<4 where !add.isHittable { app.swipeUp() }
        add.tap()
        app.buttons["Save with reflection"].tap()
        let row = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "deadline \(tag)")).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5)); row.tap()
        XCTAssertTrue(has(app, "Reflection"))
        XCTAssertTrue(has(app, "Next step"))
        app.swipeUp()
        shot(app, "s2-entry"); audit(app, "entry")
        app.buttons["Mark done"].tap()
        XCTAssertTrue(app.buttons["Mark not done"].waitForExistence(timeout: 5), "reversible")
        shot(app, "s3-done")

        app.tabBars.buttons["Practice"].tap()
        app.buttons["Practice a message"].tap()
        let situation = app.descendants(matching: .any).matching(NSPredicate(format: "elementType == %d OR elementType == %d", XCUIElement.ElementType.textField.rawValue, XCUIElement.ElementType.textView.rawValue)).element(boundBy: 0)
        situation.tap(); situation.typeText("The group project")
        app.buttons["Get a suggestion"].tap()
        XCTAssertTrue(app.buttons["Use the clear option"].waitForExistence(timeout: 10))
        shot(app, "s4-options"); audit(app, "options")
        app.buttons["Use the clear option"].tap()
        let wording = app.textViews["Your wording"]
        XCTAssertTrue((wording.value as? String ?? "").contains("the group project"), "option in the wording box")
        app.buttons["Undo suggestion"].tap()
        XCTAssertEqual((wording.value as? String ?? ""), "", "undone")
        attach(findings.joined(separator: "\n"), "suggestion-audit.txt")
    }
}
