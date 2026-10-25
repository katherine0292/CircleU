import XCTest
@testable import Circleu

final class AppStartupTests: XCTestCase {
    func testDefaultStartsTheExistingAppWithFirebase() {
        let startup = AppStartup.resolve(arguments: ["Circleu"], isDebugBuild: true)
        XCTAssertEqual(startup, .existingApp)
        XCTAssertTrue(startup.configuresFirebase, "the default path must stay exactly as before")
    }

    func testReleaseBuildsIgnoreTheHiddenSwitch() {
        let startup = AppStartup.resolve(arguments: ["Circleu", AppStartup.launchArgument], isDebugBuild: false)
        XCTAssertEqual(startup, .existingApp, "TestFlight and App Store builds can't open the guest journal")
    }

    func testDebugSwitchOpensGuestJournalWithoutFirebase() {
        let startup = AppStartup.resolve(arguments: ["Circleu", AppStartup.launchArgument], isDebugBuild: true)
        XCTAssertEqual(startup, .guestJournal)
        XCTAssertFalse(startup.configuresFirebase)
    }

    func testThisTestRunStartsTheExistingApp() {
        XCTAssertEqual(AppStartup.resolve(), .existingApp)
    }

    func testOpenFailureNeverReadsAsAnEmptyJournal() {
        XCTAssertEqual(GuestJournalViewModel.openFailureMessage(for: GuestJournalError.storeMissing),
                       "Your saved journal is missing from this phone. Nothing new has been created.")
        XCTAssertEqual(GuestJournalViewModel.openFailureMessage(for: GuestJournalError.storeUnavailable("x")),
                       GuestJournalViewModel.loadFailedMessage)
    }
}
