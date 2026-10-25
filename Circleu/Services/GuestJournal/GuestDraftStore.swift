import Foundation

/// A draft read back from this phone, and whether its protection could be confirmed.
nonisolated struct KeptDraft: Equatable, Sendable {
    let id: UUID
    let text: String
    let isProtected: Bool
}

/// Keeps the unsaved Write draft on this phone so it survives leaving the app or a relaunch.
/// Each draft has an ID; once saved as an entry, the journal store remembers that ID.
nonisolated protocol GuestDraftStore: Sendable {
    /// The kept draft, or nil if there is none. Throws `storeUnavailable` if a draft exists but
    /// can't be read; the file is then left untouched.
    func load() async throws -> KeptDraft?
    /// Replaces the kept draft; empty text removes it. Throws `saveFailed` if nothing was
    /// written, or `protectionFailed` if the text was kept but protection couldn't be confirmed.
    func save(id: UUID, text: String) async throws
    /// Removes the kept draft only if it is still the draft with this ID.
    func remove(id: UUID) async throws
}

/// One protected JSON file next to the journal store. An actor, so operations apply in order.
actor FileGuestDraftStore: GuestDraftStore {
    private struct File: Codable {
        let id: UUID
        let text: String
    }

    private let url: URL
    private let protection: GuestJournalFileProtection

    /// `fileName` separates kinds of draft: the Write draft ("Draft.json") and Practice's.
    init(location: GuestJournalLocation, fileName: String = "Draft.json",
         protection: GuestJournalFileProtection = .completeUnlessOpen) {
        url = location.directory.appendingPathComponent(fileName)
        self.protection = protection
    }

    func load() throws -> KeptDraft? {
        guard let file = try readFile() else { return nil }
        let isProtected = (try? protection.apply(url)) != nil
        return KeptDraft(id: file.id, text: file.text, isProtected: isProtected)
    }

    func save(id: UUID, text: String) throws {
        if text.isEmpty { return try deleteFile() }
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(File(id: id, text: text))
            // Protected as it's written (on iOS), then confirmed below.
            #if os(iOS)
            try data.write(to: url, options: [.atomic, .completeFileProtectionUnlessOpen])
            #else
            try data.write(to: url, options: .atomic)
            #endif
        } catch {
            throw GuestJournalError.saveFailed("draft: \(error.localizedDescription)")
        }
        do { try protection.apply(url) } catch {
            throw GuestJournalError.protectionFailed("draft") // The text is kept.
        }
    }

    func remove(id: UUID) throws {
        // Leave a newer draft (another ID) alone. An unreadable file is also left alone.
        guard let file = try? readFile(), file.id == id else { return }
        try deleteFile()
    }

    private func readFile() throws -> File? {
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile || error.code == .fileNoSuchFile {
            return nil
        } catch {
            throw GuestJournalError.storeUnavailable("draft: \(error.localizedDescription)")
        }
        do { return try JSONDecoder().decode(File.self, from: data) } catch {
            throw GuestJournalError.storeUnavailable("draft: unreadable")
        }
    }

    private func deleteFile() throws {
        do {
            if FileManager.default.fileExists(atPath: url.path) { try FileManager.default.removeItem(at: url) }
        } catch {
            throw GuestJournalError.saveFailed("draft: \(error.localizedDescription)")
        }
    }
}
