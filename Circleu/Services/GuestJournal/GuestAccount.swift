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
    /// Throws if it couldn't, and then nothing else may happen.
    func discardEarlierSession() throws
    /// Logs in and returns the account's uid and the Firebase project it belongs to.
    func logIn(email: String, password: String) async throws -> (uid: String, project: String)
    /// Always looks the same to the person, whether or not an account uses this email.
    func sendPasswordReset(email: String) async throws
    /// Deletes the account with this uid, only if it is the one this service logged in to.
    func deleteAccount(uid: String) async throws
    /// Returns false if signing out failed.
    @discardableResult
    func signOut() -> Bool
}

/// The account's private cloud backup: read only its journal and practice, from the server.
@MainActor
protocol GuestCloudBackupReading: AnyObject {
    func readBackup(uid: String, project: String) async throws -> GuestCloudBackup
    /// Deletes everything the account owns in the cloud: its private backup, posts it wrote in any
    /// circle, its memberships, and circles it created (kept only while other people's posts are
    /// in them, which it can't delete). Returns how many such circles were kept. Throws if any part
    /// couldn't be deleted; a retry finds everything that's left.
    func deleteOwnedContent(uid: String) async throws -> Int
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
        // The same item twice: keep its latest edit, every time.
        // (A tie on the edit time is broken by the words, so the result never depends on order.)
        // (A tie on the edit time is broken on the whole record, so the result never depends on order.)
        backup.entries = Dictionary(backup.entries.map { ($0.legacyID, $0) }, uniquingKeysWith: { a, b in
            a.updatedAt != b.updatedAt ? (a.updatedAt > b.updatedAt ? a : b) : ("\(a)" >= "\(b)" ? a : b)
        }).values.sorted { $0.createdAt > $1.createdAt }
        backup.messages = Dictionary(backup.messages.map { ($0.legacyID, $0) }, uniquingKeysWith: { a, b in
            a.updatedAt != b.updatedAt ? (a.updatedAt > b.updatedAt ? a : b) : ("\(a)" >= "\(b)" ? a : b)
        }).values.sorted { $0.createdAt > $1.createdAt }
        return backup
    }
}

// MARK: - Live (Firebase, Dev project only)

/// Firebase for the guest journal's Log in: a separate, named Firebase app used only for
/// recovery, so it never shares sign-in or cache with anything else. Configured only when Log in
/// is first used, and only for the Dev project, reusing the bundled Dev configuration under this
/// app's bundle ID (the Dev key accepts it; checked 26 Oct with a non-existent account). Release
/// builds carry the Prod configuration, so Log in reports itself unavailable there.
enum GuestFirebase {
    static let allowedProjects: Set<String> = ["circleu-45651"]
    static let appName = "circleu-guest-recovery"

    /// The recovery app and its project, if Log in is possible in this build.
    static func app() -> (app: FirebaseApp, project: String)? {
        FirebaseRuntime.noteGuestSignInAccess()
        if let existing = FirebaseApp.app(name: appName), let project = existing.options.projectID {
            return (existing, project)
        }
        guard let options = FirebaseOptions.defaultOptions(), let project = options.projectID,
              allowedProjects.contains(project) else { return nil } // Never Prod.
        options.bundleID = Bundle.main.bundleIdentifier ?? options.bundleID
        FirebaseApp.configure(name: appName, options: options)
        guard let app = FirebaseApp.app(name: appName) else { return nil }
        // Set before any read: recovery data is held in memory only, never on disk.
        let settings = FirestoreSettings()
        settings.cacheSettings = MemoryCacheSettings()
        Firestore.firestore(app: app).settings = settings
        return (app, project)
    }
}

final class LiveGuestAccountService: GuestAccountService {
    private let firebase: (app: FirebaseApp, project: String)?
    /// The user this service logged in to; deletion is bound to it, never to "whoever is current".
    private var user: User?

    init() { firebase = GuestFirebase.app() }

    var isAvailable: Bool { firebase != nil }

    private var auth: Auth? { firebase.map { Auth.auth(app: $0.app) } }

    func discardEarlierSession() throws {
        guard let auth else { return }
        do { try auth.signOut() } catch { throw GuestAccountError.failed }
        user = nil
    }

    func logIn(email: String, password: String) async throws -> (uid: String, project: String) {
        guard let auth, let project = firebase?.project else { throw GuestAccountError.unavailable }
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            user = result.user
            return (result.user.uid, project)
        } catch {
            throw Self.map(error)
        }
    }

    func sendPasswordReset(email: String) async throws {
        guard let auth else { throw GuestAccountError.unavailable }
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            switch Self.map(error) {
            case .couldNotLogIn: return // "No such account" must look like success.
            case .offline: throw GuestAccountError.offline
            case .tooManyAttempts: throw GuestAccountError.tooManyAttempts
            default: throw GuestAccountError.failed // A real service problem is reported, generically.
            }
        }
    }

    func deleteAccount(uid: String) async throws {
        guard let user, user.uid == uid, auth?.currentUser?.uid == uid else { throw GuestAccountError.needsRecentLogIn }
        do { try await user.delete() } catch { throw Self.map(error) }
        self.user = nil
    }

    @discardableResult
    func signOut() -> Bool {
        user = nil
        guard let auth else { return true }
        return (try? auth.signOut()) != nil
    }

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

    private var db: Firestore? { GuestFirebase.app().map { Firestore.firestore(app: $0.app) } }

    func readBackup(uid: String, project: String) async throws -> GuestCloudBackup {
        guard let db else { throw GuestAccountError.unavailable }
        do {
            let user = db.collection("users").document(uid)
            // From the server only: never an old cached copy.
            async let journal = user.collection("journalEntries").getDocuments(source: .server)
            async let practice = user.collection("tipsPracticeSessions").getDocuments(source: .server)
            return GuestCloudBackupMapper.map(journal: try await journal.documents.map { $0.data() },
                                              practice: try await practice.documents.map { $0.data() },
                                              uid: uid, project: project)
        } catch {
            throw (error as NSError).domain == FirestoreErrorDomain
                && (error as NSError).code == FirestoreErrorCode.unavailable.rawValue
                ? GuestAccountError.offline : GuestAccountError.failed
        }
    }

    func deleteOwnedContent(uid: String) async throws -> Int {
        guard let db else { throw GuestAccountError.unavailable }
        var failures = 0
        var keptCircles = 0

        // Every circle is readable to signed-in people, so posts in circles left long ago are found
        // too. A circle is only changed once all of this person's posts in it are gone, so a failed
        // run is always found again by the retry.
        guard let circles = try? await db.collection("circles").getDocuments(source: .server).documents else {
            throw GuestAccountError.failed
        }
        for circle in circles {
            guard let mine = try? await circle.reference.collection("posts").whereField("authorUserID", isEqualTo: uid)
                .getDocuments(source: .server).documents else { failures += 1; continue }
            var postsGone = true
            for post in mine where (try? await post.reference.delete()) == nil {
                postsGone = false
                failures += 1
            }
            guard postsGone else { continue }
            let data = circle.data()
            let isMember = (data["memberUserIDs"] as? [String])?.contains(uid) == true
            if data["creatorUserID"] as? String == uid {
                // Other people's posts can't be deleted here; keep their circle rather than orphan them.
                guard let others = try? await circle.reference.collection("posts").limit(to: 1)
                    .getDocuments(source: .server).documents else { failures += 1; continue }
                if others.isEmpty {
                    if (try? await circle.reference.delete()) == nil { failures += 1 }
                } else {
                    keptCircles += 1
                    // Kept for the others, but this person is no longer in it.
                    if isMember,
                       (try? await circle.reference.updateData(["memberUserIDs": FieldValue.arrayRemove([uid])])) == nil {
                        failures += 1
                    }
                }
            } else if isMember,
                      (try? await circle.reference.updateData(["memberUserIDs": FieldValue.arrayRemove([uid])])) == nil {
                failures += 1
            }
        }

        // The private backup.
        let user = db.collection("users").document(uid)
        for name in Self.privateCollections {
            guard let documents = try? await user.collection(name).getDocuments(source: .server).documents else {
                failures += 1
                continue
            }
            for document in documents where (try? await document.reference.delete()) == nil { failures += 1 }
        }
        for (collection, document) in [("profile", "main"), ("rewardState", "main")]
            where (try? await user.collection(collection).document(document).delete()) == nil { failures += 1 }
        if (try? await user.delete()) == nil { failures += 1 }
        if failures > 0 { throw GuestAccountError.failed } // Nothing is reported as done unless it is.
        return keptCircles
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

    func discardEarlierSession() throws { signedIn = false }

    func logIn(email: String, password: String) async throws -> (uid: String, project: String) {
        guard !deleted, email.lowercased() == Self.email, password == Self.password else {
            throw GuestAccountError.couldNotLogIn
        }
        signedIn = true
        return ("fake-uid", "fake-project")
    }

    func sendPasswordReset(email: String) async throws {}

    func deleteAccount(uid: String) async throws {
        guard signedIn, uid == "fake-uid" else { throw GuestAccountError.needsRecentLogIn }
        deleted = true
        signedIn = false
    }

    @discardableResult
    func signOut() -> Bool { signedIn = false; return true }
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

    func deleteOwnedContent(uid: String) async throws -> Int { deleted = true; return 0 }
}
#endif
