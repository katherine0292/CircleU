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
                .buttonStyle(.borderless) // In a List row, default-style buttons all fire on any tap.
                .accessibilityLabel("Previous month")
                Spacer()
                Text(month, format: .dateTime.month(.wide).year())
                    .font(GuestBrand.font(.headline, .semibold)).foregroundStyle(GuestBrand.ink)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Button {
                    month = Date()
                    selectedDay = calendar.startOfDay(for: Date())
                } label: {
                    Image(systemName: "smallcircle.filled.circle").frame(width: 44, height: 44).contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Go to today")
                Button { shiftMonth(1) } label: {
                    Image(systemName: "chevron.right").frame(width: 44, height: 44).contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
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
                // One dot per entry, up to three.
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle().frame(width: 4, height: 4).opacity(index < count ? 1 : 0)
                    }
                }
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
                let source = switch reflection.source {
                case .onDevice: "suggested by Apple Intelligence on this iPhone"
                case .guided: "guided prompts"
                case .imported: "from the earlier CircleU app"
                }
                lines.append("Reflection (\(source)):")
                for part in [reflection.summary, reflection.feeling.isEmpty ? "" : "Feeling: \(reflection.feeling)", reflection.insight]
                where !part.isEmpty { lines.append(part) }
                if entry.isReflectionStale { lines.append("(Based on an earlier version of these words.)") }
            }
            if let step = entry.nextStep { lines.append("Next step: \(step)\(entry.nextStepDone ? " (done)" : "")") }
        }
        lines += ["", "PRACTICE"]
        for message in messages.sorted(by: { $0.createdAt < $1.createdAt }) {
            // copy: export
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
    static let deletedExportPendingMessage = "Everything was deleted. A leftover copy is still here; CircleU will try again to remove it."
    static let exportedMessage = "Export done. The copy you shared is yours to keep or delete."
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

    /// Deletes everything in the guest journal, drafts included, in one store transaction: all
    /// of it or none of it. Draft writes pause meanwhile. The earlier app's data is never touched.
    func deleteAll() async {
        guard let data = practice.store as? any GuestDataStore, !isWorking else {
            message = Self.deleteFailedMessage
            return
        }
        isWorking = true
        defer { isWorking = false }
        message = nil
        await journal.pauseDrafts()
        await practice.pauseDrafts()
        var deleted = true
        var leftovers = false
        do {
            leftovers = try await !data.deleteAll()
        } catch GuestJournalError.savedButUnprotected {
            // Committed.
        } catch {
            deleted = false
        }
        journal.resumeDrafts(afterDeleting: deleted)
        practice.resumeDrafts(afterDeleting: deleted)
        guard deleted else {
            message = Self.deleteFailedMessage
            return
        }
        let exportsRemoved = Self.removeExports()
        GuestAvatars.reset() // The chosen Pingu goes back to the default too.
        await journal.load()
        await practice.load()
        message = exportsRemoved && !leftovers ? Self.deletedMessage : Self.deletedExportPendingMessage
    }

    func noteExportCleanup(succeeded: Bool, shared: Bool) {
        if !succeeded {
            message = Self.exportCleanupMessage
        } else if shared {
            message = Self.exportedMessage
        }
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
                section("Your Pingu", icon: "GuestPinguWelcome") {
                    GuestAvatarButton(size: 110)
                    GuestSummary("Tap to change.")
                }
                section("Privacy and data", icon: "GuestIconPrivacy") {
                    GuestSummary("Kept on this iPhone. Not uploaded or synced.")
                    GuestLearnMore {
                        Text("Suggestions and dictation stay on this iPhone; no audio is saved.")
                        Text("Your iPhone’s own backups (iCloud or a computer) may include your journal.")
                        Text("Restoring an older backup can bring back things you deleted.")
                        Text("Exports you saved elsewhere aren’t deleted here.")
                    }
                }
                section("Your data", icon: "GuestIconJournal") {
                    GuestSummary("A text file you can save or share.")
                    Button {
                        Task { exportURL = await settings.makeExportFile() }
                    } label: {
                        Label { Text("Export my data") } icon: { GuestBrandIcon(asset: "GuestIconNextStep", size: 24) }
                    }
                    .buttonStyle(GuestBrandButtonStyle(filled: false))
                    .disabled(settings.isWorking)
                    Button(role: .destructive) { confirmDelete = true } label: {
                        Text("Delete all data").frame(maxWidth: .infinity, minHeight: 44).contentShape(Rectangle())
                    }
                    .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.danger)
                    .disabled(settings.isWorking)
                }
                if settings.message == GuestSettingsViewModel.exportedMessage {
                    GuestSuccessBanner(text: GuestSettingsViewModel.exportedMessage, asset: "GuestPinguBackpack")
                } else if let message = settings.message {
                    Label(message, systemImage: "info.circle")
                        .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
                }
                if let importer = settings.practice.store as? any GuestImportStore {
                    section("Earlier CircleU account", icon: "GuestIconJournal") {
                        GuestSummary("Bring in your journal from an earlier account.")
                        NavigationLink {
                            GuestSignInView(factory: .live, store: importer, journal: settings.journal,
                                            practice: settings.practice)
                        } label: {
                            Text("Log in to bring in your journal")
                        }
                        .buttonStyle(GuestBrandButtonStyle(filled: false))
                        NavigationLink {
                            GuestDeleteAccountView(factory: .live)
                        } label: {
                            Text("Delete my account").frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.danger)
                    }
                }
                section("About", icon: "GuestIconLogo") {
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
            Text("Deletes everything in this journal, including drafts. The earlier CircleU app isn’t affected.")
        }
        .sheet(item: Binding(get: { exportURL.map(ExportFile.init) }, set: { if $0 == nil { exportURL = nil } })) { file in
            GuestShareSheet(url: file.url) { completed in
                // Don't leave a copy behind; say so if it can't be removed.
                settings.noteExportCleanup(succeeded: GuestSettingsViewModel.removeExports(), shared: completed)
                exportURL = nil
            }
        }
    }

    private struct ExportFile: Identifiable {
        let url: URL
        var id: String { url.path }
    }

    private func section<Content: View>(_ title: String, icon: String,
                                        @ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label { Text(title) } icon: { GuestBrandIcon(asset: icon, size: 28) }
                .font(GuestBrand.font(.headline, .semibold)).foregroundStyle(GuestBrand.ink)
                .accessibilityAddTraits(.isHeader)
            content().font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
    }
}

/// The system share sheet for one file; `onFinish(completed)` runs when it closes.
struct GuestShareSheet: UIViewControllerRepresentable {
    let url: URL
    let onFinish: (Bool) -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        controller.completionWithItemsHandler = { _, completed, _, _ in onFinish(completed) }
        return controller
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
