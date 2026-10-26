import Combine
import SwiftUI
import UIKit

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
        case done(added: Int, skipped: [GuestLegacyScan.Skip], isProtected: Bool)
        case failed(String)
    }

    @Published private(set) var state: State = .scanning

    static let failedMessage = "Couldn’t copy your earlier journal. Nothing was added; try again."

    private let defaults: UserDefaults
    private let store: any GuestImportStore
    private let journal: GuestJournalViewModel
    private let practice: GuestPracticeViewModel
    private var pending = GuestLegacyScan()

    init(defaults: UserDefaults = GuestLegacyImport.source, store: any GuestImportStore, journal: GuestJournalViewModel,
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
            let result = try await store.importLegacy(entries: scan.entries, messages: scan.messages)
            await journal.load()
            await practice.load()
            state = .done(added: result.added, skipped: scan.skipped, isProtected: result.isProtected)
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
                Text("Copy your earlier journal from this iPhone.")
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
        case .done(let added, let skipped, let isProtected):
            GuestSuccessBanner(text: added == 0 ? "Nothing new to copy." : "Copied \(added) \(added == 1 ? "item" : "items") into your journal.",
                               asset: "GuestPinguReading")
            if !isProtected {
                Label(GuestJournalViewModel.savedButUnprotectedMessage, systemImage: "exclamationmark.shield")
                    .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
            }
            Self.leftOut(skipped)
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
            Self.leftOut(scan.skipped)
            if model.canImport {
                Button("Copy into this journal") { Task { await model.importAll() } }
                    .buttonStyle(GuestBrandButtonStyle())
                GuestLearnMore {
                    Text("Reflections are kept apart from your words and marked as from the earlier app.")
                    Text("Titles, tags, quests and coaching aren’t copied.")
                }
                    .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
            }
        }
    }
}

extension GuestImportView {
    /// `heading: false` inside a "Left out (N)" disclosure, which already names the list.
    @ViewBuilder static func leftOut(_ skipped: [GuestLegacyScan.Skip], heading: Bool = true) -> some View {
        if !skipped.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                if heading {
                    Text("Left out").font(GuestBrand.font(.headline, .semibold)).foregroundStyle(GuestBrand.ink)
                        .accessibilityAddTraits(.isHeader)
                }
                ForEach(Array(skipped.enumerated()), id: \.offset) { _, skip in
                    Text("\(skip.what): \(Self.reason(skip.reason))")
                        .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                }
                Text("Left-out items stay in the earlier app.")
                    .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
            }
        }
    }

    static func reason(_ reason: GuestLegacyScan.SkipReason) -> String {
        switch reason {
        case .noWords: "no words were saved with it"
        case .unreadable: "it couldn’t be read"
        case .needsAccount: "it can’t be shown to be yours yet, so it stays sealed"
        }
    }
}

// MARK: - Welcome

/// First launch of the guest journal: three illustrated pages, then Get started, and Log in for
/// someone who used CircleU before. Accounts aren't part of this version, so Log in explains that
/// and offers the earlier journal on this iPhone instead.
struct GuestWelcomeView: View {
    let store: any GuestImportStore
    let journal: GuestJournalViewModel
    let practice: GuestPracticeViewModel
    let onDone: () -> Void
    @State private var showsLogin = false
    @State private var page = 0
    @State private var scrolledPage: Int? = 0
    @State private var footerHeight: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    static let pages: [GuestOnboardingPage] = [
        GuestOnboardingPage(asset: "GuestOnboardingHardMoment", title: "Something on your mind?",
                            line: "A private place for the moments that stay with you."),
        GuestOnboardingPage(asset: "GuestOnboardingFindWords", title: "Write or talk it through",
                            line: "Kept on this iPhone. Not uploaded or synced."),
        GuestOnboardingPage(asset: "GuestOnboardingSayItKindly", title: "Find your words",
                            line: "Practise what you want to say, when you’re ready."),
    ]
    private var isLast: Bool { page == Self.pages.count - 1 }

    var body: some View {
        NavigationStack {
            // Pages fill the whole screen, under the status bar and behind the footer; each keeps its
            // words above the footer. Sizes are explicit so the paging scroll view can't shrink them.
            GeometryReader { outer in
                let top = outer.safeAreaInsets.top, bottom = outer.safeAreaInsets.bottom
                let width = outer.size.width, height = outer.size.height + top + bottom
                ZStack(alignment: .bottom) {
                    ScrollView(.horizontal) {
                        HStack(spacing: 0) {
                            ForEach(Self.pages.indices, id: \.self) { index in
                                GuestOnboardingPageView(page: Self.pages[index], topInset: top,
                                                        bottomInset: footerHeight + bottom)
                                    .frame(width: width, height: height)
                                    .id(index)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollIndicators(.hidden)
                    .scrollTargetBehavior(.paging)
                    .scrollBounceBehavior(.basedOnSize)
                    .scrollPosition(id: $scrolledPage)
                    .onChange(of: scrolledPage) { _, new in if let new { page = new } }
                    footer
                        .background(GeometryReader { Color.clear.preference(key: GuestFooterHeight.self, value: $0.size.height) })
                        .padding(.bottom, bottom)
                }
                .frame(width: width, height: height)
                .onPreferenceChange(GuestFooterHeight.self) { footerHeight = $0 }
                .ignoresSafeArea()
            }
            .background(GuestBrand.ice.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showsLogin) {
                GuestSignInView(factory: .live, store: store, journal: journal, practice: practice, onSkip: onDone)
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 20) {
            GuestPageDots(count: Self.pages.count, selected: page)
            Group {
                if isLast {
                    VStack(spacing: 12) {
                        Button("Get started", action: onDone).buttonStyle(GuestBrandButtonStyle())
                        Button("Log in") { showsLogin = true }.buttonStyle(GuestBrandButtonStyle(filled: false))
                    }
                } else {
                    HStack {
                        Button("Skip") { go(to: Self.pages.count - 1) }
                            .font(GuestBrand.font(.headline, .semibold)).foregroundStyle(GuestBrand.blue)
                            .frame(minWidth: 44, minHeight: 44).contentShape(Rectangle())
                        Spacer()
                        Button { go(to: page + 1) } label: {
                            Image(systemName: "arrow.right").font(.title2.weight(.semibold)).foregroundStyle(.white)
                                .frame(width: 60, height: 60).background(GuestBrand.blue, in: Circle())
                        }
                        .accessibilityLabel("Next")
                    }
                }
            }
            .frame(minHeight: 120, alignment: .bottom)
        }
        .padding(.horizontal, 24).padding(.bottom, 16)
    }

    private func go(to index: Int) {
        page = index
        if reduceMotion { scrolledPage = index } else { withAnimation(.easeInOut(duration: 0.3)) { scrolledPage = index } }
    }
}

private struct GuestFooterHeight: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = max(value, nextValue()) }
}

struct GuestOnboardingPage {
    let asset: String
    let title: String
    let line: String
}

/// One Welcome page: the scene fills from the top and fades into ice, where the words sit. At
/// accessibility text sizes the scene becomes a short banner so text never sits on the art.
struct GuestOnboardingPageView: View {
    let page: GuestOnboardingPage
    /// The status bar height; the page itself runs under it.
    let topInset: CGFloat
    /// The footer and home indicator, which sit over the bottom of the page.
    let bottomInset: CGFloat
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        GeometryReader { geo in
            if typeSize.isAccessibilitySize {
                // A 180 pt band around Pingu, who sits about 38% down the scene.
                let top = topInset
                VStack(spacing: 0) {
                    Color.clear.frame(height: 180 + top)
                        .overlay(alignment: .top) {
                            art(width: geo.size.width).offset(y: min(0, top + 90 - geo.size.width * aspect * 0.38))
                        }
                        .clipped()
                    ScrollView { words.padding(24).padding(.bottom, bottomInset) }
                }
            } else {
                // The art is a background so its height never moves the words.
                words.padding(.horizontal, 24).padding(.bottom, bottomInset + 20)
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
                    .background(alignment: .top) { art(width: geo.size.width) }
                    .clipped()
            }
        }
        .ignoresSafeArea()
    }

    /// Height over width; the scenes aren't all the same shape.
    private var aspect: CGFloat {
        guard let size = UIImage(named: page.asset)?.size, size.width > 0 else { return 1.5 }
        return size.height / size.width
    }

    private func art(width: CGFloat) -> some View {
        Image(page.asset).resizable().scaledToFill()
            .frame(width: width, height: width * aspect).clipped()
            .accessibilityHidden(true)
    }

    private var words: some View {
        VStack(spacing: 10) {
            Text(page.title).font(GuestBrand.font(.title, .bold)).foregroundStyle(GuestBrand.ink)
                .accessibilityAddTraits(.isHeader)
            GuestSummary(page.line)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

/// Page dots: the current one wider and blue. Spoken as "Page N of M".
struct GuestPageDots: View {
    let count: Int
    let selected: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Capsule().fill(index == selected ? GuestBrand.blue : GuestBrand.blue.opacity(0.2))
                    .frame(width: index == selected ? 24 : 8, height: 8)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Page \(selected + 1) of \(count)")
    }
}
