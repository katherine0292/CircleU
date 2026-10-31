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

    /// Message-first Practice: review the words, then keep them, to reach the "Your wording" screen.
    func reviewAndKeepWording(_ app: XCUIApplication) {
        app.buttons["Review wording"].tap()
        let keep = app.buttons["Keep my wording"]
        XCTAssertTrue(keep.waitForExistence(timeout: 10), "the result screen offers to keep my words")
        for _ in 0..<4 where !keep.isHittable { app.swipeUp() }
        keep.tap()
        XCTAssertTrue(app.buttons["Save"].waitForExistence(timeout: 10), "back on my wording")
    }

    /// Skips tests that contact the real Firebase Dev project unless they were asked for:
    /// `TEST_RUNNER_CIRCLEU_LIVE_DEV=1 xcodebuild test …`.
    func requireLiveDev() throws {
        guard ProcessInfo.processInfo.environment["CIRCLEU_LIVE_DEV"] == "1" else {
            throw XCTSkip("Contacts Firebase Dev; set TEST_RUNNER_CIRCLEU_LIVE_DEV=1 to run it.")
        }
    }
}
