import XCTest

final class GuestPolishUITests: XCTestCase {
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

    func testPinguArtScreens() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.terminate(); app.launchArguments = ["-CircleUResetGuestData", "-circleu.guest.welcomeSeen.v1", "YES", "-CircleUGuestMode", "-CircleUGuidedSuggestions", "YES"]; app.launch()
        app.tabBars.buttons["Today"].tap()
        XCTAssertTrue(app.textViews["Your words"].waitForExistence(timeout: 10), "Today opens straight to writing")
        XCTAssertTrue(app.buttons["Start dictation"].exists, "with the big microphone")
        shot(app, "u1-today"); audit(app, "today")
        app.buttons["Settings"].tap()
        let avatar = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Your Pingu")).firstMatch
        XCTAssertTrue(avatar.waitForExistence(timeout: 10))
        avatar.tap()
        XCTAssertTrue(app.navigationBars["Choose your Pingu"].waitForExistence(timeout: 5))
        shot(app, "u2-picker"); audit(app, "picker")
        app.buttons["Pingu with a warm drink"].tap()
        app.buttons["Done"].tap()
        XCTAssertTrue(app.buttons["Your Pingu: Pingu with a warm drink"].waitForExistence(timeout: 5))
        shot(app, "u3-pingu-changed")
        app.navigationBars.buttons.element(boundBy: 0).tap()

        let editor = app.textViews["Your words"]; XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.tap(); editor.typeText("I felt stressed before the group meeting")
        app.buttons["Save"].tap()
        XCTAssertTrue(has(app, "Saved"), "saved moment")
        shot(app, "u5-saved")
        app.buttons["Reflect on it"].tap()
        XCTAssertTrue(has(app, "Guided prompts", 10))
        shot(app, "u4-review")
        app.buttons["Save reflection"].tap()
        let row = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "group meeting")).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5))
        row.tap()
        XCTAssertTrue(app.images["Reflection"].waitForExistence(timeout: 5), "the reflection icon")
        shot(app, "u6-entry"); audit(app, "entry")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        let search = app.searchFields["Search your journal"]
        if !search.exists { app.swipeDown() }
        search.tap(); search.typeText("zzqx")
        XCTAssertTrue(has(app, "No entries match “zzqx”."))
        shot(app, "u7-no-results")
        search.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 10))
        let dismiss = app.buttons.matching(NSPredicate(format: "label IN %@", ["Cancel", "Close", "Done"])).firstMatch
        if dismiss.exists { dismiss.tap() }

        app.tabBars.buttons["Practice"].tap()
        app.buttons["Practice a message"].tap()
        let wording = app.textViews["Your wording"]; XCTAssertTrue(wording.waitForExistence(timeout: 5))
        wording.tap(); wording.typeText("Could we talk about the slides?")
        app.buttons["Save"].tap()
        XCTAssertTrue(has(app, "Saved · not sent"))
        shot(app, "u8-message-saved")
        app.buttons["Back"].tap()

        app.tabBars.buttons["Today"].tap()
        XCTAssertTrue(app.textViews["Your words"].waitForExistence(timeout: 5), "Today is back at its start, not a blank screen")
        app.buttons["Settings"].tap()
        // The "Your Pingu" caption is hidden from VoiceOver; the avatar button says it.
        XCTAssertTrue(app.buttons["Kept on this iPhone"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Your Pingu")).firstMatch.exists)
        shot(app, "u9-settings"); audit(app, "settings")
        app.swipeUp(); sleep(1); shot(app, "u9b-settings-lower")
        attach(findings.joined(separator: "\n"), "polish-audit.txt")
    }
}
