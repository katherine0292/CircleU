import XCTest
@testable import Circleu

@MainActor
final class FirebaseFirestoreSyncServiceTests: XCTestCase {
    func testPrivateBackupMapperCreatesUserScopedDocumentsForSupportedPrivateData() {
        let ids = TestIDs()
        let snapshot = makeSnapshot(ids: ids)

        let documents = FirebaseSyncMapper.privateBackupDocuments(for: snapshot)

        XCTAssertEqual(
            documents.map(\.path),
            [
                "users/firebase-user-1",
                "users/firebase-user-1/profile/main",
                "users/firebase-user-1/journalEntries/\(ids.entryID.uuidString)",
                "users/firebase-user-1/quests/\(ids.questID.uuidString)",
                "users/firebase-user-1/tipsPracticeSessions/\(ids.tipsSessionID.uuidString)",
                "users/firebase-user-1/rewardState/main",
                "users/firebase-user-1/pointEntries/\(ids.pointEntryID.uuidString)",
                "users/firebase-user-1/activityEvents/\(ids.activityEventID.uuidString)",
                "users/firebase-user-1/aiReflectionSessions/\(ids.sessionID.uuidString)"
            ]
        )
        XCTAssertEqual(
            documents.map(\.scope),
            [.user, .profile, .journalEntries, .quests, .tipsPracticeSessions, .rewardState, .pointEntries, .activityEvents, .aiSessions]
        )
    }

    func testJournalPayloadMatchesFirebaseSchemaFields() {
        let ids = TestIDs()
        let journal = FirebaseSyncMapper.privateBackupDocuments(for: makeSnapshot(ids: ids))[2]

        XCTAssertEqual(journal.data["entryID"], .string(ids.entryID.uuidString))
        XCTAssertEqual(journal.data["durationSeconds"], .int(120))
        XCTAssertEqual(journal.data["transcript"], .string("I asked for feedback after the group meeting."))
        XCTAssertEqual(journal.data["engineName"], .string("Local test engine"))
        XCTAssertEqual(journal.data["sessionID"], .string(ids.sessionID.uuidString))
        XCTAssertEqual(journal.data["editableTitle"], .string("Team clarity"))
        XCTAssertEqual(journal.data["editableEmotion"], .string("Focused"))
        XCTAssertEqual(journal.data["privateNote"], .string("Remember to thank Mina."))
        XCTAssertEqual(journal.data["tags"], .stringArray(["team", "feedback"]))

        guard case .dictionary(let result)? = journal.data["result"] else {
            XCTFail("Expected result dictionary")
            return
        }

        XCTAssertEqual(result["title"], .string("Clearer voice"))
        XCTAssertEqual(result["confidenceScore"], .double(0.82))
    }

    func testProfileRewardAndTipsPayloadsMatchFirebaseSchemaFields() {
        let ids = TestIDs()
        let documents = FirebaseSyncMapper.privateBackupDocuments(for: makeSnapshot(ids: ids))
        let user = documents[0]
        let profile = documents[1]
        let tips = documents[4]
        let reward = documents[5]
        let points = documents[6]
        let activity = documents[7]

        XCTAssertEqual(user.data["uid"], .string("firebase-user-1"))
        XCTAssertEqual(user.data["email"], .string("tuan@example.com"))
        XCTAssertEqual(user.data["displayName"], .string("Tuan"))
        XCTAssertEqual(user.data["localUserID"], .string("local-user-1"))

        XCTAssertEqual(profile.data["displayName"], .string("Tuan"))
        XCTAssertEqual(profile.data["promptIndex"], .int(2))

        XCTAssertEqual(tips.data["sessionID"], .string(ids.tipsSessionID.uuidString))
        XCTAssertEqual(tips.data["originalMessage"], .string("I need more time to finish this."))
        XCTAssertEqual(tips.data["scene"], .string("workplace"))
        XCTAssertEqual(tips.data["tone"], .string("diplomatic"))
        XCTAssertEqual(tips.data["attachedImageCount"], .int(0))

        XCTAssertEqual(reward.data["points"], .int(35))
        XCTAssertEqual(reward.data["level"], .int(1))
        XCTAssertEqual(reward.data["intoLevel"], .int(35))
        XCTAssertEqual(reward.data["nextLevel"], .int(2))

        XCTAssertEqual(points.data["pointEntryID"], .string(ids.pointEntryID.uuidString))
        XCTAssertEqual(points.data["label"], .string("Daily reflection"))
        XCTAssertEqual(points.data["points"], .int(8))

        XCTAssertEqual(activity.data["activityEventID"], .string(ids.activityEventID.uuidString))
        XCTAssertEqual(activity.data["type"], .string("reflect"))
        XCTAssertEqual(activity.data["refID"], .string(ids.entryID.uuidString))
    }

    func testPrivateBackupMapperDoesNotUploadSharedCircleDataBeforeRulesExist() {
        let ids = TestIDs()
        let documents = FirebaseSyncMapper.privateBackupDocuments(for: makeSnapshot(ids: ids))

        XCTAssertFalse(documents.contains { $0.path.hasPrefix("circles/") })
        XCTAssertFalse(documents.contains { $0.scope == .circles || $0.scope == .circlePosts })
    }

    func testUploadOnlySyncerWritesDocumentsWithMergeAndReportsUploadedPrivateCounts() async throws {
        let ids = TestIDs()
        let client = FakeFirestoreClient()
        let syncer = FirebaseUploadOnlySyncer(client: client)

        let result = try await syncer.sync(makeSnapshot(ids: ids))

        XCTAssertTrue(result.didSucceed)
        XCTAssertEqual(result.uploadedCounts.journalEntryCount, 1)
        XCTAssertEqual(result.uploadedCounts.questCount, 1)
        XCTAssertEqual(result.uploadedCounts.tipsPracticeSessionCount, 1)
        XCTAssertEqual(result.uploadedCounts.pointEntryCount, 1)
        XCTAssertEqual(result.uploadedCounts.activityEventCount, 1)
        XCTAssertEqual(result.uploadedCounts.aiSessionCount, 1)
        XCTAssertEqual(result.uploadedCounts.circleCount, 0)
        XCTAssertEqual(result.uploadedCounts.circlePostCount, 0)
        XCTAssertEqual(result.downloadedCounts, .zero)
        XCTAssertEqual(client.writes.map(\.merge), Array(repeating: true, count: 9))
        XCTAssertEqual(client.writes.map(\.path).count, 9)
    }

    func testUploadOnlySyncerReportsFailedScopesWithoutThrowingAwaySuccessfulWrites() async throws {
        let ids = TestIDs()
        let client = FakeFirestoreClient(failingPaths: [
            "users/firebase-user-1/quests/\(ids.questID.uuidString)"
        ])
        let syncer = FirebaseUploadOnlySyncer(client: client)

        let result = try await syncer.sync(makeSnapshot(ids: ids))

        XCTAssertFalse(result.didSucceed)
        XCTAssertEqual(result.failedScopes, [.quests])
        XCTAssertEqual(result.uploadedCounts.journalEntryCount, 1)
        XCTAssertEqual(result.uploadedCounts.questCount, 0)
        XCTAssertEqual(result.uploadedCounts.aiSessionCount, 1)
    }

    func testRestorePrivateBackupReadsUserScopedDocumentsIntoSnapshot() async throws {
        let ids = TestIDs()
        let snapshot = makeSnapshot(ids: ids)
        let documents = Dictionary(
            uniqueKeysWithValues: FirebaseSyncMapper.privateBackupDocuments(for: snapshot).map { ($0.path, $0.firestoreData) }
        )
        let client = FakeFirestoreClient(seedDocuments: documents)
        let syncer = FirebaseUploadOnlySyncer(client: client)

        let restored = try await syncer.restorePrivateBackup(userID: "firebase-user-1")

        XCTAssertEqual(restored.user?.uid, "firebase-user-1")
        XCTAssertEqual(restored.profile?.displayName, "Tuan")
        XCTAssertEqual(restored.journalEntries.first?.id, ids.entryID)
        XCTAssertEqual(restored.journalEntries.first?.result.title, "Clearer voice")
        XCTAssertEqual(restored.quests.first?.id, ids.questID)
        XCTAssertEqual(restored.tipsPracticeSessions.first?.id, ids.tipsSessionID)
        XCTAssertEqual(restored.rewardState?.points, 35)
        XCTAssertEqual(restored.pointEntries.first?.id, ids.pointEntryID)
        XCTAssertEqual(restored.activityEvents.first?.id, ids.activityEventID)
        XCTAssertEqual(restored.aiSessions.first?.id, ids.sessionID)
        XCTAssertEqual(restored.counts.journalEntryCount, 1)
        XCTAssertEqual(restored.counts.aiSessionCount, 1)
    }

    func testPurgePrivateBackupDeletesAllUserScopedDocuments() async throws {
        let ids = TestIDs()
        let snapshot = makeSnapshot(ids: ids)
        let documents = Dictionary(
            uniqueKeysWithValues: FirebaseSyncMapper.privateBackupDocuments(for: snapshot).map { ($0.path, $0.firestoreData) }
        )
        let client = FakeFirestoreClient(seedDocuments: documents)
        let syncer = FirebaseUploadOnlySyncer(client: client)

        XCTAssertFalse(client.documents.isEmpty)

        try await syncer.purgePrivateBackup(userID: "firebase-user-1")

        XCTAssertTrue(client.documents.isEmpty)
        XCTAssertTrue(client.deletedPaths.contains("users/firebase-user-1/profile/main"))
        XCTAssertTrue(client.deletedPaths.contains("users/firebase-user-1/journalEntries/\(ids.entryID.uuidString)"))
        XCTAssertTrue(client.deletedPaths.contains("users/firebase-user-1/quests/\(ids.questID.uuidString)"))
        XCTAssertTrue(client.deletedPaths.contains("users/firebase-user-1/tipsPracticeSessions/\(ids.tipsSessionID.uuidString)"))
        XCTAssertTrue(client.deletedPaths.contains("users/firebase-user-1/rewardState/main"))
        XCTAssertTrue(client.deletedPaths.contains("users/firebase-user-1/pointEntries/\(ids.pointEntryID.uuidString)"))
        XCTAssertTrue(client.deletedPaths.contains("users/firebase-user-1/activityEvents/\(ids.activityEventID.uuidString)"))
        XCTAssertTrue(client.deletedPaths.contains("users/firebase-user-1/aiReflectionSessions/\(ids.sessionID.uuidString)"))
    }
}

private struct TestIDs {
    let entryID = UUID(uuidString: "00000000-0000-0000-0000-000000000101")!
    let questID = UUID(uuidString: "00000000-0000-0000-0000-000000000102")!
    let circleID = UUID(uuidString: "00000000-0000-0000-0000-000000000103")!
    let postID = UUID(uuidString: "00000000-0000-0000-0000-000000000104")!
    let sessionID = UUID(uuidString: "00000000-0000-0000-0000-000000000105")!
    let attemptID = UUID(uuidString: "00000000-0000-0000-0000-000000000106")!
    let tipsSessionID = UUID(uuidString: "00000000-0000-0000-0000-000000000107")!
    let tipsTurnID = UUID(uuidString: "00000000-0000-0000-0000-000000000108")!
    let tipsOptionID = UUID(uuidString: "00000000-0000-0000-0000-000000000109")!
    let pointEntryID = UUID(uuidString: "00000000-0000-0000-0000-000000000110")!
    let activityEventID = UUID(uuidString: "00000000-0000-0000-0000-000000000111")!
}

private struct FakeFirestoreWrite {
    var path: String
    var data: [String: Any]
    var merge: Bool
}

private final class FakeFirestoreClient: FirebaseFirestoreClient {
    var writes: [FakeFirestoreWrite] = []
    var deletedPaths: [String] = []
    var documents: [String: [String: Any]]
    private let failingPaths: Set<String>

    init(seedDocuments: [String: [String: Any]] = [:], failingPaths: Set<String> = []) {
        self.documents = seedDocuments
        self.failingPaths = failingPaths
    }

    func setData(_ data: [String: Any], at documentPath: String, merge: Bool) async throws {
        if failingPaths.contains(documentPath) {
            throw FakeFirestoreError.writeFailed
        }

        writes.append(FakeFirestoreWrite(path: documentPath, data: data, merge: merge))
        documents[documentPath] = data
    }

    func getDocument(at documentPath: String) async throws -> [String: Any]? {
        documents[documentPath]
    }

    func getDocuments(in collectionPath: String) async throws -> [[String: Any]] {
        let prefix = "\(collectionPath)/"
        return documents
            .filter { item in
                item.key.hasPrefix(prefix) && item.key.dropFirst(prefix.count).contains("/") == false
            }
            .map(\.value)
    }

    func deleteDocument(at documentPath: String) async throws {
        if failingPaths.contains(documentPath) {
            throw FakeFirestoreError.writeFailed
        }
        deletedPaths.append(documentPath)
        documents.removeValue(forKey: documentPath)
    }
}

private enum FakeFirestoreError: Error {
    case writeFailed
}

private func makeSnapshot(ids: TestIDs) -> BackendSyncSnapshot {
    let createdAt = Date(timeIntervalSince1970: 100)
    let updatedAt = Date(timeIntervalSince1970: 200)
    let entry = JournalReflectionEntry(
        id: ids.entryID,
        createdAt: createdAt,
        durationSeconds: 120,
        transcript: "I asked for feedback after the group meeting.",
        engineName: "Local test engine",
        result: AIReflectionResult(
            title: "Clearer voice",
            emotion: "Focused",
            summary: "You made the conversation easier to enter.",
            insight: "Asking directly helped you get useful feedback.",
            expressionMoment: "You named the ask clearly.",
            quote: "A direct question can be kind.",
            confidenceScore: 0.82,
            suggestedQuest: "Ask one clarifying question tomorrow."
        ),
        sessionID: ids.sessionID,
        editableTitle: "Team clarity",
        editableEmotion: "Focused",
        privateNote: "Remember to thank Mina.",
        tags: ["team", "feedback"],
        lastEditedAt: updatedAt
    )
    let quest = Quest(
        id: ids.questID,
        title: "Ask one question",
        detail: "Ask one clarifying question tomorrow.",
        sourceEntryID: ids.entryID,
        createdAt: createdAt,
        status: .active
    )
    let circle = CircleSpace(id: ids.circleID, name: "Support", intention: "Private practice", createdAt: createdAt)
    let post = CirclePost(
        id: ids.postID,
        circleID: ids.circleID,
        text: "I practiced asking for feedback.",
        createdAt: createdAt,
        sourceEntryID: ids.entryID
    )
    let session = AIReflectionSession(
        id: ids.sessionID,
        createdAt: createdAt,
        updatedAt: updatedAt,
        entryID: ids.entryID,
        engineName: "Local test engine",
        source: .typedFallback,
        transcript: entry.transcript,
        durationSeconds: 120,
        attempts: [
            AIReflectionAttempt(
                id: ids.attemptID,
                createdAt: createdAt,
                engineName: "Local test engine",
                status: .succeeded,
                result: entry.result,
                elapsedMilliseconds: 40
            )
        ],
        selectedAttemptID: ids.attemptID
    )
    let tipsSession = TipsPracticeSession(
        id: ids.tipsSessionID,
        createdAt: createdAt,
        updatedAt: updatedAt,
        originalMessage: "I need more time to finish this.",
        scene: .workplace,
        tone: .diplomatic,
        situation: "Group project deadline",
        turns: [
            TipsPracticeTurn(
                id: ids.tipsTurnID,
                role: .user,
                label: "You said",
                text: "I need more time to finish this.",
                createdAt: createdAt
            )
        ],
        coachOutput: TipsCoachOutput(
            suggestedPhrasing: "I can finish this well if I have one more day.",
            whyItWorks: "It names the need and the outcome.",
            simulatedReply: "Thanks for explaining.",
            roomReading: "Clear and calm.",
            replyOptions: [
                TipsCoachReplyOption(id: ids.tipsOptionID, label: "NEXT", text: "Can we agree on tomorrow?")
            ]
        )
    )
    let pointEntry = PointEntry(
        id: ids.pointEntryID,
        label: "Daily reflection",
        points: 8,
        icon: "📓",
        createdAt: createdAt
    )
    let activityEvent = ActivityEvent(
        id: ids.activityEventID,
        type: .reflect,
        title: "Team clarity",
        keyword: "Focused · reflection",
        refID: ids.entryID,
        createdAt: createdAt
    )

    return BackendSyncSnapshot(
        userID: "firebase-user-1",
        generatedAt: updatedAt,
        user: BackendUserSnapshot(
            uid: "firebase-user-1",
            email: "tuan@example.com",
            displayName: "Tuan",
            localUserID: "local-user-1",
            updatedAt: updatedAt
        ),
        profile: BackendProfileSnapshot(displayName: "Tuan", promptIndex: 2, updatedAt: updatedAt),
        journalEntries: [entry],
        quests: [quest],
        tipsPracticeSessions: [tipsSession],
        rewardState: BackendRewardSnapshot(
            points: 35,
            level: 1,
            intoLevel: 35,
            nextLevel: 2,
            questAwards: ["daily_reflect": "2026-6-10"],
            updatedAt: updatedAt
        ),
        pointEntries: [pointEntry],
        activityEvents: [activityEvent],
        circles: [circle],
        circlePosts: [post],
        aiSessions: [session]
    )
}
