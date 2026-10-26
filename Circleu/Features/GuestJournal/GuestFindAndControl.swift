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
            Button("Go to today") {
                month = Date()
                selectedDay = calendar.startOfDay(for: Date())
            }
            .buttonStyle(.borderless)
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
    static let exportedMessage = "Export done."
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
    @State private var showPrivacy = false
    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 28

    init(journal: GuestJournalViewModel, practice: GuestPracticeViewModel) {
        _settings = StateObject(wrappedValue: GuestSettingsViewModel(journal: journal, practice: practice))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if settings.message == GuestSettingsViewModel.exportedMessage {
                    GuestSuccessBanner(text: GuestSettingsViewModel.exportedMessage, asset: "GuestPinguBackpack")
                } else if let message = settings.message {
                    Label(message, systemImage: "info.circle")
                        .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                pingu
                privacyChip
                group("Your data") {
                    Button {
                        Task { exportURL = await settings.makeExportFile() }
                    } label: {
                        row("Export my data") { GuestBrandIcon(asset: "GuestIconExport", size: iconSize) }
                    }
                    .disabled(settings.isWorking)
                    divider
                    Button(role: .destructive) { confirmDelete = true } label: {
                        row("Delete all data", destructive: true, chevron: false) { dangerIcon("trash") }
                    }
                    .disabled(settings.isWorking)
                }
                if let importer = settings.practice.store as? any GuestImportStore {
                    group("Earlier CircleU account") {
                        NavigationLink {
                            GuestSignInView(factory: .live, store: importer, journal: settings.journal,
                                            practice: settings.practice)
                        } label: {
                            row("Bring in your earlier journal") { GuestBrandIcon(asset: "GuestIconEarlierJournal", size: iconSize) }
                        }
                        divider
                        NavigationLink {
                            GuestDeleteAccountView(factory: .live)
                        } label: {
                            row("Delete my account", destructive: true) { dangerIcon("person.crop.circle.badge.xmark") }
                        }
                    }
                }
                HStack(spacing: 6) {
                    GuestBrandIcon(asset: "GuestIconLogo", size: 18)
                    Text("CircleU \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
                }
                .font(GuestBrand.font(.caption)).foregroundStyle(GuestBrand.muted)
                .accessibilityElement(children: .combine)
            }
            .buttonStyle(.plain)
            .padding(20)
        }
        .background(GuestBrand.ice.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete all data?", isPresented: $confirmDelete) {
            Button("Cancel", role: .cancel) {}
            Button("Delete all", role: .destructive) { Task { await settings.deleteAll() } }
        } message: {
            Text("Deletes this journal and drafts. The earlier app stays.")
        }
        .sheet(isPresented: $showPrivacy) { GuestPrivacySheet() }
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

    /// The chosen Pingu, with a pencil badge in place of "Tap to change."
    private var pingu: some View {
        VStack(spacing: 6) {
            GuestAvatarButton(size: 110, framed: true)
            Text("Your Pingu").font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.ink)
                .accessibilityHidden(true) // The button already says it.
        }
    }

    /// The privacy promise stays in words; the detail opens as a sheet.
    private var privacyChip: some View {
        VStack(spacing: 6) {
            Button { showPrivacy = true } label: {
                HStack(spacing: 8) {
                    GuestBrandIcon(asset: "GuestIconPrivacy", size: 22)
                    Text("Kept on this iPhone")
                    Image(systemName: "chevron.right").font(.caption.weight(.bold)).accessibilityHidden(true)
                }
                .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.blue)
                .padding(.horizontal, 16).frame(minHeight: 44)
                .background(GuestBrand.blue.opacity(0.1), in: Capsule())
            }
            .accessibilityHint("Shows what stays on this iPhone.")
            GuestSummary("Not uploaded or synced.")
        }
    }

    private var divider: some View {
        Divider().padding(.leading, iconSize + 28)
    }

    private func group<Content: View>(_ title: String, @ViewBuilder _ rows: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(GuestBrand.font(.footnote, .semibold)).foregroundStyle(GuestBrand.muted)
                .padding(.leading, 16).accessibilityAddTraits(.isHeader)
            VStack(spacing: 0) { rows() }
                .background(.white, in: RoundedRectangle(cornerRadius: 18))
        }
    }

    private func row<Icon: View>(_ title: String, destructive: Bool = false, chevron: Bool = true,
                                 @ViewBuilder icon: () -> Icon) -> some View {
        HStack(spacing: 12) {
            icon()
            Text(title).frame(maxWidth: .infinity, alignment: .leading)
            if chevron {
                Image(systemName: "chevron.right").font(.footnote.weight(.semibold))
                    .foregroundStyle(GuestBrand.muted.opacity(0.6)).accessibilityHidden(true)
            }
        }
        .font(GuestBrand.font(.body)).foregroundStyle(destructive ? GuestBrand.danger : GuestBrand.ink)
        .padding(.horizontal, 16).frame(minHeight: 56)
        .contentShape(Rectangle())
    }

    private func dangerIcon(_ symbol: String) -> some View {
        Image(systemName: symbol).font(.system(size: 15, weight: .semibold)).foregroundStyle(GuestBrand.danger)
            .frame(width: iconSize, height: iconSize)
            .background(GuestBrand.danger.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            .accessibilityHidden(true)
    }
}

/// What "Kept on this iPhone" means: one short line per fact, each with an icon.
struct GuestPrivacySheet: View {
    @Environment(\.dismiss) private var dismiss
    @ScaledMetric(relativeTo: .subheadline) private var iconSize: CGFloat = 40

    /// Each fact has its own illustrated icon (BrandArtwork/Expansion03), none shared with another screen.
    private let facts: [(asset: String, text: String)] = [
        ("GuestIconNoAudio", "Suggestions and dictation stay here; no audio is saved."),
        ("GuestIconBackups", "iCloud or computer backups of your iPhone may include your journal."),
        ("GuestIconRestore", "Restoring an older backup can bring back deleted items."),
        ("GuestIconSharedCopy", "Exports you saved elsewhere aren’t deleted here."),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    GuestPinguDecoration(asset: "GuestPinguQuietBreath", height: 140)
                    VStack(spacing: 4) {
                        Text("Kept on this iPhone").font(GuestBrand.font(.title2, .bold)).foregroundStyle(GuestBrand.ink)
                            .accessibilityAddTraits(.isHeader)
                        GuestSummary("Not uploaded or synced.")
                    }
                    .multilineTextAlignment(.center)
                    VStack(spacing: 0) {
                        ForEach(Array(facts.enumerated()), id: \.offset) { index, fact in
                            if index > 0 { Divider().padding(.leading, iconSize + 30) }
                            HStack(spacing: 14) {
                                GuestBrandIcon(asset: fact.asset, size: iconSize)
                                Text(fact.text).font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 16).padding(.vertical, 12)
                        }
                    }
                    .background(.white, in: RoundedRectangle(cornerRadius: 18))
                }
                .padding(20)
            }
            .background(GuestBrand.ice.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
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
