import Combine
import Foundation

@MainActor
final class UserProfileStore: ObservableObject {
    @Published var displayName: String {
        didSet {
            guard !isReloadingFromBackend else { return }
            saveDisplayName(displayName)
        }
    }

    @Published var dailyPromptIndex: Int {
        didSet {
            guard !isReloadingFromBackend else { return }
            userDefaults.set(dailyPromptIndex, forKey: dailyPromptIndexKey)
        }
    }

    @Published var isCloudAIEnabled: Bool {
        didSet {
            guard !isReloadingFromBackend else { return }
            userDefaults.set(isCloudAIEnabled, forKey: isCloudAIEnabledKey)
        }
    }

    @Published var hasConsentedToCloudAI: Bool {
        didSet {
            guard !isReloadingFromBackend else { return }
            userDefaults.set(hasConsentedToCloudAI, forKey: hasConsentedToCloudAIKey)
        }
    }

    private let userDefaults: UserDefaults
    private let baseDisplayNameKey = "circleu.profile.displayName.v1"
    private let baseDailyPromptIndexKey = "circleu.profile.dailyPromptIndex.v1"
    private let baseIsCloudAIEnabledKey = "circleu.settings.isCloudAIEnabled.v1"
    private let baseHasConsentedToCloudAIKey = "circleu.settings.hasConsentedToCloudAI.v1"

    /// Firebase UID for the active session.
    private var currentUserID: String?

    private var displayNameKey: String {
        guard let uid = currentUserID, !uid.isEmpty else { return baseDisplayNameKey }
        return "\(baseDisplayNameKey).user.\(uid)"
    }

    private var dailyPromptIndexKey: String {
        guard let uid = currentUserID, !uid.isEmpty else { return baseDailyPromptIndexKey }
        return "\(baseDailyPromptIndexKey).user.\(uid)"
    }

    private var isCloudAIEnabledKey: String {
        guard let uid = currentUserID, !uid.isEmpty else { return baseIsCloudAIEnabledKey }
        return "\(baseIsCloudAIEnabledKey).user.\(uid)"
    }

    private var hasConsentedToCloudAIKey: String {
        guard let uid = currentUserID, !uid.isEmpty else { return baseHasConsentedToCloudAIKey }
        return "\(baseHasConsentedToCloudAIKey).user.\(uid)"
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        let savedName = userDefaults.string(forKey: baseDisplayNameKey) ?? ""
        displayName = savedName.trimmingCharacters(in: .whitespacesAndNewlines)
        dailyPromptIndex = userDefaults.integer(forKey: baseDailyPromptIndexKey)
        isCloudAIEnabled = userDefaults.object(forKey: baseIsCloudAIEnabledKey) as? Bool ?? false
        hasConsentedToCloudAI = userDefaults.bool(forKey: baseHasConsentedToCloudAIKey)
    }

    // MARK: - Backend wiring

    func configureBackend(uid: String) {
        guard !uid.isEmpty, currentUserID != uid else { return }
        currentUserID = uid
        loadFromCurrentScope()
    }

    func teardownBackend() {
        guard currentUserID != nil else { return }
        currentUserID = nil
        loadFromCurrentScope()
    }

    /// Reload the published properties from the current scope's keys. Uses a flag to
    /// suppress the didSet writers so we don't accidentally re-save the old values
    /// into the new bucket while assigning.
    private func loadFromCurrentScope() {
        isReloadingFromBackend = true
        defer { isReloadingFromBackend = false }
        let savedName = userDefaults.string(forKey: displayNameKey) ?? ""
        displayName = savedName.trimmingCharacters(in: .whitespacesAndNewlines)
        dailyPromptIndex = userDefaults.integer(forKey: dailyPromptIndexKey)
        isCloudAIEnabled = userDefaults.object(forKey: isCloudAIEnabledKey) as? Bool ?? false
        hasConsentedToCloudAI = userDefaults.bool(forKey: hasConsentedToCloudAIKey)
    }

    /// Set while reloading from a different scope's keys so the didSet persistence
    /// hooks don't overwrite the new bucket with the same values they just read.
    private var isReloadingFromBackend = false
 
    var firstName: String {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmed.split(separator: " ").first else { return "friend" }
        return String(first)
    }

    var hasDisplayName: Bool {
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func updateDisplayName(_ value: String) {
        displayName = sanitizedName(value)
    }

    func mergeRestoredProfile(_ profile: BackendProfileSnapshot?) {
        guard let profile else { return }
        let restoredName = sanitizedName(profile.displayName)
        if !restoredName.isEmpty && !hasDisplayName {
            displayName = restoredName
        }
        dailyPromptIndex = max(dailyPromptIndex, profile.promptIndex)
    }

    func reset() {
        displayName = ""
        dailyPromptIndex = 0
        isCloudAIEnabled = false
        hasConsentedToCloudAI = false
        userDefaults.removeObject(forKey: displayNameKey)
        userDefaults.removeObject(forKey: dailyPromptIndexKey)
        userDefaults.removeObject(forKey: isCloudAIEnabledKey)
        userDefaults.removeObject(forKey: hasConsentedToCloudAIKey)
    }

    func seedDemoProfile() {
        updateDisplayName("Mike")
        dailyPromptIndex = 1
    }

    func advanceDailyPrompt(totalPrompts: Int) {
        guard totalPrompts > 0 else { return }
        dailyPromptIndex = (dailyPromptIndex + 1) % totalPrompts
    }

    func summaryText(progress: AppProgressSnapshot, circleCount: Int, supportPostCount: Int) -> String {
        """
        Circleu Local Profile

        Name: \(displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Friend" : displayName)
        Level: \(progress.level)
        XP: \(progress.xp)
        Saved reflections: \(progress.entryCount)
        Current streak: \(progress.streak)
        Most common mood: \(progress.mostCommonEmotion)
        Communities: \(circleCount)
        Support posts: \(supportPostCount)
        Completed quests: \(progress.completedQuestCount)

        Circleu stores this data locally on this iPhone.
        """
    }

    private func sanitizedName(_ value: String) -> String {
        let collapsed = value
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
        return String(collapsed.prefix(32))
    }

    private func saveDisplayName(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        userDefaults.set(trimmed, forKey: displayNameKey)
    }
}
