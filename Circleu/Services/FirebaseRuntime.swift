import FirebaseCore
import Foundation
import os

private let firebaseLogger = Logger(subsystem: "com.Pingu.Circleu", category: "FirebaseRuntime")

enum FirebaseRuntime {
    #if DEBUG
    /// Test instrumentation: counts attempts to configure Firebase or build a cloud service,
    /// so tests can prove the guest journal path never reaches this runtime.
    static var debugCloudAccessCount = 0
    #endif

    private static func recordCloudAccess() {
        #if DEBUG
        debugCloudAccessCount += 1
        #endif
    }

    /// The guest journal's optional Log in configures Firebase itself (Dev only); counted the
    /// same way, so tests can prove guest startup never gets here.
    static func noteGuestSignInAccess() {
        recordCloudAccess()
    }

    static var expectedBundleID: String {
        Bundle.main.bundleIdentifier ?? ""
    }

    static var configuredApp: FirebaseApp? {
        FirebaseApp.app()
    }

    nonisolated static var canUseLiveFirebase: Bool {
        configuredApp != nil
    }

    @discardableResult
    static func configureIfAvailable() -> Bool {
        recordCloudAccess()
        guard FirebaseApp.app() == nil else { return true }
        guard let options = FirebaseOptions.defaultOptions() else {
            firebaseLogger.warning("Firebase disabled: GoogleService-Info.plist is missing.")
            return false
        }

        let configuredBundleID = options.bundleID
        let appBundleID = expectedBundleID
        guard configuredBundleID == appBundleID else {
            firebaseLogger.warning("Firebase disabled: plist bundle ID '\(configuredBundleID, privacy: .public)' does not match app bundle ID '\(appBundleID, privacy: .public)'.")
            return false
        }

        FirebaseApp.configure(options: options)
        return true
    }

    static func makeAuthenticator() -> FirebaseAuthenticating {
        recordCloudAccess()
        return canUseLiveFirebase ? FirebaseAuthService() : NoOpFirebaseAuthenticator()
    }

    static func makeSyncer() -> any ReflectionSyncing & ReflectionBackupRestoring {
        recordCloudAccess()
        return canUseLiveFirebase ? FirebaseUploadOnlySyncer() : NoOpBackendSyncer()
    }

    static func makeAnalyticsTracker() -> any AnalyticsTracking {
        recordCloudAccess()
        return canUseLiveFirebase ? FirebaseAnalyticsTracker() : NoOpAnalyticsTracker()
    }
}

struct NoOpBackendSyncer: ReflectionSyncing, ReflectionBackupRestoring {
    func sync(_ snapshot: BackendSyncSnapshot) async throws -> BackendSyncResult {
        BackendSyncResult()
    }

    func restorePrivateBackup(userID: String) async throws -> BackendSyncSnapshot {
        BackendSyncSnapshot(
            userID: userID,
            journalEntries: [],
            quests: [],
            circles: [],
            circlePosts: [],
            aiSessions: []
        )
    }

    func purgePrivateBackup(userID: String) async throws {}
}
