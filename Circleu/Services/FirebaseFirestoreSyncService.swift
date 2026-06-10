import FirebaseFirestore
import Foundation

indirect enum FirebasePayloadValue: Equatable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case date(Date)
    case stringArray([String])
    case dictionary([String: FirebasePayloadValue])
    case dictionaryArray([[String: FirebasePayloadValue]])

    nonisolated var firestoreValue: Any {
        switch self {
        case .string(let value):
            return value
        case .int(let value):
            return value
        case .double(let value):
            return value
        case .bool(let value):
            return value
        case .date(let value):
            return value
        case .stringArray(let value):
            return value
        case .dictionary(let value):
            return value.mapValues(\.firestoreValue)
        case .dictionaryArray(let values):
            return values.map { $0.mapValues(\.firestoreValue) }
        }
    }
}

struct FirebaseDocumentPayload: Equatable {
    var path: String
    var data: [String: FirebasePayloadValue]
    var scope: BackendSyncScope

    nonisolated var firestoreData: [String: Any] {
        data.mapValues(\.firestoreValue)
    }
}

enum FirebaseSyncMapper {
    nonisolated static func privateBackupDocuments(for snapshot: BackendSyncSnapshot) -> [FirebaseDocumentPayload] {
        let uid = snapshot.userID

        let userDocument = snapshot.user.map { user in
            FirebaseDocumentPayload(
                path: "users/\(uid)",
                data: user.firebasePayload,
                scope: .user
            )
        }

        let profileDocument = snapshot.profile.map { profile in
            FirebaseDocumentPayload(
                path: "users/\(uid)/profile/main",
                data: profile.firebasePayload,
                scope: .profile
            )
        }

        let journalDocuments = snapshot.journalEntries.map { entry in
            FirebaseDocumentPayload(
                path: "users/\(uid)/journalEntries/\(entry.id.uuidString)",
                data: entry.firebasePayload,
                scope: .journalEntries
            )
        }

        let questDocuments = snapshot.quests.map { quest in
            FirebaseDocumentPayload(
                path: "users/\(uid)/quests/\(quest.id.uuidString)",
                data: quest.firebasePayload,
                scope: .quests
            )
        }

        let tipsPracticeDocuments = snapshot.tipsPracticeSessions.map { session in
            FirebaseDocumentPayload(
                path: "users/\(uid)/tipsPracticeSessions/\(session.id.uuidString)",
                data: session.firebasePayload,
                scope: .tipsPracticeSessions
            )
        }

        let rewardDocument = snapshot.rewardState.map { rewardState in
            FirebaseDocumentPayload(
                path: "users/\(uid)/rewardState/main",
                data: rewardState.firebasePayload,
                scope: .rewardState
            )
        }

        let pointDocuments = snapshot.pointEntries.map { entry in
            FirebaseDocumentPayload(
                path: "users/\(uid)/pointEntries/\(entry.id.uuidString)",
                data: entry.firebasePayload,
                scope: .pointEntries
            )
        }

        let activityDocuments = snapshot.activityEvents.map { event in
            FirebaseDocumentPayload(
                path: "users/\(uid)/activityEvents/\(event.id.uuidString)",
                data: event.firebasePayload,
                scope: .activityEvents
            )
        }

        let aiSessionDocuments = snapshot.aiSessions.map { session in
            FirebaseDocumentPayload(
                path: "users/\(uid)/aiReflectionSessions/\(session.id.uuidString)",
                data: session.firebasePayload,
                scope: .aiSessions
            )
        }

        return [userDocument, profileDocument].compactMap { $0 }
            + journalDocuments
            + questDocuments
            + tipsPracticeDocuments
            + [rewardDocument].compactMap { $0 }
            + pointDocuments
            + activityDocuments
            + aiSessionDocuments
    }

    nonisolated static func privateBackupSnapshot(
        userID: String,
        userDocument: [String: Any]?,
        profileDocument: [String: Any]?,
        journalDocuments: [[String: Any]],
        questDocuments: [[String: Any]],
        tipsPracticeDocuments: [[String: Any]],
        rewardDocument: [String: Any]?,
        pointDocuments: [[String: Any]],
        activityDocuments: [[String: Any]],
        aiSessionDocuments: [[String: Any]]
    ) -> BackendSyncSnapshot {
        BackendSyncSnapshot(
            userID: userID,
            user: userDocument.flatMap(BackendUserSnapshot.init(firebaseData:)),
            profile: profileDocument.flatMap(BackendProfileSnapshot.init(firebaseData:)),
            journalEntries: journalDocuments.compactMap(JournalReflectionEntry.init(firebaseData:)),
            quests: questDocuments.compactMap(Quest.init(firebaseData:)),
            tipsPracticeSessions: tipsPracticeDocuments.compactMap(TipsPracticeSession.init(firebaseData:)),
            rewardState: rewardDocument.flatMap(BackendRewardSnapshot.init(firebaseData:)),
            pointEntries: pointDocuments.compactMap(PointEntry.init(firebaseData:)),
            activityEvents: activityDocuments.compactMap(ActivityEvent.init(firebaseData:)),
            circles: [],
            circlePosts: [],
            aiSessions: aiSessionDocuments.compactMap(AIReflectionSession.init(firebaseData:))
        )
    }
}

nonisolated protocol FirebaseFirestoreClient {
    func setData(_ data: [String: Any], at documentPath: String, merge: Bool) async throws
    func getDocument(at documentPath: String) async throws -> [String: Any]?
    func getDocuments(in collectionPath: String) async throws -> [[String: Any]]
}

struct FirebaseUploadOnlySyncer: ReflectionSyncing, ReflectionBackupRestoring {
    nonisolated(unsafe) private let client: FirebaseFirestoreClient

    nonisolated init(client: FirebaseFirestoreClient = LiveFirebaseFirestoreClient()) {
        self.client = client
    }

    nonisolated func sync(_ snapshot: BackendSyncSnapshot) async throws -> BackendSyncResult {
        let documents = FirebaseSyncMapper.privateBackupDocuments(for: snapshot)
        var uploadedCounts = BackendSyncCounts.zero
        var failedScopes = Set<BackendSyncScope>()

        for document in documents {
            do {
                try await client.setData(document.firestoreData, at: document.path, merge: true)
                uploadedCounts.increment(document.scope)
            } catch {
                failedScopes.insert(document.scope)
            }
        }

        return BackendSyncResult(
            uploadedCounts: uploadedCounts,
            downloadedCounts: .zero,
            failedScopes: BackendSyncScope.allCases.filter { failedScopes.contains($0) }
        )
    }

    nonisolated func restorePrivateBackup(userID: String) async throws -> BackendSyncSnapshot {
        async let userDocument = client.getDocument(at: "users/\(userID)")
        async let profileDocument = client.getDocument(at: "users/\(userID)/profile/main")
        async let journalDocuments = client.getDocuments(in: "users/\(userID)/journalEntries")
        async let questDocuments = client.getDocuments(in: "users/\(userID)/quests")
        async let tipsPracticeDocuments = client.getDocuments(in: "users/\(userID)/tipsPracticeSessions")
        async let rewardDocument = client.getDocument(at: "users/\(userID)/rewardState/main")
        async let pointDocuments = client.getDocuments(in: "users/\(userID)/pointEntries")
        async let activityDocuments = client.getDocuments(in: "users/\(userID)/activityEvents")
        async let aiSessionDocuments = client.getDocuments(in: "users/\(userID)/aiReflectionSessions")

        return try await FirebaseSyncMapper.privateBackupSnapshot(
            userID: userID,
            userDocument: userDocument,
            profileDocument: profileDocument,
            journalDocuments: journalDocuments,
            questDocuments: questDocuments,
            tipsPracticeDocuments: tipsPracticeDocuments,
            rewardDocument: rewardDocument,
            pointDocuments: pointDocuments,
            activityDocuments: activityDocuments,
            aiSessionDocuments: aiSessionDocuments
        )
    }
}

struct LiveFirebaseFirestoreClient: FirebaseFirestoreClient {
    nonisolated init() {}

    nonisolated func setData(_ data: [String: Any], at documentPath: String, merge: Bool) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Firestore.firestore().document(documentPath).setData(data, merge: merge) { error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume()
            }
        }
    }

    nonisolated func getDocument(at documentPath: String) async throws -> [String: Any]? {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[String: Any]?, Error>) in
            Firestore.firestore().document(documentPath).getDocument { snapshot, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: snapshot?.data())
            }
        }
    }

    nonisolated func getDocuments(in collectionPath: String) async throws -> [[String: Any]] {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[[String: Any]], Error>) in
            Firestore.firestore().collection(collectionPath).getDocuments { snapshot, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: snapshot?.documents.map { $0.data() } ?? [])
            }
        }
    }
}

private extension BackendSyncCounts {
    nonisolated mutating func increment(_ scope: BackendSyncScope) {
        switch scope {
        case .user, .profile, .rewardState:
            break
        case .journalEntries:
            journalEntryCount += 1
        case .quests:
            questCount += 1
        case .tipsPracticeSessions:
            tipsPracticeSessionCount += 1
        case .pointEntries:
            pointEntryCount += 1
        case .activityEvents:
            activityEventCount += 1
        case .circles:
            circleCount += 1
        case .circlePosts:
            circlePostCount += 1
        case .aiSessions:
            aiSessionCount += 1
        }
    }
}

private extension BackendUserSnapshot {
    nonisolated var firebasePayload: [String: FirebasePayloadValue] {
        compactPayload([
            "uid": .string(uid),
            "email": email.map(FirebasePayloadValue.string),
            "displayName": .string(displayName),
            "createdAt": .date(updatedAt),
            "localUserID": localUserID.map(FirebasePayloadValue.string),
            "updatedAt": .date(updatedAt)
        ])
    }
}

private extension BackendProfileSnapshot {
    nonisolated var firebasePayload: [String: FirebasePayloadValue] {
        [
            "displayName": .string(displayName),
            "promptIndex": .int(promptIndex),
            "updatedAt": .date(updatedAt)
        ]
    }
}

private extension JournalReflectionEntry {
    nonisolated var firebasePayload: [String: FirebasePayloadValue] {
        compactPayload([
            "entryID": .string(id.uuidString),
            "createdAt": .date(createdAt),
            "updatedAt": .date(lastEditedAt ?? createdAt),
            "durationSeconds": .int(durationSeconds),
            "transcript": .string(transcript),
            "engineName": .string(engineName),
            "sessionID": sessionID.map { .string($0.uuidString) },
            "editableTitle": editableTitle.map(FirebasePayloadValue.string),
            "editableEmotion": editableEmotion.map(FirebasePayloadValue.string),
            "privateNote": .string(privateNote),
            "tags": .stringArray(tags),
            "result": .dictionary(result.firebasePayload)
        ])
    }
}

private extension Quest {
    nonisolated var firebasePayload: [String: FirebasePayloadValue] {
        compactPayload([
            "questID": .string(id.uuidString),
            "title": .string(title),
            "detail": .string(detail),
            "sourceEntryID": sourceEntryID.map { .string($0.uuidString) },
            "createdAt": .date(createdAt),
            "completedAt": completedAt.map(FirebasePayloadValue.date),
            "status": .string(status.rawValue)
        ])
    }
}

private extension TipsPracticeSession {
    nonisolated var firebasePayload: [String: FirebasePayloadValue] {
        compactPayload([
            "sessionID": .string(id.uuidString),
            "createdAt": .date(createdAt),
            "updatedAt": .date(updatedAt),
            "originalMessage": .string(originalMessage),
            "scene": .string(scene.rawValue),
            "customScene": customScene.map(FirebasePayloadValue.string),
            "tone": .string(tone.rawValue),
            "situation": .string(situation),
            "attachedImageCount": .int(attachedImageCount),
            "turns": .dictionaryArray(turns.map(\.firebasePayload)),
            "coachOutput": .dictionary(coachOutput.firebasePayload)
        ])
    }
}

private extension TipsPracticeTurn {
    nonisolated var firebasePayload: [String: FirebasePayloadValue] {
        [
            "turnID": .string(id.uuidString),
            "role": .string(role.rawValue),
            "label": .string(label),
            "text": .string(text),
            "createdAt": .date(createdAt)
        ]
    }
}

private extension TipsCoachOutput {
    nonisolated var firebasePayload: [String: FirebasePayloadValue] {
        [
            "suggestedPhrasing": .string(suggestedPhrasing),
            "whyItWorks": .string(whyItWorks),
            "simulatedReply": .string(simulatedReply),
            "roomReading": .string(roomReading),
            "replyOptions": .dictionaryArray(replyOptions.map(\.firebasePayload))
        ]
    }
}

private extension TipsCoachReplyOption {
    nonisolated var firebasePayload: [String: FirebasePayloadValue] {
        [
            "optionID": .string(id.uuidString),
            "label": .string(label),
            "text": .string(text)
        ]
    }
}

private extension BackendRewardSnapshot {
    nonisolated var firebasePayload: [String: FirebasePayloadValue] {
        [
            "points": .int(points),
            "level": .int(level),
            "intoLevel": .int(intoLevel),
            "nextLevel": .int(nextLevel),
            "questAwards": .dictionary(questAwards.mapValues(FirebasePayloadValue.string)),
            "updatedAt": .date(updatedAt)
        ]
    }
}

private extension PointEntry {
    nonisolated var firebasePayload: [String: FirebasePayloadValue] {
        [
            "pointEntryID": .string(id.uuidString),
            "label": .string(label),
            "points": .int(points),
            "icon": .string(icon),
            "createdAt": .date(createdAt)
        ]
    }
}

private extension ActivityEvent {
    nonisolated var firebasePayload: [String: FirebasePayloadValue] {
        compactPayload([
            "activityEventID": .string(id.uuidString),
            "type": .string(type.rawValue),
            "title": .string(title),
            "keyword": .string(keyword),
            "refID": refID.map { .string($0.uuidString) },
            "createdAt": .date(createdAt)
        ])
    }
}

private extension AIReflectionSession {
    nonisolated var firebasePayload: [String: FirebasePayloadValue] {
        compactPayload([
            "sessionID": .string(id.uuidString),
            "createdAt": .date(createdAt),
            "updatedAt": .date(updatedAt),
            "entryID": entryID.map { .string($0.uuidString) },
            "engineName": .string(engineName),
            "source": .string(source.rawValue),
            "transcript": .string(transcript),
            "durationSeconds": .int(durationSeconds),
            "selectedAttemptID": selectedAttemptID.map { .string($0.uuidString) },
            "mergedSessionIDs": .stringArray(mergedSessionIDs.map(\.uuidString)),
            "attempts": .dictionaryArray(attempts.map(\.firebasePayload))
        ])
    }
}

private extension AIReflectionAttempt {
    nonisolated var firebasePayload: [String: FirebasePayloadValue] {
        compactPayload([
            "attemptID": .string(id.uuidString),
            "createdAt": .date(createdAt),
            "engineName": .string(engineName),
            "status": .string(status.rawValue),
            "result": result.map { .dictionary($0.firebasePayload) },
            "errorMessage": errorMessage.map(FirebasePayloadValue.string),
            "elapsedMilliseconds": elapsedMilliseconds.map(FirebasePayloadValue.int)
        ])
    }
}

private extension AIReflectionResult {
    nonisolated var firebasePayload: [String: FirebasePayloadValue] {
        [
            "title": .string(title),
            "emotion": .string(emotion),
            "summary": .string(summary),
            "insight": .string(insight),
            "expressionMoment": .string(expressionMoment),
            "quote": .string(quote),
            "confidenceScore": .double(confidenceScore),
            "suggestedQuest": .string(suggestedQuest)
        ]
    }
}

private enum FirebasePayloadReader {
    nonisolated static func string(_ data: [String: Any], _ key: String) -> String? {
        data[key] as? String
    }

    nonisolated static func int(_ data: [String: Any], _ key: String) -> Int? {
        switch data[key] {
        case let value as Int:
            return value
        case let value as NSNumber:
            return value.intValue
        case let value as Double:
            return Int(value)
        default:
            return nil
        }
    }

    nonisolated static func double(_ data: [String: Any], _ key: String) -> Double? {
        switch data[key] {
        case let value as Double:
            return value
        case let value as NSNumber:
            return value.doubleValue
        case let value as Int:
            return Double(value)
        default:
            return nil
        }
    }

    nonisolated static func date(_ data: [String: Any], _ key: String) -> Date? {
        switch data[key] {
        case let value as Date:
            return value
        case let value as Timestamp:
            return value.dateValue()
        case let value as TimeInterval:
            return Date(timeIntervalSince1970: value)
        case let value as NSNumber:
            return Date(timeIntervalSince1970: value.doubleValue)
        default:
            return nil
        }
    }

    nonisolated static func uuid(_ data: [String: Any], _ key: String) -> UUID? {
        string(data, key).flatMap(UUID.init(uuidString:))
    }

    nonisolated static func strings(_ data: [String: Any], _ key: String) -> [String] {
        data[key] as? [String] ?? []
    }

    nonisolated static func dictionary(_ data: [String: Any], _ key: String) -> [String: Any]? {
        data[key] as? [String: Any]
    }

    nonisolated static func dictionaries(_ data: [String: Any], _ key: String) -> [[String: Any]] {
        data[key] as? [[String: Any]] ?? []
    }
}

private extension BackendUserSnapshot {
    nonisolated init?(firebaseData data: [String: Any]) {
        guard let uid = FirebasePayloadReader.string(data, "uid"),
              let displayName = FirebasePayloadReader.string(data, "displayName") else {
            return nil
        }

        self.init(
            uid: uid,
            email: FirebasePayloadReader.string(data, "email"),
            displayName: displayName,
            localUserID: FirebasePayloadReader.string(data, "localUserID"),
            updatedAt: FirebasePayloadReader.date(data, "updatedAt") ?? Date()
        )
    }
}

private extension BackendProfileSnapshot {
    nonisolated init?(firebaseData data: [String: Any]) {
        guard let displayName = FirebasePayloadReader.string(data, "displayName"),
              let promptIndex = FirebasePayloadReader.int(data, "promptIndex") else {
            return nil
        }

        self.init(
            displayName: displayName,
            promptIndex: promptIndex,
            updatedAt: FirebasePayloadReader.date(data, "updatedAt") ?? Date()
        )
    }
}

private extension JournalReflectionEntry {
    nonisolated init?(firebaseData data: [String: Any]) {
        guard let id = FirebasePayloadReader.uuid(data, "entryID"),
              let createdAt = FirebasePayloadReader.date(data, "createdAt"),
              let durationSeconds = FirebasePayloadReader.int(data, "durationSeconds"),
              let transcript = FirebasePayloadReader.string(data, "transcript"),
              let engineName = FirebasePayloadReader.string(data, "engineName"),
              let resultData = FirebasePayloadReader.dictionary(data, "result"),
              let result = AIReflectionResult(firebaseData: resultData) else {
            return nil
        }

        self.init(
            id: id,
            createdAt: createdAt,
            durationSeconds: durationSeconds,
            transcript: transcript,
            engineName: engineName,
            result: result,
            sessionID: FirebasePayloadReader.uuid(data, "sessionID"),
            editableTitle: FirebasePayloadReader.string(data, "editableTitle"),
            editableEmotion: FirebasePayloadReader.string(data, "editableEmotion"),
            privateNote: FirebasePayloadReader.string(data, "privateNote") ?? "",
            tags: FirebasePayloadReader.strings(data, "tags"),
            lastEditedAt: FirebasePayloadReader.date(data, "updatedAt")
        )
    }
}

private extension Quest {
    nonisolated init?(firebaseData data: [String: Any]) {
        guard let id = FirebasePayloadReader.uuid(data, "questID"),
              let title = FirebasePayloadReader.string(data, "title"),
              let detail = FirebasePayloadReader.string(data, "detail"),
              let createdAt = FirebasePayloadReader.date(data, "createdAt"),
              let statusValue = FirebasePayloadReader.string(data, "status"),
              let status = QuestStatus(rawValue: statusValue) else {
            return nil
        }

        self.init(
            id: id,
            title: title,
            detail: detail,
            sourceEntryID: FirebasePayloadReader.uuid(data, "sourceEntryID"),
            createdAt: createdAt,
            completedAt: FirebasePayloadReader.date(data, "completedAt"),
            status: status
        )
    }
}

private extension TipsPracticeSession {
    nonisolated init?(firebaseData data: [String: Any]) {
        guard let id = FirebasePayloadReader.uuid(data, "sessionID"),
              let createdAt = FirebasePayloadReader.date(data, "createdAt"),
              let updatedAt = FirebasePayloadReader.date(data, "updatedAt"),
              let originalMessage = FirebasePayloadReader.string(data, "originalMessage"),
              let sceneValue = FirebasePayloadReader.string(data, "scene"),
              let scene = TipsPracticeScene(rawValue: sceneValue),
              let toneValue = FirebasePayloadReader.string(data, "tone"),
              let tone = TipsPracticeTone(rawValue: toneValue),
              let situation = FirebasePayloadReader.string(data, "situation"),
              let coachOutputData = FirebasePayloadReader.dictionary(data, "coachOutput"),
              let coachOutput = TipsCoachOutput(firebaseData: coachOutputData) else {
            return nil
        }

        self.init(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            originalMessage: originalMessage,
            scene: scene,
            customScene: FirebasePayloadReader.string(data, "customScene"),
            tone: tone,
            situation: situation,
            turns: FirebasePayloadReader.dictionaries(data, "turns").compactMap(TipsPracticeTurn.init(firebaseData:)),
            coachOutput: coachOutput,
            attachedImageCount: FirebasePayloadReader.int(data, "attachedImageCount") ?? 0
        )
    }
}

private extension TipsPracticeTurn {
    nonisolated init?(firebaseData data: [String: Any]) {
        guard let id = FirebasePayloadReader.uuid(data, "turnID"),
              let roleValue = FirebasePayloadReader.string(data, "role"),
              let role = TipsPracticeRole(rawValue: roleValue),
              let label = FirebasePayloadReader.string(data, "label"),
              let text = FirebasePayloadReader.string(data, "text"),
              let createdAt = FirebasePayloadReader.date(data, "createdAt") else {
            return nil
        }

        self.init(id: id, role: role, label: label, text: text, createdAt: createdAt)
    }
}

private extension TipsCoachOutput {
    nonisolated init?(firebaseData data: [String: Any]) {
        guard let suggestedPhrasing = FirebasePayloadReader.string(data, "suggestedPhrasing"),
              let whyItWorks = FirebasePayloadReader.string(data, "whyItWorks"),
              let simulatedReply = FirebasePayloadReader.string(data, "simulatedReply"),
              let roomReading = FirebasePayloadReader.string(data, "roomReading") else {
            return nil
        }

        self.init(
            suggestedPhrasing: suggestedPhrasing,
            whyItWorks: whyItWorks,
            simulatedReply: simulatedReply,
            roomReading: roomReading,
            replyOptions: FirebasePayloadReader.dictionaries(data, "replyOptions").compactMap(TipsCoachReplyOption.init(firebaseData:))
        )
    }
}

private extension TipsCoachReplyOption {
    nonisolated init?(firebaseData data: [String: Any]) {
        guard let id = FirebasePayloadReader.uuid(data, "optionID"),
              let label = FirebasePayloadReader.string(data, "label"),
              let text = FirebasePayloadReader.string(data, "text") else {
            return nil
        }

        self.init(id: id, label: label, text: text)
    }
}

private extension BackendRewardSnapshot {
    nonisolated init?(firebaseData data: [String: Any]) {
        guard let points = FirebasePayloadReader.int(data, "points"),
              let level = FirebasePayloadReader.int(data, "level"),
              let intoLevel = FirebasePayloadReader.int(data, "intoLevel"),
              let nextLevel = FirebasePayloadReader.int(data, "nextLevel") else {
            return nil
        }

        self.init(
            points: points,
            level: level,
            intoLevel: intoLevel,
            nextLevel: nextLevel,
            questAwards: data["questAwards"] as? [String: String] ?? [:],
            updatedAt: FirebasePayloadReader.date(data, "updatedAt") ?? Date()
        )
    }
}

private extension PointEntry {
    nonisolated init?(firebaseData data: [String: Any]) {
        guard let id = FirebasePayloadReader.uuid(data, "pointEntryID"),
              let label = FirebasePayloadReader.string(data, "label"),
              let points = FirebasePayloadReader.int(data, "points"),
              let icon = FirebasePayloadReader.string(data, "icon"),
              let createdAt = FirebasePayloadReader.date(data, "createdAt") else {
            return nil
        }

        self.init(id: id, label: label, points: points, icon: icon, createdAt: createdAt)
    }
}

private extension ActivityEvent {
    nonisolated init?(firebaseData data: [String: Any]) {
        guard let id = FirebasePayloadReader.uuid(data, "activityEventID"),
              let typeValue = FirebasePayloadReader.string(data, "type"),
              let type = ActivityType(rawValue: typeValue),
              let title = FirebasePayloadReader.string(data, "title"),
              let keyword = FirebasePayloadReader.string(data, "keyword"),
              let createdAt = FirebasePayloadReader.date(data, "createdAt") else {
            return nil
        }

        self.init(
            id: id,
            type: type,
            title: title,
            keyword: keyword,
            refID: FirebasePayloadReader.uuid(data, "refID"),
            createdAt: createdAt
        )
    }
}

private extension AIReflectionSession {
    nonisolated init?(firebaseData data: [String: Any]) {
        guard let id = FirebasePayloadReader.uuid(data, "sessionID"),
              let createdAt = FirebasePayloadReader.date(data, "createdAt"),
              let updatedAt = FirebasePayloadReader.date(data, "updatedAt"),
              let engineName = FirebasePayloadReader.string(data, "engineName"),
              let sourceValue = FirebasePayloadReader.string(data, "source"),
              let source = AIReflectionSource(rawValue: sourceValue),
              let transcript = FirebasePayloadReader.string(data, "transcript"),
              let durationSeconds = FirebasePayloadReader.int(data, "durationSeconds") else {
            return nil
        }

        self.init(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            entryID: FirebasePayloadReader.uuid(data, "entryID"),
            engineName: engineName,
            source: source,
            transcript: transcript,
            durationSeconds: durationSeconds,
            attempts: FirebasePayloadReader.dictionaries(data, "attempts").compactMap(AIReflectionAttempt.init(firebaseData:)),
            selectedAttemptID: FirebasePayloadReader.uuid(data, "selectedAttemptID"),
            mergedSessionIDs: FirebasePayloadReader.strings(data, "mergedSessionIDs").compactMap(UUID.init(uuidString:))
        )
    }
}

private extension AIReflectionAttempt {
    nonisolated init?(firebaseData data: [String: Any]) {
        guard let id = FirebasePayloadReader.uuid(data, "attemptID"),
              let createdAt = FirebasePayloadReader.date(data, "createdAt"),
              let engineName = FirebasePayloadReader.string(data, "engineName"),
              let statusValue = FirebasePayloadReader.string(data, "status"),
              let status = AIReflectionAttemptStatus(rawValue: statusValue) else {
            return nil
        }

        let result = FirebasePayloadReader.dictionary(data, "result").flatMap(AIReflectionResult.init(firebaseData:))
        self.init(
            id: id,
            createdAt: createdAt,
            engineName: engineName,
            status: status,
            result: result,
            errorMessage: FirebasePayloadReader.string(data, "errorMessage"),
            elapsedMilliseconds: FirebasePayloadReader.int(data, "elapsedMilliseconds")
        )
    }
}

private extension AIReflectionResult {
    nonisolated init?(firebaseData data: [String: Any]) {
        guard let title = FirebasePayloadReader.string(data, "title"),
              let emotion = FirebasePayloadReader.string(data, "emotion"),
              let summary = FirebasePayloadReader.string(data, "summary"),
              let insight = FirebasePayloadReader.string(data, "insight"),
              let expressionMoment = FirebasePayloadReader.string(data, "expressionMoment"),
              let quote = FirebasePayloadReader.string(data, "quote"),
              let confidenceScore = FirebasePayloadReader.double(data, "confidenceScore"),
              let suggestedQuest = FirebasePayloadReader.string(data, "suggestedQuest") else {
            return nil
        }

        self.init(
            title: title,
            emotion: emotion,
            summary: summary,
            insight: insight,
            expressionMoment: expressionMoment,
            quote: quote,
            confidenceScore: confidenceScore,
            suggestedQuest: suggestedQuest
        )
    }
}

nonisolated private func compactPayload(_ values: [String: FirebasePayloadValue?]) -> [String: FirebasePayloadValue] {
    values.reduce(into: [:]) { result, item in
        guard let value = item.value else { return }
        result[item.key] = value
    }
}
