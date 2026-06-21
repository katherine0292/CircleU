import Combine
import Foundation

enum BackendSyncOperation: String, Equatable {
    case idle
    case uploading
    case restoring
}

@MainActor
final class BackendSessionStore: ObservableObject {
    @Published private(set) var session: FirebaseAuthSession?
    @Published private(set) var lastAuthErrorMessage: String?
    @Published private(set) var lastSyncResult: BackendSyncResult?
    @Published private(set) var lastUploadResult: BackendSyncResult?
    @Published private(set) var lastRestoreResult: BackendSyncResult?
    @Published private(set) var lastSyncErrorMessage: String?
    @Published private(set) var lastSyncErrorOperation: BackendSyncOperation?
    @Published private(set) var syncOperation: BackendSyncOperation = .idle
    @Published private(set) var lastSyncAttemptedAt: Date?
    @Published private(set) var lastUploadStartedAt: Date?
    @Published private(set) var lastUploadSucceededAt: Date?
    @Published private(set) var lastRestoreStartedAt: Date?
    @Published private(set) var lastRestoreSucceededAt: Date?

    private let authenticator: FirebaseAuthenticating
    private let syncer: ReflectionSyncing
    private let restorer: ReflectionBackupRestoring
    private let identityProvider: UserIdentityProviding

    init(
        authenticator: FirebaseAuthenticating? = nil,
        syncer: ReflectionSyncing? = nil,
        restorer: ReflectionBackupRestoring? = nil,
        identityProvider: UserIdentityProviding? = nil
    ) {
        let liveSyncer = FirebaseRuntime.makeSyncer()
        self.authenticator = authenticator ?? FirebaseRuntime.makeAuthenticator()
        self.syncer = syncer ?? liveSyncer
        self.restorer = restorer ?? liveSyncer
        self.identityProvider = identityProvider ?? LocalUserIdentityProvider()
        session = self.authenticator.currentSession
    }

    /// Wire backend-dependent stores to follow the current Firebase auth session. Call once
    /// (during app launch) and again whenever the session changes via sign-in / sign-out.
    /// CircleStore mirrors the public `/circles` collection; the journal + AI session stores
    /// scope their on-device cache to the signed-in UID so no account ever sees another
    /// account's reflections on the same device.
    func wireBackendStores(
        circleStore: CircleStore,
        journalStore: ReflectionJournalStore,
        aiSessionStore: AIReflectionSessionStore,
        rewardsStore: RewardsStore,
        questStore: QuestStore,
        tipsPracticeStore: TipsPracticeStore,
        profileStore: UserProfileStore
    ) {
        if let session {
            UserDefaults.standard.set(session.uid, forKey: "circleu.currentFirebaseUID")
            circleStore.configureBackend(uid: session.uid, displayName: session.displayName)
            journalStore.configureBackend(uid: session.uid)
            aiSessionStore.configureBackend(uid: session.uid)
            rewardsStore.configureBackend(uid: session.uid)
            questStore.configureBackend(uid: session.uid)
            tipsPracticeStore.configureBackend(uid: session.uid)
            profileStore.configureBackend(uid: session.uid)
        } else {
            UserDefaults.standard.removeObject(forKey: "circleu.currentFirebaseUID")
            circleStore.teardownBackend()
            journalStore.teardownBackend()
            aiSessionStore.teardownBackend()
            rewardsStore.teardownBackend()
            questStore.teardownBackend()
            tipsPracticeStore.teardownBackend()
            profileStore.teardownBackend()
        }
    }

    var backendUserID: String? {
        session?.uid
    }

    var backendEmail: String? {
        session?.email
    }

    var isSyncing: Bool {
        syncOperation != .idle
    }

    func signUp(
        name: String,
        email: String,
        password: String,
        authStore: AuthStore,
        profileStore: UserProfileStore
    ) async throws -> Account {
        let account: Account
        do {
            account = try authStore.signUp(name: name, email: email, password: password)
        } catch AuthError.emailTaken {
            account = try authStore.signIn(email: email, password: password)
        }
        profileStore.updateDisplayName(account.displayName)

        do {
            session = try await authenticator.signUp(
                profile: FirebaseAuthProfile(account: account, localUserID: identityProvider.localUserID),
                password: password
            )
            lastAuthErrorMessage = nil
        } catch {
            do {
                session = try await authenticator.signIn(email: account.email, password: password)
                lastAuthErrorMessage = nil
            } catch {
                lastAuthErrorMessage = error.localizedDescription
                throw error
            }
        }

        return account
    }

    func signIn(
        email: String,
        password: String,
        authStore: AuthStore,
        profileStore: UserProfileStore
    ) async throws -> Account {
        let account: Account
        do {
            account = try authStore.signIn(email: email, password: password)
        } catch AuthError.noAccount {
            let restoredSession = try await signInWithFirebase(email: email, password: password)
            account = try authStore.signUp(
                name: restoredDisplayName(from: restoredSession, email: email),
                email: email,
                password: password
            )
        }

        profileStore.updateDisplayName(account.displayName)

        if session?.email != account.email {
            _ = try await signInWithFirebase(email: email, password: password)
        }

        return account
    }

    func signOut(authStore: AuthStore) {
        do {
            try authenticator.signOut()
            lastAuthErrorMessage = nil
        } catch {
            lastAuthErrorMessage = error.localizedDescription
        }

        session = nil
        authStore.logout()
    }

    func deleteAccount(
        authStore: AuthStore,
        profileStore: UserProfileStore,
        journalStore: ReflectionJournalStore,
        questStore: QuestStore,
        tipsPracticeStore: TipsPracticeStore,
        rewardsStore: RewardsStore,
        aiSessionStore: AIReflectionSessionStore,
        circleStore: CircleStore,
        hasCompletedOnboarding: inout Bool
    ) async throws {
        // 1. Purge Firestore backup first while authenticated
        if let uid = session?.uid {
            do {
                try await restorer.purgePrivateBackup(userID: uid)
            } catch {
                // Log and continue on best-effort basis
                print("Failed to purge Firestore cloud backup: \(error)")
            }
        }

        // 2. Delete Firebase Authentication account
        do {
            try await authenticator.deleteAccount()
            lastAuthErrorMessage = nil
        } catch {
            lastAuthErrorMessage = error.localizedDescription
            throw error
        }

        // 3. Log out and invalidate local session
        session = nil
        authStore.logout()

        // 4. Reset all local data models and return to first-run state
        profileStore.reset()
        journalStore.reset()
        aiSessionStore.reset()
        questStore.reset()
        tipsPracticeStore.resetAll()
        rewardsStore.reset()
        circleStore.reset(seedStarterSpaces: false)
        hasCompletedOnboarding = false
    }

    func updateDisplayName(_ displayName: String) async throws {
        guard let currentSession = session else { return }
        do {
            let updatedSession = try await authenticator.updateDisplayName(displayName)
            session = FirebaseAuthSession(
                uid: updatedSession.uid,
                email: updatedSession.email ?? currentSession.email,
                displayName: updatedSession.displayName,
                localUserID: currentSession.localUserID
            )
            lastAuthErrorMessage = nil
        } catch {
            lastAuthErrorMessage = error.localizedDescription
            throw error
        }
    }

    func uploadPrivateBackup(
        profileStore: UserProfileStore,
        journalStore: ReflectionJournalStore,
        questStore: QuestStore,
        tipsPracticeStore: TipsPracticeStore,
        rewardsStore: RewardsStore,
        circleStore: CircleStore,
        aiSessionStore: AIReflectionSessionStore
    ) async {
        guard let uid = session?.uid else { return }
        guard !isSyncing else { return }
        let now = Date()

        let snapshot = BackendSyncSnapshot(
            userID: uid,
            generatedAt: now,
            user: BackendUserSnapshot(
                uid: uid,
                email: session?.email,
                displayName: session?.displayName ?? profileStore.displayName,
                localUserID: session?.localUserID,
                updatedAt: now
            ),
            profile: BackendProfileSnapshot(
                displayName: profileStore.displayName,
                promptIndex: profileStore.dailyPromptIndex,
                updatedAt: now
            ),
            journalEntries: journalStore.entries,
            quests: questStore.quests,
            tipsPracticeSessions: tipsPracticeStore.recentSessions,
            rewardState: BackendRewardSnapshot(
                points: rewardsStore.points,
                level: rewardsStore.level,
                intoLevel: rewardsStore.intoLevel,
                nextLevel: rewardsStore.nextLevel,
                questAwards: rewardsStore.questAwards,
                updatedAt: now
            ),
            pointEntries: rewardsStore.pointsLog,
            activityEvents: rewardsStore.activity,
            circles: circleStore.circles,
            circlePosts: circleStore.posts,
            aiSessions: aiSessionStore.sessions
        )

        guard !snapshot.isEmpty else { return }

        let startedAt = Date()
        lastSyncAttemptedAt = startedAt
        lastUploadStartedAt = startedAt
        syncOperation = .uploading
        defer { syncOperation = .idle }

        do {
            let result = try await syncer.sync(snapshot)
            lastUploadResult = result
            lastSyncResult = result
            if result.didSucceed {
                lastUploadSucceededAt = result.syncedAt
            }
            lastSyncErrorMessage = nil
            lastSyncErrorOperation = nil
        } catch {
            lastSyncErrorMessage = error.localizedDescription
            lastSyncErrorOperation = .uploading
        }
    }

    func restorePrivateBackup(
        profileStore: UserProfileStore,
        journalStore: ReflectionJournalStore,
        questStore: QuestStore,
        tipsPracticeStore: TipsPracticeStore,
        rewardsStore: RewardsStore,
        aiSessionStore: AIReflectionSessionStore
    ) async {
        guard let uid = session?.uid else { return }
        guard !isSyncing else { return }

        let startedAt = Date()
        lastSyncAttemptedAt = startedAt
        lastRestoreStartedAt = startedAt
        syncOperation = .restoring
        defer { syncOperation = .idle }

        do {
            let snapshot = try await restorer.restorePrivateBackup(userID: uid)
            profileStore.mergeRestoredProfile(snapshot.profile)
            journalStore.mergeRestoredEntries(snapshot.journalEntries)
            questStore.mergeRestoredQuests(snapshot.quests)
            tipsPracticeStore.mergeRestoredSessions(snapshot.tipsPracticeSessions)
            rewardsStore.mergeRestoredBackup(
                rewardState: snapshot.rewardState,
                pointEntries: snapshot.pointEntries,
                activityEvents: snapshot.activityEvents
            )
            aiSessionStore.mergeRestoredSessions(snapshot.aiSessions)

            let result = BackendSyncResult(downloadedCounts: snapshot.counts)
            lastRestoreResult = result
            lastSyncResult = result
            if result.didSucceed {
                lastRestoreSucceededAt = result.syncedAt
            }
            lastSyncErrorMessage = nil
            lastSyncErrorOperation = nil
        } catch {
            lastSyncErrorMessage = error.localizedDescription
            lastSyncErrorOperation = .restoring
        }
    }

    private func signInWithFirebase(email: String, password: String) async throws -> FirebaseAuthSession {
        do {
            let firebaseSession = try await authenticator.signIn(email: email, password: password)
            session = firebaseSession
            lastAuthErrorMessage = nil
            return firebaseSession
        } catch {
            lastAuthErrorMessage = error.localizedDescription
            throw error
        }
    }

    private func fallbackDisplayName(from email: String) -> String {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let prefix = cleanEmail.split(separator: "@").first.map(String.init) ?? ""
        return prefix.isEmpty ? "Friend" : prefix
    }

    private func restoredDisplayName(from session: FirebaseAuthSession, email: String) -> String {
        let displayName = session.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        return displayName.isEmpty ? fallbackDisplayName(from: email) : displayName
    }
}
