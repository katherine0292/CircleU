import SwiftUI
import UIKit

/// Guest experience shell: Today, Journal and Practice.
struct GuestHomeView: View {
    @ObservedObject var journal: GuestJournalViewModel
    @ObservedObject var practice: GuestPracticeViewModel
    let makeDictationEngine: () -> any GuestDictationEngine
    @State private var tab: Tab = .today

    enum Tab: Hashable { case today, journal, practice }

    var body: some View {
        TabView(selection: $tab) {
            GuestTodayView(journal: journal, makeDictationEngine: makeDictationEngine, onSaved: { tab = .journal })
                .tabItem { GuestTabLabel(title: "Today", icon: "GuestIconToday") }
                .tag(Tab.today)
            GuestJournalListView(journal: journal, practice: practice)
                .tabItem { GuestTabLabel(title: "Journal", icon: "GuestIconJournal") }
                .tag(Tab.journal)
            GuestPracticeHomeView(practice: practice, journal: journal)
                .tabItem { GuestTabLabel(title: "Practice", icon: "GuestIconPractice") }
                .tag(Tab.practice)
        }
        .tint(GuestBrand.blue)
        .preferredColorScheme(.light) // Dark mode is deferred; the palette is light-only for now.
        .font(GuestBrand.font(.body))
        .foregroundStyle(GuestBrand.ink)
        // Above every tab and pushed screen, so a warning can't hide behind an open entry.
        .safeAreaInset(edge: .top) {
            if !journal.notices.isEmpty {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(journal.notices, id: \.self) { notice in
                            Label(notice, systemImage: "exclamationmark.shield")
                                .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
                        }
                    }
                    Spacer()
                    Button("OK") { journal.dismissNotices() }
                }
                .padding(12)
                .background(.white, in: RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Tabs

/// A tab with its illustrated brand icon; the title is the accessible name.
private struct GuestTabLabel: View {
    let title: String
    let icon: String

    var body: some View {
        Label { Text(title) } icon: { Image(icon).renderingMode(.original).accessibilityHidden(true) }
    }
}

// MARK: - Today

struct GuestTodayView: View {
    @ObservedObject var journal: GuestJournalViewModel
    let makeDictationEngine: () -> any GuestDictationEngine
    let onSaved: () -> Void
    @State private var isWriting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("What’s on your mind?")
                        .font(GuestBrand.font(.largeTitle, .bold)).foregroundStyle(GuestBrand.ink)
                        .accessibilityAddTraits(.isHeader)
                    Image("GuestBrandAvatar").resizable().scaledToFit()
                        .frame(maxWidth: .infinity).frame(height: 180)
                        .accessibilityHidden(true)
                    Button { isWriting = true } label: {
                        Label("Work through a moment", systemImage: "arrow.right")
                            .labelStyle(TrailingIconLabelStyle())
                    }
                    .buttonStyle(GuestBrandButtonStyle())
                    // Shown only when there is something to continue.
                    if !journal.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button { isWriting = true } label: {
                            Label {
                                Text("Continue your draft")
                            } icon: {
                                Image("GuestIconJournal").renderingMode(.original).accessibilityHidden(true)
                            }
                        }
                        .buttonStyle(GuestBrandButtonStyle(filled: false))
                    }
                }
                .padding(24)
            }
            .background(GuestBrand.ice.ignoresSafeArea())
            .navigationDestination(isPresented: $isWriting) {
                GuestWriteView(journal: journal, dictationEngine: makeDictationEngine()) {
                    isWriting = false
                    onSaved()
                }
            }
        }
    }
}

private struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack { configuration.title; Spacer(); configuration.icon }
    }
}

// MARK: - Write

struct GuestWriteView: View {
    @ObservedObject var journal: GuestJournalViewModel
    @StateObject private var dictation: GuestDictationViewModel
    let onSaved: () -> Void
    @FocusState private var focused: Bool
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL

    init(journal: GuestJournalViewModel, dictationEngine: @autoclosure @escaping () -> any GuestDictationEngine,
         onSaved: @escaping () -> Void) {
        self.journal = journal
        self.onSaved = onSaved
        _dictation = StateObject(wrappedValue: GuestDictationViewModel(journal: journal, engine: dictationEngine()))
    }

    var body: some View {
        // Scrolls rather than squeezing when the keyboard is up; Save stays visible above it.
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Start with your words.")
                    .font(GuestBrand.font(.title, .bold)).foregroundStyle(GuestBrand.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("Type, or tap the microphone and talk.")
                    .font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.muted)
                microphone
                TextEditor(text: $journal.draft)
                    .focused($focused)
                    .disabled(dictation.isActive) // Spoken words are going in; type again after Stop.
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .frame(minHeight: 200)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18))
                    .accessibilityLabel("Your words")
                if let message = dictation.message {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(message, systemImage: "info.circle")
                            .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                        if dictation.needsSettings, let url = URL(string: UIApplication.openSettingsURLString) {
                            Button("Open Settings") { openURL(url) }
                                .font(GuestBrand.font(.footnote, .semibold)).foregroundStyle(GuestBrand.blue)
                        }
                    }
                }
                if let error = journal.saveError {
                    Label(error, systemImage: "exclamationmark.circle")
                        .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
                }
                if let warning = journal.draftWarning {
                    Label(warning, systemImage: "info.circle")
                        .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                }
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            Button {
                dictation.stopForSave() // Saving while listening keeps the words so far.
                Task { if await journal.saveDraft() { onSaved() } }
            } label: {
                Text(journal.isSaving ? "Saving…" : "Save only my words")
            }
            .buttonStyle(GuestBrandButtonStyle())
            .disabled(journal.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || journal.isSaving)
            .padding(.horizontal, 24).padding(.vertical, 12)
            .background(GuestBrand.ice)
        }
        .background(GuestBrand.ice.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        // No automatic keyboard: it would cover the microphone. Tap the text to type.
        // Leaving the app or this screen stops listening; the words so far stay in the draft.
        // Only `.background`: the permission alert makes the app `.inactive`, and calls arrive
        // as audio-session interruptions.
        .onChange(of: scenePhase) { _, phase in if phase == .background { dictation.interrupt() } }
        .onDisappear { dictation.interrupt() }
    }

    /// The big microphone: tap to talk, tap again to stop. Cancel removes only the spoken words.
    private var microphone: some View {
        VStack(spacing: 10) {
            Button {
                focused = false
                Task { await dictation.toggle() }
            } label: {
                Image(systemName: dictation.isActive ? "stop.fill" : "mic.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 80, height: 80)
                    .background(GuestBrand.blue, in: Circle())
                    .overlay(Circle().stroke(GuestBrand.blue.opacity(0.25), lineWidth: dictation.state == .listening ? 10 : 0))
                    .animation(.easeInOut(duration: 0.2), value: dictation.state)
            }
            .disabled(dictation.state == .finishing || journal.isSaving)
            .accessibilityLabel(dictation.isActive ? "Stop dictation" : "Start dictation")
            .accessibilityHint(dictation.isActive ? "Keeps the words so far." : "Your words appear in the text, on this iPhone only.")
            Text(statusText)
                .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                .accessibilityHidden(true)
            if dictation.state == .listening || dictation.state == .finishing {
                Button("Cancel dictation") { dictation.cancel() }
                    .font(GuestBrand.font(.footnote, .semibold)).foregroundStyle(GuestBrand.blue)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var statusText: String {
        switch dictation.state {
        case .idle: "Tap to talk"
        case .requestingAccess: "Checking access…"
        case .listening: "Listening… tap to stop"
        case .finishing: "Finishing…"
        }
    }
}

// MARK: - Journal

struct GuestJournalListView: View {
    @ObservedObject var journal: GuestJournalViewModel
    @ObservedObject var practice: GuestPracticeViewModel

    var body: some View {
        NavigationStack {
            Group {
                switch journal.loadState {
                case .loading:
                    ProgressView()
                case .failed(let message):
                    VStack(spacing: 16) {
                        Text(message).multilineTextAlignment(.center)
                        Button("Try again") { Task { await journal.load() } }
                    }
                    .padding(24)
                case .loaded(let entries) where entries.isEmpty:
                    VStack(spacing: 16) {
                        Image("GuestPinguWriting").resizable().scaledToFit().frame(height: 160)
                            .accessibilityHidden(true)
                        Text("Nothing saved yet.").foregroundStyle(GuestBrand.muted)
                    }
                    .padding(24)
                case .loaded(let entries):
                    List(entries) { entry in
                        NavigationLink(value: entry.id) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.originalWords).lineLimit(3).foregroundStyle(GuestBrand.ink)
                                Text(entry.updatedAt, format: .dateTime.day().month().hour().minute())
                                    .font(GuestBrand.font(.caption)).foregroundStyle(GuestBrand.muted)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(GuestBrand.ice.ignoresSafeArea())
            .navigationTitle("Journal")
            .navigationDestination(for: UUID.self) { id in
                GuestEntryDetailView(entryID: id, journal: journal, practice: practice)
            }
        }
    }
}

struct GuestEntryDetailView: View {
    let entryID: UUID
    @ObservedObject var journal: GuestJournalViewModel
    @ObservedObject var practice: GuestPracticeViewModel
    /// Owned here, outside the content that refreshes, so an open editor survives list reloads.
    @State private var editor: GuestEntryEditorViewModel?
    @State private var practiceRoute: GuestPracticeRoute?
    @State private var confirmDelete = false
    @State private var deleteError: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        content
            .background(GuestBrand.ice.ignoresSafeArea())
            .navigationTitle("Entry")
            .navigationDestination(item: $practiceRoute) { route in
                GuestPracticeRouteView(route: route, practice: practice, journal: journal)
            }
            .alert("Delete this entry?", isPresented: $confirmDelete) {
                let linked = practice.linkedMessages(to: entryID)
                if linked.isEmpty {
                    Button("Cancel", role: .cancel) {}
                    Button("Delete", role: .destructive) { Task { await delete(.keepMessages) } }
                } else {
                    // Keeping the message is the default; it stays in Practice, on its own.
                    Button("Keep message") { Task { await delete(.keepMessages) } }
                        .keyboardShortcut(.defaultAction)
                    Button("Delete both", role: .destructive) { Task { await delete(.deleteBoth) } }
                    Button("Cancel", role: .cancel) {}
                }
            } message: {
                if !practice.linkedMessages(to: entryID).isEmpty {
                    Text("A practice message was made from it. Keep the message, or delete both?")
                }
            }
            .navigationDestination(isPresented: Binding(get: { editor != nil },
                                                        set: { if !$0 { editor = nil } })) {
                if let editor {
                    GuestEntryEditView(editor: editor) {
                        self.editor = nil
                        Task { await journal.load() }
                    }
                }
            }
    }

    @ViewBuilder private var content: some View {
        switch journal.loadState {
        case .loading:
            ProgressView()
        case .failed(let message):
            // A read problem is not a deleted entry.
            VStack(spacing: 16) {
                Text(message).multilineTextAlignment(.center)
                Button("Try again") { Task { await journal.load() } }
            }
            .padding(24)
        case .loaded(let entries):
            if let entry = entries.first(where: { $0.id == entryID }) {
                detail(for: entry)
            } else {
                Text("This entry no longer exists.").foregroundStyle(GuestBrand.muted)
            }
        }
    }

    private func detail(for entry: GuestJournalEntry) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("My words").font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.muted)
                Text(entry.originalWords).font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 18))
                Text(entry.updatedAt, format: .dateTime.day().month().year().hour().minute())
                    .font(GuestBrand.font(.caption)).foregroundStyle(GuestBrand.muted)
                let linked = practice.linkedMessages(to: entry.id)
                if case .failed(let message) = practice.loadState {
                    // Unknown is not "none": say so rather than hiding linked messages.
                    HStack {
                        Text(message).font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                        Button("Try again") { Task { await practice.load() } }
                            .font(GuestBrand.font(.footnote, .semibold))
                    }
                    .padding(.top, 8)
                } else if !linked.isEmpty {
                    Text("Practice").font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.muted)
                        .padding(.top, 8)
                    ForEach(linked) { message in
                        Button { practiceRoute = .message(message.id) } label: {
                            GuestPracticeRow(message: message, entries: journal.entries)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Button { practiceRoute = .new(sourceEntryID: entry.id) } label: {
                    Label {
                        Text("Practice what to say")
                    } icon: {
                        Image("GuestIconPractice").renderingMode(.original).accessibilityHidden(true)
                    }
                }
                .buttonStyle(GuestBrandButtonStyle(filled: false))
                .padding(.top, 8)
                if let deleteError {
                    Label(deleteError, systemImage: "exclamationmark.circle")
                        .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
                }
                Button("Delete entry", role: .destructive) { Task { await askToDelete() } }
                    .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.danger)
                    .frame(maxWidth: .infinity, minHeight: 44).contentShape(Rectangle())
                    .padding(.top, 8)
            }
            .padding(24)
        }
        .toolbar {
            Button("Edit") { editor = GuestEntryEditorViewModel(entry: entry, store: journal.store) }
        }
    }
}

struct GuestEntryEditView: View {
    @ObservedObject var editor: GuestEntryEditorViewModel
    let onDone: () -> Void
    @State private var confirmDiscard = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextEditor(text: $editor.text)
                .scrollContentBackground(.hidden)
                .padding(12)
                .background(.white, in: RoundedRectangle(cornerRadius: 18))
                .accessibilityLabel("Your words")
            if let error = editor.saveError {
                Label(error, systemImage: "exclamationmark.circle")
                    .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
            }
            Button {
                // Close only when everything typed is saved and there's no warning to read.
                Task { if await editor.save() == .saved { onDone() } }
            } label: {
                Text(editor.isSaving ? "Saving…" : "Save")
            }
            .buttonStyle(GuestBrandButtonStyle())
            .disabled(!editor.canSave)
        }
        .padding(24)
        .background(GuestBrand.ice.ignoresSafeArea())
        .navigationTitle("Edit")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Back") {
                    if editor.hasChanges { confirmDiscard = true } else { onDone() }
                }
                .disabled(!editor.canLeave) // Can't discard while a save may still commit.
            }
        }
        // An alert shows both choices; on iOS 26 a confirmation dialog can hide the cancel button.
        .alert("Discard your changes?", isPresented: $confirmDiscard) {
            Button("Keep editing", role: .cancel) {}
            Button("Discard", role: .destructive) { if editor.canLeave { onDone() } }
        } message: {
            Text("Your edits haven’t been saved.")
        }
    }
}

extension GuestEntryDetailView {
    /// The delete choices depend on linked messages, so make sure they're known first.
    fileprivate func askToDelete() async {
        deleteError = nil
        if case .loaded = practice.loadState {} else { await practice.load() }
        if case .loaded = practice.loadState {
            confirmDelete = true
        } else {
            deleteError = GuestPracticeViewModel.loadFailedMessage
        }
    }

    /// A failed delete keeps the entry (and its messages) and says so.
    fileprivate func delete(_ choice: GuestLinkedPracticeChoice) async {
        if let error = await practice.deleteEntry(id: entryID, linkedPractice: choice, journal: journal) {
            deleteError = error
        } else {
            dismiss()
        }
    }
}
