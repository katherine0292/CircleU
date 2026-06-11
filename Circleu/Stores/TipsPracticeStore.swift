import Combine
import Foundation

@MainActor
final class TipsPracticeStore: ObservableObject {
    @Published var draftMessage = ""
    @Published var draftScene: TipsPracticeScene = .workplace
    @Published var draftCustomScene = ""
    @Published var draftTone: TipsPracticeTone = .diplomatic
    @Published var draftSituation = ""
    @Published var currentSession: TipsPracticeSession?
    @Published private(set) var recentSessions: [TipsPracticeSession] = []

    private let baseStorageKey = "circleu.tipsPractice.sessions.v1"
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    /// Firebase UID for the active session. Practice transcripts can include personal
    /// scenarios, so each account gets its own bucket.
    private var currentUserID: String?

    private var storageKey: String {
        guard let uid = currentUserID, !uid.isEmpty else { return baseStorageKey }
        return "\(baseStorageKey).user.\(uid)"
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        load()
    }

    // MARK: - Backend wiring

    func configureBackend(uid: String) {
        guard !uid.isEmpty, currentUserID != uid else { return }
        currentUserID = uid
        currentSession = nil
        recentSessions = []
        load()
    }

    func teardownBackend() {
        guard currentUserID != nil else { return }
        currentUserID = nil
        currentSession = nil
        recentSessions = []
        load()
    }

    func saveDraft(
        message: String,
        scene: TipsPracticeScene,
        customScene: String,
        tone: TipsPracticeTone,
        situation: String
    ) {
        draftMessage = message
        draftScene = scene
        draftCustomScene = customScene
        draftTone = tone
        draftSituation = situation
    }

    func activate(_ session: TipsPracticeSession) {
        currentSession = session
        upsertRecent(session)
    }

    func updateCurrentSession(_ session: TipsPracticeSession) {
        currentSession = session
        upsertRecent(session)
    }

    func resume(_ session: TipsPracticeSession) {
        var resumedSession = session
        resumedSession.updatedAt = Date()
        currentSession = resumedSession
        upsertRecent(resumedSession)
    }

    func delete(_ session: TipsPracticeSession) {
        recentSessions.removeAll { $0.id == session.id }
        if currentSession?.id == session.id {
            currentSession = nil
        }
        save()
    }

    func mergeRestoredSessions(_ restoredSessions: [TipsPracticeSession]) {
        guard !restoredSessions.isEmpty else { return }
        var merged = Dictionary(uniqueKeysWithValues: recentSessions.map { ($0.id, $0) })

        for restoredSession in restoredSessions {
            if let localSession = merged[restoredSession.id] {
                merged[restoredSession.id] = restoredSession.updatedAt > localSession.updatedAt ? restoredSession : localSession
            } else {
                merged[restoredSession.id] = restoredSession
            }
        }

        recentSessions = Array(merged.values.sorted { $0.updatedAt > $1.updatedAt }.prefix(12))
        save()
    }

    func clearCurrentSession() {
        currentSession = nil
    }

    func resetDraft() {
        draftMessage = ""
        draftScene = .workplace
        draftCustomScene = ""
        draftTone = .diplomatic
        draftSituation = ""
        currentSession = nil
    }

    func resetAll() {
        resetDraft()
        recentSessions = []
        userDefaults.removeObject(forKey: storageKey)
    }

    private func upsertRecent(_ session: TipsPracticeSession) {
        recentSessions.removeAll { $0.id == session.id }
        recentSessions.insert(session, at: 0)
        recentSessions = Array(recentSessions.prefix(12))
        save()
    }

    private func load() {
        guard let data = userDefaults.data(forKey: storageKey),
              let sessions = try? decoder.decode([TipsPracticeSession].self, from: data) else {
            recentSessions = []
            return
        }

        recentSessions = sessions.sorted { $0.updatedAt > $1.updatedAt }
    }

    private func save() {
        guard let data = try? encoder.encode(recentSessions) else { return }
        userDefaults.set(data, forKey: storageKey)
    }
}
