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
    /// Delete all, step 1: moves any kept draft aside (reversibly) under an ID (its own, or a new
    /// one if it can't be read) and returns that ID, so the delete transaction can mark it
    /// consumed. Throws if it can't.
    func stageRemoval() async throws -> UUID?
    /// Delete all, step 2: deletes the staged copy (`true`) or puts it back (`false`).
    func finishRemoval(commit: Bool) async throws
    /// At launch, before `load`: settles copies left by an interrupted Delete all. `isConsumed`
    /// returns true (deleted: remove the copy), false (not deleted: put it back) or nil (unknown:
    /// leave it). Returns false if anything was left unsettled; then nothing may be written.
    func recoverStaged(isConsumed: @escaping @Sendable (UUID) async -> Bool?) async throws -> Bool
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

    private var stagePrefix: String { url.lastPathComponent + ".deleting-" }
    private func stagedURL(_ id: UUID) -> URL {
        url.deletingLastPathComponent().appendingPathComponent(stagePrefix + id.uuidString)
    }
    /// The copy staged in this run.
    private var stagedID: UUID?

    func stageRemoval() throws -> UUID? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        // An unreadable draft gets a new ID so the delete decision still covers it.
        let id = (try? readFile()?.id) ?? UUID()
        do { try FileManager.default.moveItem(at: url, to: stagedURL(id)) } catch {
            throw GuestJournalError.saveFailed("draft: \(error.localizedDescription)")
        }
        stagedID = id
        return id
    }

    func finishRemoval(commit: Bool) throws {
        guard let id = stagedID else { return }
        try settle(stagedURL(id), delete: commit)
        stagedID = nil
    }

    func recoverStaged(isConsumed: @escaping @Sendable (UUID) async -> Bool?) async throws -> Bool {
        let folder = url.deletingLastPathComponent()
        let names = (try? FileManager.default.contentsOfDirectory(atPath: folder.path)) ?? []
        var settled = true
        for name in names where name.hasPrefix(stagePrefix) {
            guard let id = UUID(uuidString: String(name.dropFirst(stagePrefix.count))) else { continue }
            switch await isConsumed(id) {
            case true?: try settle(folder.appendingPathComponent(name), delete: true)
            case false?: try settle(folder.appendingPathComponent(name), delete: false)
            case nil: settled = false // Unknown: leave it, and write nothing over it.
            }
        }
        return settled
    }

    /// Deletes a staged copy, or puts it back. Never overwrites a draft that's already there.
    private func settle(_ staged: URL, delete: Bool) throws {
        guard FileManager.default.fileExists(atPath: staged.path) else { return }
        do {
            if delete {
                try FileManager.default.removeItem(at: staged)
            } else if FileManager.default.fileExists(atPath: url.path) {
                throw GuestJournalError.saveFailed("draft: a newer draft is in the way")
            } else {
                try FileManager.default.moveItem(at: staged, to: url)
            }
        } catch let error as GuestJournalError {
            throw error
        } catch {
            throw GuestJournalError.saveFailed("draft: \(error.localizedDescription)")
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
