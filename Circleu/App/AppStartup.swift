import Foundation

/// Which experience the app starts.
///
/// `.guestJournal` is the new local-only journal (first slice). It can only be switched on in
/// DEBUG builds with the hidden `-CircleUGuestMode` launch argument, so TestFlight and App Store
/// (Release) builds always start the existing app exactly as before.
nonisolated enum AppStartup: Equatable, Sendable {
    case existingApp
    case guestJournal

    static let launchArgument = "-CircleUGuestMode"

    static func resolve(arguments: [String] = ProcessInfo.processInfo.arguments,
                        isDebugBuild: Bool = AppStartup.isDebugBuild) -> AppStartup {
        isDebugBuild && arguments.contains(launchArgument) ? .guestJournal : .existingApp
    }

    static var isDebugBuild: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }

    /// Only the existing app configures Firebase and analytics; the guest journal never does.
    var configuresFirebase: Bool { self == .existingApp }
}

/// Launch-time setup, run by `CircleuApp.init`. The steps are injectable so tests exercise this
/// exact path: the guest journal must never configure Firebase or install analytics.
@MainActor
struct AppBootstrap {
    var configureFirebase: () -> Void
    var installAnalytics: () -> Void

    static var live: AppBootstrap {
        AppBootstrap(configureFirebase: { FirebaseRuntime.configureIfAvailable() },
                     installAnalytics: { AnalyticsService.shared = FirebaseRuntime.makeAnalyticsTracker() })
    }

    func run(for startup: AppStartup) {
        guard startup.configuresFirebase else { return }
        configureFirebase()
        installAnalytics()
    }
}
