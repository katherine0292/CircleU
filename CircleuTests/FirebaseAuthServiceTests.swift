import XCTest
@testable import Circleu

@MainActor
final class FirebaseAuthServiceTests: XCTestCase {
    func testFirebaseAuthProfileMigratesOnlySafeLocalAccountFields() {
        let account = Account(
            id: UUID(),
            email: " TUAN@EXAMPLE.COM ",
            displayName: "  Tuan Nguyen  ",
            passwordHash: "local-password-hash",
            salt: "local-salt",
            createdAt: Date(timeIntervalSince1970: 10)
        )

        let profile = FirebaseAuthProfile(account: account, localUserID: "local-user-123")

        XCTAssertEqual(profile.email, "tuan@example.com")
        XCTAssertEqual(profile.displayName, "Tuan Nguyen")
        XCTAssertEqual(profile.localUserID, "local-user-123")
    }

    func testFirebaseAuthProfileFallsBackToFriendForBlankDisplayName() {
        let profile = FirebaseAuthProfile(
            email: " FRIEND@example.com ",
            displayName: "   ",
            localUserID: "local-user"
        )

        XCTAssertEqual(profile.email, "friend@example.com")
        XCTAssertEqual(profile.displayName, "Friend")
    }

    func testFirebaseAuthServiceSignsUpAndUpdatesDisplayName() async throws {
        let client = FakeFirebaseAuthClient()
        let service = FirebaseAuthService(client: client)

        let session = try await service.signUp(
            profile: FirebaseAuthProfile(
                email: " TUAN@example.com ",
                displayName: "  Tuan  ",
                localUserID: "local-user-123"
            ),
            password: "strong-password"
        )

        XCTAssertEqual(client.createdEmail, "tuan@example.com")
        XCTAssertEqual(client.createdPassword, "strong-password")
        XCTAssertEqual(client.updatedDisplayName, "Tuan")
        XCTAssertEqual(session.uid, "firebase-user-1")
        XCTAssertEqual(session.email, "tuan@example.com")
        XCTAssertEqual(session.displayName, "Tuan")
        XCTAssertEqual(session.localUserID, "local-user-123")
    }

    func testFirebaseAuthServiceSignsInWithNormalizedEmail() async throws {
        let client = FakeFirebaseAuthClient()
        let service = FirebaseAuthService(client: client)

        let session = try await service.signIn(email: " TUAN@example.com ", password: "strong-password")

        XCTAssertEqual(client.signedInEmail, "tuan@example.com")
        XCTAssertEqual(client.signedInPassword, "strong-password")
        XCTAssertEqual(session.uid, "firebase-user-1")
        XCTAssertEqual(session.email, "tuan@example.com")
    }

    func testFirebaseAuthServiceSignsOutThroughClient() throws {
        let client = FakeFirebaseAuthClient()
        let service = FirebaseAuthService(client: client)

        XCTAssertFalse(client.didSignOut)

        try service.signOut()

        XCTAssertTrue(client.didSignOut)
    }
}

private final class FakeFirebaseAuthClient: FirebaseAuthClient {
    var currentUser: FirebaseAuthSession?
    var createdEmail: String?
    var createdPassword: String?
    var signedInEmail: String?
    var signedInPassword: String?
    var updatedDisplayName: String?
    var didSignOut = false

    func createUser(email: String, password: String) async throws -> FirebaseAuthSession {
        createdEmail = email
        createdPassword = password
        currentUser = FirebaseAuthSession(
            uid: "firebase-user-1",
            email: email,
            displayName: "Friend",
            localUserID: nil
        )
        return currentUser!
    }

    func signIn(email: String, password: String) async throws -> FirebaseAuthSession {
        signedInEmail = email
        signedInPassword = password
        currentUser = FirebaseAuthSession(
            uid: "firebase-user-1",
            email: email,
            displayName: "Tuan",
            localUserID: nil
        )
        return currentUser!
    }

    func updateDisplayName(_ displayName: String) async throws -> FirebaseAuthSession {
        updatedDisplayName = displayName
        currentUser = FirebaseAuthSession(
            uid: currentUser?.uid ?? "firebase-user-1",
            email: currentUser?.email,
            displayName: displayName,
            localUserID: currentUser?.localUserID
        )
        return currentUser!
    }

    func signOut() throws {
        didSignOut = true
        currentUser = nil
    }
}
