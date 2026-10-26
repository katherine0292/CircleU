import XCTest

// Shared helpers for the guest journal UI tests. The app's Debug build opens the guest journal with
// the hidden `-CircleUGuestMode` launch argument; run these with the CircleuUITests scheme.
extension XCTestCase {
    /// Keeps text output (accessibility audit findings, labels) with the test result.
    func attach(_ text: String, _ name: String) {
        guard !text.isEmpty else { return }
        let attachment = XCTAttachment(string: text)
        attachment.name = name
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

    /// Skips tests that contact the real Firebase Dev project unless they were asked for:
    /// `TEST_RUNNER_CIRCLEU_LIVE_DEV=1 xcodebuild test …`.
    func requireLiveDev() throws {
        guard ProcessInfo.processInfo.environment["CIRCLEU_LIVE_DEV"] == "1" else {
            throw XCTSkip("Contacts Firebase Dev; set TEST_RUNNER_CIRCLEU_LIVE_DEV=1 to run it.")
        }
    }
}
