import CryptoKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation

/// What can go wrong when logging in to an earlier account. Messages are generic on purpose:
/// they never say whether an account exists.
enum GuestAccountError: Error, Equatable {
    /// Wrong email or password, or no such account (deliberately not told apart).
    case couldNotLogIn
    case offline
    case tooManyAttempts
    /// Log in isn't set up in this build (no Dev configuration for this app).
    case unavailable
    /// The account needs a fresh log in before this (deletion).
    case needsRecentLogIn
    case failed
}

/// Optional Log in to an existing CircleU email/password account, only to bring in that
/// account's earlier journal or delete the account. No sign-up. Nothing is uploaded.
@MainActor
protocol GuestAccountService: AnyObject {
    /// Whether Log in is set up in this build.
    var isAvailable: Bool { get }
    /// Signs out any session left from before (for example after a reinstall); never trusted.
    func discardEarlierSession()
    /// Logs in and returns the account's uid and the Firebase project it belongs to.
    func logIn(email: String, password: String) async throws -> (uid: String, project: String)
    /// Always looks the same to the person, whether or not an account uses this email.
    func sendPasswordReset(email: String) async throws
    /// Deletes the logged-in account itself (after its cloud backup).
    func deleteAccount() async throws
    func signOut()
}

/// The account's private cloud backup: read only its journal and practice, from the server.
@MainActor
protocol GuestCloudBackupReading: AnyObject {
    func readBackup(uid: String, project: String) async throws -> GuestCloudBackup
    /// Deletes the account's private backup documents. Throws if any couldn't be deleted (retry).
    func deleteBackup(uid: String) async throws
}

struct GuestCloudBackup: Equatable {
    var entries: [GuestImportedEntry] = []
    var messages: [GuestImportedMessage] = []
    var skipped: [GuestLegacyScan.Skip] = []
}

/// Import receipts scoped to where an item came from, so cloud items never collide with drafts,
/// local items or another account's items: a stable UUID from "cloud:<project>:<uid>:<kind>:<id>".
enum GuestScopedID {
    static func cloud(project: String, uid: String, kind: String, id: UUID) -> UUID {
        let digest = SHA256.hash(data: Data("cloud:\(project):\(uid):\(kind):\(id.uuidString)".utf8))
        var bytes = Array(digest.prefix(16))
        bytes[6] = (bytes[6] & 0x0F) | 0x50 // Name-based version.
        bytes[8] = (bytes[8] & 0x3F) | 0x80 // RFC 4122 variant.
        return UUID(uuid: (bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7],
                           bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]))
    }
}

/// Maps the account's cloud documents to the guest journal, keeping every rejection visible.
enum GuestCloudBackupMapper {
    static func map(journal: [[String: Any]], practice: [[String: Any]], uid: String, project: String) -> GuestCloudBackup {
        var backup = GuestCloudBackup()
        var rejected = 0
        for document in journal {
            guard let entry = JournalReflectionEntry(firebaseData: document) else { rejected += 1; continue }
            guard let mapped = GuestLegacyImport.map(entry) else {
                backup.skipped.append(.init(what: "An entry from \(entry.createdAt.formatted(date: .abbreviated, time: .omitted))",
                                            reason: .noWords))
                continue
            }
            backup.entries.append(GuestImportedEntry(
                legacyID: GuestScopedID.cloud(project: project, uid: uid, kind: "journal", id: entry.id),
                originalWords: mapped.originalWords, createdAt: mapped.createdAt, updatedAt: mapped.updatedAt,
                reflection: mapped.reflection))
        }
        for document in practice {
            guard let session = TipsPracticeSession(firebaseData: document) else { rejected += 1; continue }
            guard let mapped = GuestLegacyImport.map(session) else {
                backup.skipped.append(.init(what: "A practice message from \(session.createdAt.formatted(date: .abbreviated, time: .omitted))",
                                            reason: .noWords))
                continue
            }
            backup.messages.append(GuestImportedMessage(
                legacyID: GuestScopedID.cloud(project: project, uid: uid, kind: "practice", id: session.id),
                situation: mapped.situation, wording: mapped.wording, createdAt: mapped.createdAt,
                updatedAt: mapped.updatedAt))
        }
        if rejected > 0 {
            backup.skipped.append(.init(what: rejected == 1 ? "1 saved item" : "\(rejected) saved items", reason: .unreadable))
        }
        backup.entries.sort { $0.createdAt > $1.createdAt }
        backup.messages.sort { $0.createdAt > $1.createdAt }
        return backup
    }
}

// MARK: - Live (Firebase, Dev project only)

/// Firebase for the guest journal's Log in, configured only when Log in is first used, and only
/// for the Dev project. It reuses the bundled Dev configuration under this app's own bundle ID
/// (the Dev API key accepts the guest test app; checked 26 Oct with a non-existent account).
/// Release builds carry the Prod configuration, so Log in reports itself unavailable there.
enum GuestFirebase {
    static let allowedProjects: Set<String> = ["circleu-45651"]

    /// Returns the project ID if Firebase is ready for the guest Log in.
    static func configure() -> String? {
        FirebaseRuntime.noteGuestSignInAccess()
        if let app = FirebaseApp.app() {
            return allowedProjects.contains(app.options.projectID ?? "") ? app.options.projectID : nil
        }
        guard let options = FirebaseOptions.defaultOptions(), let project = options.projectID,
              allowedProjects.contains(project) else { return nil } // Never Prod.
        options.bundleID = Bundle.main.bundleIdentifier ?? options.bundleID
        FirebaseApp.configure(options: options)
        // Recovery reads never leave a lasting copy on the phone.
        let settings = FirestoreSettings()
        settings.cacheSettings = MemoryCacheSettings()
        Firestore.firestore().settings = settings
        return project
    }
}

final class LiveGuestAccountService: GuestAccountService {
    private let project: String?

    init() { project = GuestFirebase.configure() }

    var isAvailable: Bool { project != nil }

    func discardEarlierSession() {
        guard isAvailable else { return }
        try? Auth.auth().signOut()
    }

    func logIn(email: String, password: String) async throws -> (uid: String, project: String) {
        guard let project else { throw GuestAccountError.unavailable }
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return (result.user.uid, project)
        } catch {
            throw Self.map(error)
        }
    }

    func sendPasswordReset(email: String) async throws {
        guard isAvailable else { throw GuestAccountError.unavailable }
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            let mapped = Self.map(error)
            // Only problems the person can act on are shown; "no such account" looks like success.
            if mapped == .offline || mapped == .tooManyAttempts { throw mapped }
        }
    }

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { throw GuestAccountError.needsRecentLogIn }
        do { try await user.delete() } catch { throw Self.map(error) }
    }

    func signOut() { try? Auth.auth().signOut() }

    private static func map(_ error: Error) -> GuestAccountError {
        switch AuthErrorCode(rawValue: (error as NSError).code) {
        case .networkError: .offline
        case .tooManyRequests: .tooManyAttempts
        case .requiresRecentLogin: .needsRecentLogIn
        case .wrongPassword, .invalidCredential, .userNotFound, .invalidEmail, .userDisabled: .couldNotLogIn
        default: .failed
        }
    }
}

final class LiveGuestCloudBackupReader: GuestCloudBackupReading {
    private static let privateCollections = ["journalEntries", "tipsPracticeSessions", "quests", "pointEntries",
                                             "activityEvents", "aiReflectionSessions"]

    func readBackup(uid: String, project: String) async throws -> GuestCloudBackup {
        do {
            let users = Firestore.firestore().collection("users").document(uid)
            // From the server only: never an old cached copy.
            async let journal = users.collection("journalEntries").getDocuments(source: .server)
            async let practice = users.collection("tipsPracticeSessions").getDocuments(source: .server)
            return GuestCloudBackupMapper.map(journal: try await journal.documents.map { $0.data() },
                                              practice: try await practice.documents.map { $0.data() },
                                              uid: uid, project: project)
        } catch {
            throw (error as NSError).domain == FirestoreErrorDomain
                && (error as NSError).code == FirestoreErrorCode.unavailable.rawValue
                ? GuestAccountError.offline : GuestAccountError.failed
        }
    }

    func deleteBackup(uid: String) async throws {
        let user = Firestore.firestore().collection("users").document(uid)
        var failures = 0
        for name in Self.privateCollections {
            guard let documents = try? await user.collection(name).getDocuments(source: .server).documents else {
                failures += 1
                continue
            }
            for document in documents where (try? await document.reference.delete()) == nil { failures += 1 }
        }
        for path in ["profile/main", "rewardState/main"] where (try? await user.collection(String(path.split(separator: "/")[0]))
            .document(String(path.split(separator: "/")[1])).delete()) == nil {
            failures += 1
        }
        if (try? await user.delete()) == nil { failures += 1 }
        if failures > 0 { throw GuestAccountError.failed } // Nothing is reported as done unless it is.
    }
}

#if DEBUG
// MARK: - Fakes for Simulator UI tests (launch argument -CircleUFakeAccount YES)

/// Accepts one invented test account. Never real credentials.
final class FakeGuestAccountService: GuestAccountService {
    static let email = "pingu.test@example.com"
    static let password = "test-password-1"
    var isAvailable = true
    private(set) var signedIn = false
    private(set) var deleted = false

    func discardEarlierSession() { signedIn = false }

    func logIn(email: String, password: String) async throws -> (uid: String, project: String) {
        guard !deleted, email.lowercased() == Self.email, password == Self.password else {
            throw GuestAccountError.couldNotLogIn
        }
        signedIn = true
        return ("fake-uid", "fake-project")
    }

    func sendPasswordReset(email: String) async throws {}

    func deleteAccount() async throws {
        guard signedIn else { throw GuestAccountError.needsRecentLogIn }
        deleted = true
        signedIn = false
    }

    func signOut() { signedIn = false }
}

final class FakeGuestCloudBackupReader: GuestCloudBackupReading {
    var deleted = false

    func readBackup(uid: String, project: String) async throws -> GuestCloudBackup {
        let base = Date(timeIntervalSince1970: 1_780_000_000)
        let journal: [[String: Any]] = deleted ? [] : [
            ["entryID": "AAAAAAAA-0000-0000-0000-000000000001", "transcript": "I told my friend I needed space, kindly.",
             "createdAt": Timestamp(date: base), "engineName": "Apple Intelligence", "durationSeconds": 20,
             "result": ["title": "Space", "emotion": "Calm", "summary": "You asked for space kindly.",
                        "insight": "Boundaries can be gentle.", "expressionMoment": "", "quote": "",
                        "confidenceScore": 0.8, "suggestedQuest": ""]],
            ["entryID": "not-a-uuid"],
        ]
        return GuestCloudBackupMapper.map(journal: journal, practice: [], uid: uid, project: project)
    }

    func deleteBackup(uid: String) async throws { deleted = true }
}
#endif
