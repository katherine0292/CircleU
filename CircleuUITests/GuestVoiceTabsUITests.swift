import XCTest

final class GuestVoiceTabsUITests: XCTestCase {
    var findings: [String] = []

    func shot(_ app: XCUIApplication, _ name: String) {
        let shot = XCTAttachment(screenshot: app.screenshot()); shot.name = name; shot.lifetime = .keepAlways; add(shot)
    }
    func audit(_ app: XCUIApplication, _ screen: String) {
        try? app.performAccessibilityAudit { issue in
            self.findings.append("\(screen) | \(issue.compactDescription) | \(issue.element?.label ?? "-") | \(issue.element?.frame ?? .zero)"); return true
        }
    }

    func testTabsPracticeAndDictationDenied() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.resetAuthorizationStatus(for: .microphone) // Ask again, so the test denies it itself.
        // Simulators have no on-device speech model; without this they report dictation unavailable before asking.
        app.terminate(); app.launchArguments = ["-CircleUResetGuestData", "-circleu.guest.welcomeSeen.v1", "YES", "-CircleUGuestMode",
                                                "-CircleUAssumeOnDeviceSpeech", "YES"]; app.launch()
        XCTAssertTrue(app.textViews["Your words"].waitForExistence(timeout: 15))
        for tab in ["Today", "Journal", "Practice"] { XCTAssertTrue(app.tabBars.buttons[tab].exists, tab) }
        shot(app, "v1-today")
        app.tabBars.buttons["Journal"].tap(); sleep(1); shot(app, "v2-journal")
        app.tabBars.buttons["Practice"].tap()
        XCTAssertTrue(app.buttons["Practice a message"].waitForExistence(timeout: 5))
        audit(app, "practice"); shot(app, "v3-practice")
        app.tabBars.buttons["Today"].tap()
        let mic = app.buttons["Start dictation"]
        XCTAssertTrue(mic.waitForExistence(timeout: 5))
        audit(app, "write"); shot(app, "v4-write")
        mic.tap()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        var prompts: [String] = []
        for _ in 0..<2 {
            let deny = springboard.buttons["Don’t Allow"]
            if deny.waitForExistence(timeout: 4) {
                prompts.append(springboard.alerts.firstMatch.label)
                shot(app, "v5-prompt-\(prompts.count)"); deny.tap()
            }
        }
        sleep(1); shot(app, "v6-after-deny")
        // Speech access can't be reset from a test, so an earlier run's denial may skip the prompts.
        // The message and Open Settings below appear only when access is denied.
        let message = app.staticTexts["Dictation needs microphone and speech recognition access. Turn them on in Settings, or keep typing."]
        XCTAssertTrue(message.waitForExistence(timeout: 5), "the denial message is shown")
        XCTAssertTrue(app.buttons["Open Settings"].exists, "with a way to Settings")
        findings.append("prompts: \(prompts) | message: \(message.label) | settings: \(app.buttons["Open Settings"].exists)")
        let editor = app.textViews["Your words"]
        editor.tap(); editor.typeText("Typed after denial")
        XCTAssertTrue(app.buttons["Save"].isEnabled)
        shot(app, "v7-typed")
        attach(findings.joined(separator: "\n"), "voice-audit.txt")
    }

    func testSaveTwoEntries() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.terminate(); app.launchArguments = ["-CircleUResetGuestData", "-circleu.guest.welcomeSeen.v1", "YES", "-CircleUGuestMode"]; app.launch()
        for i in 1...2 {
            app.tabBars.buttons["Today"].tap()
            let start = app.textViews["Your words"]
            XCTAssertTrue(start.waitForExistence(timeout: 10), "start \(i)")
            start.tap()
            let editor = app.textViews["Your words"]
            XCTAssertTrue(editor.waitForExistence(timeout: 5), "editor \(i)")
            editor.tap(); editor.typeText("Entry number \(i) \(Int.random(in: 1000...9999))")
            shot(app, "two-\(i)-write")
            let save = app.buttons["Save"]
            XCTAssertTrue(save.isEnabled, "save enabled \(i)")
            save.tap()
            sleep(2); shot(app, "two-\(i)-after")
            XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label BEGINSWITH %@", "Entry number \(i)")).firstMatch.waitForExistence(timeout: 5), "entry \(i) in journal")
        }
    }

    func testThreeEntriesWithAndWithoutVoiceSurviveRelaunch() throws {
        continueAfterFailure = false
        let tag = Int.random(in: 1000...9999)
        var app = XCUIApplication()
        app.terminate(); app.launchArguments = ["-CircleUResetGuestData", "-circleu.guest.welcomeSeen.v1", "YES", "-CircleUGuestMode", "-CircleUScriptedDictation", "Spoken words \(tag)"]; app.launch()
        let expected = ["Typed one \(tag)", "Spoken words \(tag)", "Spoken words \(tag) plus typing"]
        for (i, mode) in ["type", "voice", "voice+type"].enumerated() {
            app.tabBars.buttons["Today"].tap()
            let start = app.textViews["Your words"]
            XCTAssertTrue(start.waitForExistence(timeout: 10), "start \(i)")
            start.tap()
            let editor = app.textViews["Your words"]
            XCTAssertTrue(editor.waitForExistence(timeout: 5))
            if mode == "type" { editor.tap(); editor.typeText(expected[0]) }
            if mode.hasPrefix("voice") {
                app.buttons["Start dictation"].tap()
                let stop = app.buttons["Stop dictation"]
                XCTAssertTrue(stop.waitForExistence(timeout: 5), "listening \(i)")
                shot(app, "three-\(i)-listening")
                if mode == "voice+type" {
                    stop.tap()
                    XCTAssertTrue(app.buttons["Start dictation"].waitForExistence(timeout: 5), "stopped \(i)")
                } // Plain "voice" taps Save while still listening.
            }
            if mode == "voice+type" { editor.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.9)).tap(); app.typeText(" plus typing") }
            shot(app, "three-\(i)-before-save")
            let save = app.buttons["Save"]
            XCTAssertTrue(save.isEnabled, "save enabled \(i): editor=\(editor.value ?? "")")
            save.tap()
            XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", expected[i])).firstMatch.waitForExistence(timeout: 5), "entry \(i) listed")
            shot(app, "three-\(i)-journal")
        }
        app.terminate(); app = XCUIApplication()
        app.launchArguments = ["-circleu.guest.welcomeSeen.v1", "YES", "-CircleUGuestMode"]; app.launch()
        app.tabBars.buttons["Journal"].tap()
        func rows(_ text: String) -> XCUIElementQuery { app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", text)) }
        XCTAssertTrue(rows(expected[2]).firstMatch.waitForExistence(timeout: 10), "after relaunch: \(expected[2])")
        XCTAssertEqual(rows(expected[1]).count, 2, "the spoken-only entry and the spoken-plus-typing entry are both kept")
        XCTAssertEqual(rows(expected[0]).count, 1, "the typed entry is kept once")
        shot(app, "three-relaunch")
    }
}
