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

    @MainActor
    func testGuestStartupDoesNotConstructCloudServices() {
        var calls: [String] = []
        let bootstrap = AppBootstrap(configureFirebase: { calls.append("firebase") },
                                     installAnalytics: { calls.append("analytics") })
        bootstrap.run(for: AppStartup.resolve(arguments: ["Circleu", AppStartup.launchArgument], isDebugBuild: true))
        XCTAssertEqual(calls, [], "guest startup must not configure Firebase or analytics")
    }

    @MainActor
    func testExistingStartupStillConfiguresFirebaseThenAnalytics() {
        var calls: [String] = []
        let bootstrap = AppBootstrap(configureFirebase: { calls.append("firebase") },
                                     installAnalytics: { calls.append("analytics") })
        bootstrap.run(for: AppStartup.resolve(arguments: ["Circleu"], isDebugBuild: true))
        XCTAssertEqual(calls, ["firebase", "analytics"], "the default path keeps its original order")
    }

    func testOpenFailureNeverReadsAsAnEmptyJournal() {
        XCTAssertEqual(GuestJournalViewModel.openFailureMessage(for: GuestJournalError.storeMissing),
                       "Your saved journal is missing from this phone. Nothing new has been created.")
        XCTAssertEqual(GuestJournalViewModel.openFailureMessage(for: GuestJournalError.storeUnavailable("x")),
                       GuestJournalViewModel.loadFailedMessage)
    }
}
