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
    func testGuestStartupDoesNotConstructCloudServices() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("GuestStartup-\(UUID())")
        defer { try? FileManager.default.removeItem(at: root) }
        let before = FirebaseRuntime.debugCloudAccessCount

        // The same steps CircleuApp and GuestRootView run, with only the folder changed.
        let startup = AppStartup.resolve(arguments: ["Circleu", AppStartup.launchArgument], isDebugBuild: true)
        AppBootstrap.live.run(for: startup)
        let location = GuestJournalLocation(directory: root.appendingPathComponent("GuestJournal"),
                                            setupMarker: root.appendingPathComponent("Setup/initialized"))
        let viewModel = try await GuestComposition.local(at: location).makeViewModel()

        XCTAssertEqual(FirebaseRuntime.debugCloudAccessCount, before, "guest path reached Firebase or a cloud service")
        XCTAssertEqual(viewModel.loadState, .loaded([]), "guest journal opened its local store")
    }

    @MainActor
    func testCloudAccessCounterDetectsTheExistingStartup() {
        let before = FirebaseRuntime.debugCloudAccessCount
        AppBootstrap.live.run(for: AppStartup.resolve(arguments: ["Circleu"], isDebugBuild: true))
        XCTAssertEqual(FirebaseRuntime.debugCloudAccessCount, before + 2, "configure + analytics; proves the check can fail")
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
