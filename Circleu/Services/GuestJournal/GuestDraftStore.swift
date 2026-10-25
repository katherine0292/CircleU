import Foundation

/// Keeps the unsaved Write draft on this phone so it survives leaving the app or a relaunch.
nonisolated protocol GuestDraftStore: Sendable {
    /// The kept draft, or nil if there is none. Throws if a draft exists but can't be read.
    func load() async throws -> String?
    /// Replaces the kept draft; an empty draft removes it.
    func save(_ text: String) async throws
}

/// One protected text file next to the journal store. An actor, so saves apply in order.
actor FileGuestDraftStore: GuestDraftStore {
    private let url: URL
    private let protection: GuestJournalFileProtection

    init(location: GuestJournalLocation, protection: GuestJournalFileProtection = .completeUnlessOpen) {
        url = location.directory.appendingPathComponent("Draft.txt")
        self.protection = protection
    }

    func load() throws -> String? {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile || error.code == .fileNoSuchFile {
            return nil
        } catch {
            throw GuestJournalError.storeUnavailable("draft: \(error.localizedDescription)")
        }
    }

    func save(_ text: String) throws {
        do {
            if text.isEmpty {
                if FileManager.default.fileExists(atPath: url.path) { try FileManager.default.removeItem(at: url) }
                return
            }
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try Data(text.utf8).write(to: url, options: .atomic)
            try protection.apply(url)
        } catch {
            throw GuestJournalError.saveFailed("draft: \(error.localizedDescription)")
        }
    }
}
