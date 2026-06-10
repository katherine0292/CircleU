import Foundation

struct BackendSyncSnapshot: Codable, Equatable {
    var userID: String
    var generatedAt: Date
    var user: BackendUserSnapshot?
    var profile: BackendProfileSnapshot?
    var journalEntries: [JournalReflectionEntry]
    var quests: [Quest]
    var tipsPracticeSessions: [TipsPracticeSession]
    var rewardState: BackendRewardSnapshot?
    var pointEntries: [PointEntry]
    var activityEvents: [ActivityEvent]
    var circles: [CircleSpace]
    var circlePosts: [CirclePost]
    var aiSessions: [AIReflectionSession]

    nonisolated init(
        userID: String,
        generatedAt: Date = Date(),
        user: BackendUserSnapshot? = nil,
        profile: BackendProfileSnapshot? = nil,
        journalEntries: [JournalReflectionEntry],
        quests: [Quest],
        tipsPracticeSessions: [TipsPracticeSession] = [],
        rewardState: BackendRewardSnapshot? = nil,
        pointEntries: [PointEntry] = [],
        activityEvents: [ActivityEvent] = [],
        circles: [CircleSpace],
        circlePosts: [CirclePost],
        aiSessions: [AIReflectionSession]
    ) {
        self.userID = userID
        self.generatedAt = generatedAt
        self.user = user
        self.profile = profile
        self.journalEntries = journalEntries
        self.quests = quests
        self.tipsPracticeSessions = tipsPracticeSessions
        self.rewardState = rewardState
        self.pointEntries = pointEntries
        self.activityEvents = activityEvents
        self.circles = circles
        self.circlePosts = circlePosts
        self.aiSessions = aiSessions
    }

    nonisolated var counts: BackendSyncCounts {
        BackendSyncCounts(snapshot: self)
    }

    nonisolated var isEmpty: Bool {
        guard case nil = user, case nil = profile, case nil = rewardState else {
            return false
        }

        return counts.journalEntryCount == 0
            && counts.questCount == 0
            && counts.tipsPracticeSessionCount == 0
            && counts.pointEntryCount == 0
            && counts.activityEventCount == 0
            && counts.circleCount == 0
            && counts.circlePostCount == 0
            && counts.aiSessionCount == 0
    }
}

struct BackendUserSnapshot: Codable, Equatable {
    var uid: String
    var email: String?
    var displayName: String
    var localUserID: String?
    var updatedAt: Date

    nonisolated init(uid: String, email: String?, displayName: String, localUserID: String?, updatedAt: Date) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
        self.localUserID = localUserID
        self.updatedAt = updatedAt
    }
}

struct BackendProfileSnapshot: Codable, Equatable {
    var displayName: String
    var promptIndex: Int
    var updatedAt: Date

    nonisolated init(displayName: String, promptIndex: Int, updatedAt: Date) {
        self.displayName = displayName
        self.promptIndex = promptIndex
        self.updatedAt = updatedAt
    }
}

struct BackendRewardSnapshot: Codable, Equatable {
    var points: Int
    var level: Int
    var intoLevel: Int
    var nextLevel: Int
    var questAwards: [String: String]
    var updatedAt: Date

    nonisolated init(
        points: Int,
        level: Int,
        intoLevel: Int,
        nextLevel: Int,
        questAwards: [String: String],
        updatedAt: Date
    ) {
        self.points = points
        self.level = level
        self.intoLevel = intoLevel
        self.nextLevel = nextLevel
        self.questAwards = questAwards
        self.updatedAt = updatedAt
    }
}

struct BackendSyncCounts: Codable, Equatable {
    var journalEntryCount: Int
    var questCount: Int
    var tipsPracticeSessionCount: Int
    var pointEntryCount: Int
    var activityEventCount: Int
    var circleCount: Int
    var circlePostCount: Int
    var aiSessionCount: Int

    nonisolated static let zero = BackendSyncCounts(
        journalEntryCount: 0,
        questCount: 0,
        tipsPracticeSessionCount: 0,
        pointEntryCount: 0,
        activityEventCount: 0,
        circleCount: 0,
        circlePostCount: 0,
        aiSessionCount: 0
    )

    nonisolated init(
        journalEntryCount: Int,
        questCount: Int,
        tipsPracticeSessionCount: Int = 0,
        pointEntryCount: Int = 0,
        activityEventCount: Int = 0,
        circleCount: Int,
        circlePostCount: Int,
        aiSessionCount: Int
    ) {
        self.journalEntryCount = journalEntryCount
        self.questCount = questCount
        self.tipsPracticeSessionCount = tipsPracticeSessionCount
        self.pointEntryCount = pointEntryCount
        self.activityEventCount = activityEventCount
        self.circleCount = circleCount
        self.circlePostCount = circlePostCount
        self.aiSessionCount = aiSessionCount
    }

    nonisolated init(snapshot: BackendSyncSnapshot) {
        self.init(
            journalEntryCount: snapshot.journalEntries.count,
            questCount: snapshot.quests.count,
            tipsPracticeSessionCount: snapshot.tipsPracticeSessions.count,
            pointEntryCount: snapshot.pointEntries.count,
            activityEventCount: snapshot.activityEvents.count,
            circleCount: snapshot.circles.count,
            circlePostCount: snapshot.circlePosts.count,
            aiSessionCount: snapshot.aiSessions.count
        )
    }
}

enum BackendSyncScope: String, Codable, Equatable, CaseIterable {
    case user
    case profile
    case journalEntries
    case quests
    case tipsPracticeSessions
    case rewardState
    case pointEntries
    case activityEvents
    case circles
    case circlePosts
    case aiSessions
}

struct BackendSyncResult: Codable, Equatable {
    var syncedAt: Date
    var uploadedCounts: BackendSyncCounts
    var downloadedCounts: BackendSyncCounts
    var failedScopes: [BackendSyncScope]

    nonisolated init(
        syncedAt: Date = Date(),
        uploadedCounts: BackendSyncCounts = .zero,
        downloadedCounts: BackendSyncCounts = .zero,
        failedScopes: [BackendSyncScope] = []
    ) {
        self.syncedAt = syncedAt
        self.uploadedCounts = uploadedCounts
        self.downloadedCounts = downloadedCounts
        self.failedScopes = failedScopes
    }

    nonisolated var didSucceed: Bool {
        failedScopes.isEmpty
    }
}

struct AnalyticsEvent: Codable, Equatable {
    var name: String
    var properties: [String: String]
    var createdAt: Date

    nonisolated init(name: String, properties: [String: String] = [:], createdAt: Date = Date()) {
        let cleanName = name
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: "_")
            .lowercased()
        self.name = cleanName.isEmpty ? "local_event" : String(cleanName.prefix(80))
        self.properties = properties.reduce(into: [:]) { result, item in
            let key = item.key.trimmingCharacters(in: .whitespacesAndNewlines)
            let value = item.value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !key.isEmpty, !value.isEmpty else { return }
            result[String(key.prefix(80))] = String(value.prefix(240))
        }
        self.createdAt = createdAt
    }
}

nonisolated protocol ReflectionModelProvider {
    var providerName: String { get }
    var isAvailable: Bool { get }
    var availabilityReason: String? { get }
    var supportsOnDeviceProcessing: Bool { get }
}

nonisolated protocol ReflectionSyncing {
    func sync(_ snapshot: BackendSyncSnapshot) async throws -> BackendSyncResult
}

nonisolated protocol ReflectionBackupRestoring {
    func restorePrivateBackup(userID: String) async throws -> BackendSyncSnapshot
}

nonisolated protocol UserIdentityProviding {
    var localUserID: String { get }
    var displayName: String { get }
}

nonisolated protocol AnalyticsTracking {
    func track(_ event: AnalyticsEvent)
}

struct LocalReflectionModelProvider: ReflectionModelProvider {
    nonisolated let providerName = "Local"
    nonisolated let isAvailable = true
    nonisolated let availabilityReason: String? = nil
    nonisolated let supportsOnDeviceProcessing = true
}

struct NoOpReflectionSyncer: ReflectionSyncing, ReflectionBackupRestoring {
    nonisolated func sync(_ snapshot: BackendSyncSnapshot) async throws -> BackendSyncResult {
        BackendSyncResult()
    }

    nonisolated func restorePrivateBackup(userID: String) async throws -> BackendSyncSnapshot {
        BackendSyncSnapshot(
            userID: userID,
            journalEntries: [],
            quests: [],
            circles: [],
            circlePosts: [],
            aiSessions: []
        )
    }
}

struct LocalUserIdentityProvider: UserIdentityProviding {
    nonisolated(unsafe) private let defaults: UserDefaults

    nonisolated init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    nonisolated var localUserID: String {
        let key = "circleu.localUserID"

        if let existingID = defaults.string(forKey: key) {
            return existingID
        }

        let newID = UUID().uuidString
        defaults.set(newID, forKey: key)
        return newID
    }

    nonisolated var displayName: String {
        let savedName = defaults
            .string(forKey: "circleu.profile.displayName.v1")?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return savedName.isEmpty ? "Friend" : savedName
    }
}

struct NoOpAnalyticsTracker: AnalyticsTracking {
    nonisolated func track(_ event: AnalyticsEvent) {}
}

extension AnalyticsTracking {
    nonisolated func track(event: String, properties: [String: String] = [:]) {
        track(AnalyticsEvent(name: event, properties: properties))
    }
}
