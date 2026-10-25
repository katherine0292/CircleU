import Combine
import SwiftUI

// MARK: - Import from the earlier app

/// One-time, copy-only import of the earlier CircleU app's journal and practice. Shows what was
/// found first; importing again never duplicates; the earlier app's data is only read.
@MainActor
final class GuestImportViewModel: ObservableObject {
    enum State: Equatable {
        case scanning
        /// What will be copied, what was imported before, and what will be skipped (and why).
        case preview(GuestLegacyScan, alreadyImported: Int)
        case importing
        case done(added: Int, skipped: Int)
        case failed(String)
    }

    @Published private(set) var state: State = .scanning

    static let failedMessage = "Couldn’t copy your earlier journal. Nothing was added; try again."

    private let defaults: UserDefaults
    private let store: any GuestImportStore
    private let journal: GuestJournalViewModel
    private let practice: GuestPracticeViewModel
    private var pending = GuestLegacyScan()

    init(defaults: UserDefaults = .standard, store: any GuestImportStore, journal: GuestJournalViewModel,
         practice: GuestPracticeViewModel) {
        self.defaults = defaults
        self.store = store
        self.journal = journal
        self.practice = practice
    }

    func scan() async {
        state = .scanning
        var found = GuestLegacyImport.scan(defaults)
        var already = 0
        do {
            var newEntries: [GuestImportedEntry] = []
            for entry in found.entries {
                if try await store.isImported(entry.legacyID) { already += 1 } else { newEntries.append(entry) }
            }
            var newMessages: [GuestImportedMessage] = []
            for message in found.messages {
                if try await store.isImported(message.legacyID) { already += 1 } else { newMessages.append(message) }
            }
            found.entries = newEntries
            found.messages = newMessages
        } catch {
            state = .failed(Self.failedMessage)
            return
        }
        pending = found
        state = .preview(found, alreadyImported: already)
    }

    var canImport: Bool {
        if case .preview(let scan, _) = state { return !scan.entries.isEmpty || !scan.messages.isEmpty }
        return false
    }

    func importAll() async {
        guard canImport else { return }
        let scan = pending
        state = .importing
        do {
            let added = try await store.importLegacy(entries: scan.entries, messages: scan.messages)
            await journal.load()
            await practice.load()
            state = .done(added: added, skipped: scan.skipped.count)
        } catch {
            state = .failed(Self.failedMessage)
        }
    }
}

struct GuestImportView: View {
    @StateObject private var model: GuestImportViewModel

    init(store: any GuestImportStore, journal: GuestJournalViewModel, practice: GuestPracticeViewModel) {
        _model = StateObject(wrappedValue: GuestImportViewModel(store: store, journal: journal, practice: practice))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Copy your journal from the earlier CircleU app on this iPhone into this one. The earlier app’s data isn’t changed or deleted, and nothing is sent anywhere.")
                    .foregroundStyle(GuestBrand.ink)
                content
            }
            .padding(24)
        }
        .background(GuestBrand.ice.ignoresSafeArea())
        .navigationTitle("Earlier journal")
        .navigationBarTitleDisplayMode(.inline)
        .task { if model.state == .scanning { await model.scan() } }
    }

    @ViewBuilder private var content: some View {
        switch model.state {
        case .scanning, .importing:
            ProgressView().frame(maxWidth: .infinity)
        case .failed(let message):
            Label(message, systemImage: "exclamationmark.circle").foregroundStyle(GuestBrand.ink)
            Button("Try again") { Task { await model.scan() } }
                .buttonStyle(GuestBrandButtonStyle(filled: false))
        case .done(let added, let skipped):
            GuestSuccessBanner(text: added == 0 ? "Nothing new to copy." : "Copied \(added) \(added == 1 ? "item" : "items") into your journal.",
                               asset: "GuestPinguReading")
            if skipped > 0 {
                Text("\(skipped) \(skipped == 1 ? "item was" : "items were") left out (see above). They’re still in the earlier app.")
                    .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
            }
        case .preview(let scan, let already):
            preview(scan, already: already)
        }
    }

    @ViewBuilder private func preview(_ scan: GuestLegacyScan, already: Int) -> some View {
        if scan.entries.isEmpty && scan.messages.isEmpty && scan.skipped.isEmpty {
            GuestPinguMessage(asset: "GuestPinguExplorer",
                              text: already > 0 ? "Everything from the earlier app is already here."
                                  : "Nothing from the earlier CircleU app was found in this app on this iPhone.")
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("Found").font(GuestBrand.font(.headline, .semibold)).foregroundStyle(GuestBrand.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("\(scan.entries.count) journal \(scan.entries.count == 1 ? "entry" : "entries") and \(scan.messages.count) practice \(scan.messages.count == 1 ? "message" : "messages") to copy.")
                if already > 0 {
                    Text("\(already) already copied before; they won’t be copied again.")
                        .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                }
                ForEach(Array(scan.entries.prefix(3).enumerated()), id: \.offset) { _, entry in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.originalWords).lineLimit(2).foregroundStyle(GuestBrand.ink)
                        Text(entry.createdAt, format: .dateTime.day().month().year())
                            .font(GuestBrand.font(.caption)).foregroundStyle(GuestBrand.muted)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white, in: RoundedRectangle(cornerRadius: 14))
                }
                if scan.entries.count > 3 {
                    Text("and \(scan.entries.count - 3) more").font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                }
            }
            if !scan.skipped.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Left out").font(GuestBrand.font(.headline, .semibold)).foregroundStyle(GuestBrand.ink)
                        .accessibilityAddTraits(.isHeader)
                    ForEach(Array(scan.skipped.enumerated()), id: \.offset) { _, skip in
                        Text("\(skip.what): \(skip.reason == .noWords ? "no words were saved with it" : "it couldn’t be read")")
                            .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                    }
                }
            }
            if model.canImport {
                Button("Copy into this journal") { Task { await model.importAll() } }
                    .buttonStyle(GuestBrandButtonStyle())
                Text("Reflections from the earlier app are kept apart from your words and marked as from the earlier app.")
                    .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
            }
        }
    }
}

// MARK: - Welcome

/// First launch of the guest journal: what it is, Get started, and Log in for someone who used
/// CircleU before. Accounts aren't part of this version, so Log in explains that and offers the
/// earlier journal on this iPhone instead.
struct GuestWelcomeView: View {
    let store: any GuestImportStore
    let journal: GuestJournalViewModel
    let practice: GuestPracticeViewModel
    let onDone: () -> Void
    @State private var showsLogin = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 24)
                    GuestPinguDecoration(asset: "GuestPinguWelcome", height: 200)
                    Text("CircleU").font(GuestBrand.font(.largeTitle, .bold)).foregroundStyle(GuestBrand.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text("A private place to work through a moment and find your words.")
                        .multilineTextAlignment(.center).foregroundStyle(GuestBrand.muted)
                    Text("No account needed. Everything stays on this iPhone.")
                        .font(GuestBrand.font(.footnote)).multilineTextAlignment(.center).foregroundStyle(GuestBrand.muted)
                    Button("Get started", action: onDone)
                        .buttonStyle(GuestBrandButtonStyle())
                        .padding(.top, 8)
                    Button("Log in") { showsLogin = true }
                        .buttonStyle(GuestBrandButtonStyle(filled: false))
                }
                .padding(24)
            }
            .background(GuestBrand.ice.ignoresSafeArea())
            .navigationDestination(isPresented: $showsLogin) {
                GuestLoginInfoView(store: store, journal: journal, practice: practice, onDone: onDone)
            }
        }
    }
}

struct GuestLoginInfoView: View {
    let store: any GuestImportStore
    let journal: GuestJournalViewModel
    let practice: GuestPracticeViewModel
    let onDone: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Used CircleU before?").font(GuestBrand.font(.title2, .bold)).foregroundStyle(GuestBrand.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("Signing in to an account isn’t part of this version, so nothing is fetched from the internet. If you used CircleU on this iPhone before, you can copy that journal in.")
                    .foregroundStyle(GuestBrand.ink)
                NavigationLink {
                    GuestImportView(store: store, journal: journal, practice: practice)
                } label: {
                    Text("Find my earlier journal")
                }
                .buttonStyle(GuestBrandButtonStyle())
                Button("Continue without it", action: onDone)
                    .buttonStyle(GuestBrandButtonStyle(filled: false))
            }
            .padding(24)
        }
        .background(GuestBrand.ice.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}
