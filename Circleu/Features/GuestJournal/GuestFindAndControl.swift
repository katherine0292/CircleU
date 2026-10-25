import Combine
import SwiftUI
import UIKit

// MARK: - Search

enum GuestSearch {
    /// Case- and accent-insensitive match on everything the person can read in an entry.
    static func matches(_ entry: GuestJournalEntry, _ query: String) -> Bool {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }
        let fields = [entry.originalWords, entry.reflection?.summary, entry.reflection?.feeling,
                      entry.reflection?.insight, entry.nextStep].compactMap { $0 }
        return fields.contains { $0.localizedStandardContains(query) }
    }

    static func matches(_ message: GuestPracticeMessage, _ query: String) -> Bool {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }
        return [message.situation, message.goal, message.wording].contains { $0.localizedStandardContains(query) }
    }
}

// MARK: - Calendar

/// One cell of a month grid: a day of this month (with how many entries were written), or padding.
struct GuestCalendarDay: Identifiable, Equatable {
    let id: Int
    let date: Date?
    let entryCount: Int
}

enum GuestCalendarModel {
    /// The days of `month` laid out from the calendar's first weekday, with entry counts by the
    /// day each entry was created.
    static func days(in month: Date, entries: [GuestJournalEntry], calendar: Calendar = .current) -> [GuestCalendarDay] {
        guard let interval = calendar.dateInterval(of: .month, for: month),
              let dayCount = calendar.range(of: .day, in: .month, for: month)?.count else { return [] }
        let firstWeekday = calendar.component(.weekday, from: interval.start)
        let leading = (firstWeekday - calendar.firstWeekday + 7) % 7
        var counts: [Date: Int] = [:]
        for entry in entries { counts[calendar.startOfDay(for: entry.createdAt), default: 0] += 1 }
        var cells = (0..<leading).map { GuestCalendarDay(id: -$0 - 1, date: nil, entryCount: 0) }
        for offset in 0..<dayCount {
            let date = calendar.date(byAdding: .day, value: offset, to: interval.start)!
            cells.append(GuestCalendarDay(id: offset, date: date, entryCount: counts[date] ?? 0))
        }
        return cells
    }

    static func entries(on day: Date, in entries: [GuestJournalEntry], calendar: Calendar = .current) -> [GuestJournalEntry] {
        entries.filter { calendar.isDate($0.createdAt, inSameDayAs: day) }
    }
}

struct GuestCalendarView: View {
    let entries: [GuestJournalEntry]
    @Binding var selectedDay: Date?
    @State private var month = Date()
    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button { shiftMonth(-1) } label: {
                    Image(systemName: "chevron.left").frame(width: 44, height: 44).contentShape(Rectangle())
                }
                .accessibilityLabel("Previous month")
                Spacer()
                Text(month, format: .dateTime.month(.wide).year())
                    .font(GuestBrand.font(.headline, .semibold)).foregroundStyle(GuestBrand.ink)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Button { shiftMonth(1) } label: {
                    Image(systemName: "chevron.right").frame(width: 44, height: 44).contentShape(Rectangle())
                }
                .accessibilityLabel("Next month")
            }
            .foregroundStyle(GuestBrand.blue)
            let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                    Text(symbol).font(GuestBrand.font(.caption, .semibold)).foregroundStyle(GuestBrand.muted)
                        .accessibilityHidden(true)
                }
                ForEach(GuestCalendarModel.days(in: month, entries: entries, calendar: calendar)) { day in
                    if let date = day.date { dayButton(date, count: day.entryCount) } else { Color.clear.frame(height: 44) }
                }
            }
            Button("Go to today") {
                month = Date()
                selectedDay = calendar.startOfDay(for: Date())
            }
            .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.blue)
            .frame(minHeight: 44)
        }
        .padding(12)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let start = calendar.firstWeekday - 1
        return Array(symbols[start...] + symbols[..<start])
    }

    private func dayButton(_ date: Date, count: Int) -> some View {
        let isSelected = selectedDay.map { calendar.isDate($0, inSameDayAs: date) } ?? false
        let isToday = calendar.isDateInToday(date)
        return Button {
            selectedDay = isSelected ? nil : date
        } label: {
            VStack(spacing: 2) {
                Text(date, format: .dateTime.day())
                    .font(GuestBrand.font(.subheadline, isToday ? .bold : .regular))
                Circle().frame(width: 5, height: 5).opacity(count > 0 ? 1 : 0)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .foregroundStyle(isSelected ? .white : GuestBrand.ink)
            .background(isSelected ? GuestBrand.blue : (isToday ? GuestBrand.ice : .clear),
                        in: RoundedRectangle(cornerRadius: 10))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(date, format: .dateTime.day().month(.wide)))
        .accessibilityValue(count == 0 ? "No entries" : count == 1 ? "1 entry" : "\(count) entries")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func shiftMonth(_ value: Int) {
        month = calendar.date(byAdding: .month, value: value, to: month) ?? month
    }
}

// MARK: - Export

enum GuestExport {
    /// Everything in the guest journal as plain, readable text.
    static func text(entries: [GuestJournalEntry], messages: [GuestPracticeMessage], now: Date = Date()) -> String {
        let date = Date.FormatStyle(date: .abbreviated, time: .shortened)
        var lines = ["CircleU export, \(now.formatted(date))",
                     "\(entries.count) journal \(entries.count == 1 ? "entry" : "entries") and \(messages.count) practice \(messages.count == 1 ? "message" : "messages").",
                     "", "JOURNAL"]
        for entry in entries.sorted(by: { $0.createdAt < $1.createdAt }) {
            lines += ["", "— \(entry.createdAt.formatted(date))", "My words:", entry.originalWords]
            if let reflection = entry.reflection {
                lines.append("Reflection (\(reflection.source == .onDevice ? "suggested by Apple Intelligence on this iPhone" : "guided prompts")):")
                for part in [reflection.summary, reflection.feeling.isEmpty ? "" : "Feeling: \(reflection.feeling)", reflection.insight]
                where !part.isEmpty { lines.append(part) }
                if entry.isReflectionStale { lines.append("(Based on an earlier version of these words.)") }
            }
            if let step = entry.nextStep { lines.append("Next step: \(step)\(entry.nextStepDone ? " (done)" : "")") }
        }
        lines += ["", "PRACTICE"]
        for message in messages.sorted(by: { $0.createdAt < $1.createdAt }) {
            lines += ["", "— \(message.createdAt.formatted(date)) · \(GuestPracticeTag.label(sourceEntryID: message.sourceEntryID, entries: entries))"]
            if !message.situation.isEmpty { lines.append("Situation: \(message.situation)") }
            if !message.goal.isEmpty { lines.append("Goal: \(message.goal)") }
            lines += ["Wording:", message.wording]
        }
        return lines.joined(separator: "\n") + "\n"
    }
}

// MARK: - Settings

@MainActor
final class GuestSettingsViewModel: ObservableObject {
    @Published private(set) var isWorking = false
    @Published private(set) var message: String?

    static let exportFailedMessage = "Couldn’t prepare the export. Try again."
    static let deleteFailedMessage = "Couldn’t delete. Try again. Your journal and practice are unchanged."
    static let deletedMessage = "Everything in this journal was deleted from this iPhone."
    static let cleanupPendingMessage = "Everything was deleted. A leftover copy couldn’t be removed yet; CircleU won’t show it and will try to remove it again next time it opens."
    static let deleteFailedDraftAsideMessage = "Couldn’t delete. Try again. Your journal and practice are unchanged; an unsaved draft was set aside and comes back next time CircleU opens."
    static let exportCleanupMessage = "The temporary export copy couldn’t be removed. CircleU will try again next time it opens."

    let journal: GuestJournalViewModel
    let practice: GuestPracticeViewModel

    init(journal: GuestJournalViewModel, practice: GuestPracticeViewModel) {
        self.journal = journal
        self.practice = practice
    }

    /// Where exports wait for the share sheet. Emptied after sharing, at launch and by Delete all.
    nonisolated static var exportFolder: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("CircleUExport", isDirectory: true)
    }

    /// Returns false if an export copy couldn't be removed.
    @discardableResult
    nonisolated static func removeExports(in folder: URL = exportFolder) -> Bool {
        guard FileManager.default.fileExists(atPath: folder.path) else { return true }
        return (try? FileManager.default.removeItem(at: folder)) != nil
    }

    /// Writes the export to a protected file for the share sheet; the caller removes it. Runs
    /// alone (no Delete all at the same time), and only exports a complete journal.
    func makeExportFile(directory: URL = GuestSettingsViewModel.exportFolder) async -> URL? {
        guard !isWorking else { return nil }
        isWorking = true
        defer { isWorking = false }
        message = nil
        guard let data = practice.store as? any GuestDataStore,
              let (entries, messages) = try? await data.snapshot() else {
            message = Self.exportFailedMessage // Never export a partial journal as if it were complete.
            return nil
        }
        let url = directory.appendingPathComponent("CircleU export \(Date().formatted(.iso8601.year().month().day())).txt")
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let data = Data(GuestExport.text(entries: entries, messages: messages).utf8)
            #if os(iOS)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            #else
            try data.write(to: url, options: .atomic)
            #endif
            return url
        } catch {
            try? FileManager.default.removeItem(at: url)
            message = Self.exportFailedMessage
            return nil
        }
    }

    /// Deletes everything in the guest journal, all or nothing: drafts are moved aside first, the
    /// store is cleared in one transaction, then the drafts are deleted (or put back if the store
    /// couldn't be cleared). The earlier app's data is never touched.
    func deleteAll() async {
        guard let data = practice.store as? any GuestDataStore, !isWorking else {
            message = Self.deleteFailedMessage
            return
        }
        isWorking = true
        defer { isWorking = false }
        message = nil
        var consumed: [UUID] = []
        do {
            consumed += try await journal.stageDraftRemoval()
            consumed += try await practice.stageDraftRemoval()
        } catch {
            message = await restoreDrafts() ? Self.deleteFailedMessage : Self.deleteFailedDraftAsideMessage
            return
        }
        do {
            try await data.deleteAll(consumedDraftIDs: consumed)
        } catch GuestJournalError.savedButUnprotected {
            // Committed.
        } catch {
            message = await restoreDrafts() ? Self.deleteFailedMessage : Self.deleteFailedDraftAsideMessage
            return
        }
        var draftsRemoved = true
        do { try await journal.finishDraftRemoval(commit: true) } catch { draftsRemoved = false }
        do { try await practice.finishDraftRemoval(commit: true) } catch { draftsRemoved = false }
        let exportsRemoved = Self.removeExports()
        await journal.load()
        await practice.load()
        message = draftsRemoved && exportsRemoved ? Self.deletedMessage : Self.cleanupPendingMessage
    }

    /// Returns false if a draft couldn't be put back yet (it comes back when CircleU next opens).
    private func restoreDrafts() async -> Bool {
        var restored = true
        do { try await journal.finishDraftRemoval(commit: false) } catch { restored = false }
        do { try await practice.finishDraftRemoval(commit: false) } catch { restored = false }
        return restored
    }

    func noteExportCleanup(succeeded: Bool) {
        if !succeeded { message = Self.exportCleanupMessage }
    }
}

struct GuestSettingsView: View {
    @StateObject private var settings: GuestSettingsViewModel
    @State private var exportURL: URL?
    @State private var confirmDelete = false

    init(journal: GuestJournalViewModel, practice: GuestPracticeViewModel) {
        _settings = StateObject(wrappedValue: GuestSettingsViewModel(journal: journal, practice: practice))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                section("Privacy and data") {
                    Text("Your journal and practice messages are kept on this iPhone. CircleU doesn’t upload or sync them, and suggestions are made on this iPhone.")
                    Text("Your iPhone’s own backups (iCloud or a computer) may include them. Restoring an older backup can bring back things you deleted, and exports you saved elsewhere aren’t deleted here.")
                    Text("Recording is used only while you dictate; no audio is saved.")
                }
                section("Your data") {
                    Button {
                        Task { exportURL = await settings.makeExportFile() }
                    } label: {
                        Label("Export my data", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(GuestBrandButtonStyle(filled: false))
                    .disabled(settings.isWorking)
                    Text("A readable text file. You choose where it goes; nothing is sent for you.")
                        .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                    Button(role: .destructive) { confirmDelete = true } label: {
                        Text("Delete all data").frame(maxWidth: .infinity, minHeight: 44).contentShape(Rectangle())
                    }
                    .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.danger)
                    .disabled(settings.isWorking)
                }
                if let message = settings.message {
                    Label(message, systemImage: "info.circle")
                        .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
                }
                section("About") {
                    Text("CircleU \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
                }
            }
            .padding(24)
        }
        .background(GuestBrand.ice.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete all data?", isPresented: $confirmDelete) {
            Button("Cancel", role: .cancel) {}
            Button("Delete all", role: .destructive) { Task { await settings.deleteAll() } }
        } message: {
            Text("This deletes every journal entry, reflection, next step and practice message on this iPhone, and any drafts. It can’t be undone. Data from the earlier CircleU app isn’t affected.")
        }
        .sheet(item: Binding(get: { exportURL.map(ExportFile.init) }, set: { if $0 == nil { exportURL = nil } })) { file in
            GuestShareSheet(url: file.url) {
                // Don't leave a copy behind; say so if it can't be removed.
                settings.noteExportCleanup(succeeded: GuestSettingsViewModel.removeExports())
                exportURL = nil
            }
        }
    }

    private struct ExportFile: Identifiable {
        let url: URL
        var id: String { url.path }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(GuestBrand.font(.headline, .semibold)).foregroundStyle(GuestBrand.ink)
                .accessibilityAddTraits(.isHeader)
            content().font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
    }
}

/// The system share sheet for one file; `onFinish` runs when it closes, shared or not.
struct GuestShareSheet: UIViewControllerRepresentable {
    let url: URL
    let onFinish: () -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        controller.completionWithItemsHandler = { _, _, _, _ in onFinish() }
        return controller
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
