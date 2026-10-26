import XCTest

final class GuestImportUITests: XCTestCase {
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
        app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch.waitForExistence(timeout: timeout)
    }
    func fill(_ app: XCUIApplication, email: String, password: String) {
        let emailField = app.textFields["Email"]; XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        emailField.tap(); emailField.typeText(email)
        let passwordField = app.secureTextFields["Password"]; passwordField.tap(); passwordField.typeText(password)
    }

    /// Fake account (Debug launch argument); invented test credentials only.
    func testWelcomeLogInPreviewCopySignedOutAndDelete() throws {
        continueAfterFailure = false
        var app = launchGuest(fresh: true, welcomeSeen: nil, ["-CircleUFakeAccount", "YES"])
        XCTAssertTrue(app.buttons["Get started"].waitForExistence(timeout: 10))
        shot(app, "s1-welcome")
        app.buttons["Log in"].tap()
        XCTAssertTrue(has(app, "Nothing uploaded"))
        XCTAssertTrue(has(app, "Signed out after"))
        XCTAssertTrue(app.buttons["Continue without logging in"].exists)
        shot(app, "s2-login"); audit(app, "login")
        app.buttons["What logging in does"].tap()
        XCTAssertTrue(has(app, "Accounts can’t be created here"))
        shot(app, "s2b-login-info")
        app.buttons["Done"].tap()
        fill(app, email: "pingu.test@example.com", password: "wrong-password")
        app.buttons["Log in"].firstMatch.tap()
        XCTAssertTrue(has(app, "Check your email and password"), "generic message")
        app.secureTextFields["Password"].tap(); app.secureTextFields["Password"].typeText("test-password-1")
        app.buttons["Log in"].firstMatch.tap()
        let copy = app.buttons["Copy into this journal"]
        XCTAssertTrue(copy.waitForExistence(timeout: 10), "a fresh journal has nothing copied yet")
        XCTAssertTrue(has(app, "I told my friend I needed space"))
        XCTAssertTrue(app.buttons["What isn’t copied"].exists)
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Left out")).firstMatch.tap()
        XCTAssertTrue(has(app, "couldn’t be read"), "the broken record is reported")
        shot(app, "s3-preview"); audit(app, "preview")
        copy.tap()
        XCTAssertTrue(has(app, "Signed out", 10))
        shot(app, "s4-done")
        app.buttons["Continue"].tap()
        XCTAssertTrue(app.textViews["Your words"].waitForExistence(timeout: 10), "Continue opens Today")

        // Delete my account (fake): needs a fresh log in, keeps local entries.
        app = XCUIApplication()
        app.terminate()
        app.launchArguments = ["-circleu.guest.welcomeSeen.v1", "YES", "-CircleUFakeAccount", "YES", "-CircleUGuestMode"]
        app.launch()
        app.tabBars.buttons["Today"].tap()
        XCTAssertTrue(app.buttons["Settings"].waitForExistence(timeout: 10))
        app.buttons["Settings"].tap()
        let delete = app.buttons["Delete my account"]
        for _ in 0..<6 where !delete.isHittable { app.swipeUp() }
        delete.tap()
        fill(app, email: "pingu.test@example.com", password: "test-password-1")
        XCTAssertTrue(has(app, "Will be deleted"), "nothing reads as deleted before it is")
        shot(app, "s5-delete")
        app.buttons["Delete my account"].firstMatch.tap()
        app.alerts.buttons["Delete"].tap()
        XCTAssertTrue(has(app, "were deleted", 10))
        XCTAssertTrue(has(app, "Your entries on this iPhone are still here"))
        shot(app, "s6-deleted")
        attach(findings.joined(separator: "\n"), "signin-audit.txt")
    }

    /// Real Firebase Dev with an invented account that doesn't exist: proves the configuration
    /// works from the app and that the answer is generic. Sends one sign-in request.
    func testRealDevRejectsAnInventedAccountGenerically() throws {
        try requireLiveDev()
        let app = launchGuest(fresh: true, welcomeSeen: nil)
        XCTAssertTrue(app.buttons["Log in"].waitForExistence(timeout: 10))
        app.buttons["Log in"].tap()
        fill(app, email: "nonexistent-probe-7c1e@example.invalid", password: "not-a-real-password")
        app.buttons["Log in"].firstMatch.tap()
        let generic = has(app, "Check your email and password", 20)
        shot(app, "s7-real-dev")
        let texts = app.staticTexts.allElementsBoundByIndex.map(\.label).filter { $0.contains("isn’t available") || $0.contains("went wrong") || $0.contains("offline") }
        attach(texts.joined(separator: " | "), "real-dev.txt")
        XCTAssertTrue(generic, "Dev configuration works and the answer doesn't reveal whether the account exists")
    }
}
