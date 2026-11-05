import XCTest

// Shared helpers for the guest journal UI tests. The app's Debug build opens the guest journal with
// the hidden `-CircleUGuestMode` launch argument; run these with the CircleuUITests scheme.
extension XCTestCase {
    /// Keeps text output (accessibility audit findings, labels) with the test result.
    func attach(_ text: String, _ name: String) {
        guard !text.isEmpty else { return }
        let attachment = XCTAttachment(string: text)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Launches the guest journal. `fresh` starts from an empty journal (no entries, drafts or
    /// chosen Pingu); a relaunch inside a test passes `fresh: false` to keep that test's own data.
    func launchGuest(fresh: Bool, welcomeSeen: Bool? = true, _ extra: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.terminate()
        var arguments = ["-CircleUGuestMode"] + (fresh ? ["-CircleUResetGuestData"] : [])
        if let welcomeSeen { arguments += ["-circleu.guest.welcomeSeen.v1", welcomeSeen ? "YES" : "NO"] }
        app.launchArguments = arguments + extra
        app.launch()
        return app
    }

    /// Talk: from the Talk tab, start a conversation, accept the scene, and send my words.
    /// Waits for the "Say it like this" card.
    func startTalk(_ app: XCUIApplication, saying words: String, fromTalkTab: Bool = true) {
        if fromTalkTab {
            app.tabBars.buttons["Talk"].tap()
            let start = app.buttons["Start a conversation"]
            XCTAssertTrue(start.waitForExistence(timeout: 10))
            for _ in 0..<6 where !start.isHittable { app.swipeUp() }
            start.tap()
        }
        let begin = app.buttons["Start"]
        XCTAssertTrue(begin.waitForExistence(timeout: 5), "the scene card opens first")
        begin.tap()
        sendInTalk(app, words)
        XCTAssertTrue(app.staticTexts["SAY IT LIKE THIS"].waitForExistence(timeout: 15), "a suggestion arrives")
    }

    /// Types into the Talk composer (mine or theirs, whichever is selected) and sends.
    func sendInTalk(_ app: XCUIApplication, _ words: String) {
        let field = talkField(app)
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap(); field.typeText(words)
        app.buttons["Send"].tap()
    }

    func talkField(_ app: XCUIApplication) -> XCUIElement {
        let labels = ["What you want to say", "Their reply"]
        return app.descendants(matching: .any).matching(NSPredicate(format: "label IN %@ AND (elementType == %d OR elementType == %d)",
            labels, XCUIElement.ElementType.textField.rawValue, XCUIElement.ElementType.textView.rawValue)).firstMatch
    }

    /// Copies the live suggestion and marks it said.
    func sayIt(_ app: XCUIApplication) {
        let copy = app.buttons["Copy"].firstMatch
        XCTAssertTrue(copy.waitForExistence(timeout: 10))
        copy.tap()
        XCTAssertTrue(app.buttons["Copied"].waitForExistence(timeout: 3))
        app.buttons["I said it ✓"].tap()
        XCTAssertTrue(app.staticTexts["YOU SAID ✓"].waitForExistence(timeout: 5))
    }

    /// Skips tests that contact the real Firebase Dev project unless they were asked for:
    /// `TEST_RUNNER_CIRCLEU_LIVE_DEV=1 xcodebuild test …`.
    func requireLiveDev() throws {
        guard ProcessInfo.processInfo.environment["CIRCLEU_LIVE_DEV"] == "1" else {
            throw XCTSkip("Contacts Firebase Dev; set TEST_RUNNER_CIRCLEU_LIVE_DEV=1 to run it.")
        }
    }
}
