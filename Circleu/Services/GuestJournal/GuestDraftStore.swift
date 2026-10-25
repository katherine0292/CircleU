import Foundation

/// A draft read back from this phone, and whether its protection could be confirmed.
nonisolated struct KeptDraft: Equatable, Sendable {
    let text: String
    let isProtected: Bool
}

/// Keeps the unsaved Write draft on this phone so it survives leaving the app or a relaunch.
nonisolated protocol GuestDraftStore: Sendable {
    /// The kept draft, or nil if there is none. Throws `storeUnavailable` if a draft exists but
    /// can't be read; the file is then left untouched.
    func load() async throws -> KeptDraft?
    /// Replaces the kept draft; an empty draft removes it. Throws `saveFailed` if nothing was
    /// written, or `protectionFailed` if the text was kept but protection couldn't be confirmed.
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

    func load() throws -> KeptDraft? {
        let text: String
        do {
            text = try String(contentsOf: url, encoding: .utf8)
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile || error.code == .fileNoSuchFile {
            return nil
        } catch {
            throw GuestJournalError.storeUnavailable("draft: \(error.localizedDescription)")
        }
        let isProtected = (try? verifyProtection()) != nil
        return KeptDraft(text: text, isProtected: isProtected)
    }

    /// Re-applies protection to an existing draft. The text is kept either way.
    private func verifyProtection() throws {
        do { try protection.apply(url) } catch {
            throw GuestJournalError.protectionFailed("draft")
        }
    }

    func save(_ text: String) throws {
        do {
            if text.isEmpty {
                if FileManager.default.fileExists(atPath: url.path) { try FileManager.default.removeItem(at: url) }
                return
            }
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            // Protected as it's written (on iOS), then confirmed below.
            #if os(iOS)
            try Data(text.utf8).write(to: url, options: [.atomic, .completeFileProtectionUnlessOpen])
            #else
            try Data(text.utf8).write(to: url, options: .atomic)
            #endif
        } catch {
            throw GuestJournalError.saveFailed("draft: \(error.localizedDescription)")
        }
        try verifyProtection() // The text is kept even if this fails; callers say so accurately.
    }
}
