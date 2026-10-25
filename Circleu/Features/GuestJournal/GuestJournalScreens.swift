import SwiftUI

/// Guest experience shell: Today and Journal (Practice comes in a later slice).
struct GuestHomeView: View {
    @ObservedObject var journal: GuestJournalViewModel
    @State private var tab: Tab = .today

    enum Tab: Hashable { case today, journal }

    var body: some View {
        TabView(selection: $tab) {
            GuestTodayView(journal: journal, onSaved: { tab = .journal })
                .tabItem { Label("Today", systemImage: "sun.max") }
                .tag(Tab.today)
            GuestJournalListView(journal: journal)
                .tabItem { Label("Journal", systemImage: "book.closed") }
                .tag(Tab.journal)
        }
        .tint(Pingu.accent)
    }
}

// MARK: - Today

struct GuestTodayView: View {
    @ObservedObject var journal: GuestJournalViewModel
    let onSaved: () -> Void
    @State private var isWriting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("What’s on your mind?")
                        .font(.largeTitle.bold()).foregroundStyle(Pingu.ink)
                        .accessibilityAddTraits(.isHeader)
                    Image("PinguMascot").resizable().scaledToFit()
                        .frame(maxWidth: .infinity).frame(height: 180)
                        .accessibilityHidden(true)
                    Button { isWriting = true } label: {
                        Label("Work through a moment", systemImage: "arrow.right")
                            .labelStyle(TrailingIconLabelStyle())
                            .frame(maxWidth: .infinity, minHeight: 54)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Pingu.accent)
                    // Shown only when there is something to continue.
                    if !journal.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button { isWriting = true } label: {
                            Label("Continue your draft", systemImage: "square.and.pencil")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(24)
            }
            .background(Color("PinguIce").ignoresSafeArea())
            .navigationDestination(isPresented: $isWriting) {
                GuestWriteView(journal: journal) {
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
    let onSaved: () -> Void
    @FocusState private var focused: Bool

    var body: some View {
        // Scrolls rather than squeezing when the keyboard is up; Save stays visible above it.
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Start with your words.")
                    .font(.title.bold()).foregroundStyle(Pingu.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("What happened?").font(.body).foregroundStyle(Pingu.slate)
                TextEditor(text: $journal.draft)
                    .focused($focused)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .frame(minHeight: 200)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18))
                    .accessibilityLabel("Your words")
                if let error = journal.saveError {
                    Label(error, systemImage: "exclamationmark.circle")
                        .font(.subheadline).foregroundStyle(Pingu.ink)
                }
                if let warning = journal.draftWarning {
                    Label(warning, systemImage: "info.circle")
                        .font(.footnote).foregroundStyle(Pingu.slate)
                }
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            Button {
                Task { if await journal.saveDraft() { onSaved() } }
            } label: {
                Text(journal.isSaving ? "Saving…" : "Save only my words")
                    .frame(maxWidth: .infinity, minHeight: 54)
            }
            .buttonStyle(.borderedProminent)
            .tint(Pingu.accent)
            .disabled(journal.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || journal.isSaving)
            .padding(.horizontal, 24).padding(.vertical, 12)
            .background(Color("PinguIce"))
        }
        .background(Color("PinguIce").ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { focused = true }
    }
}

// MARK: - Journal

struct GuestJournalListView: View {
    @ObservedObject var journal: GuestJournalViewModel

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
                    Text("Nothing saved yet.").foregroundStyle(Pingu.slate)
                case .loaded(let entries):
                    List(entries) { entry in
                        NavigationLink(value: entry.id) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.originalWords).lineLimit(3).foregroundStyle(Pingu.ink)
                                Text(entry.updatedAt, format: .dateTime.day().month().hour().minute())
                                    .font(.caption).foregroundStyle(Pingu.slate)
                            }
                        }
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                if let notice = journal.notice {
                    HStack(alignment: .top) {
                        Label(notice, systemImage: "exclamationmark.shield")
                            .font(.subheadline).foregroundStyle(Pingu.ink)
                        Spacer()
                        Button("OK") { journal.notice = nil }
                    }
                    .padding(12)
                    .background(.white, in: RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("Journal")
            .navigationDestination(for: UUID.self) { id in
                GuestEntryDetailView(entryID: id, journal: journal)
            }
        }
    }
}

struct GuestEntryDetailView: View {
    let entryID: UUID
    @ObservedObject var journal: GuestJournalViewModel
    /// Owned here, outside the content that refreshes, so an open editor survives list reloads.
    @State private var editor: GuestEntryEditorViewModel?

    var body: some View {
        content
            .background(Color("PinguIce").ignoresSafeArea())
            .navigationTitle("Entry")
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
                Text("This entry no longer exists.").foregroundStyle(Pingu.slate)
            }
        }
    }

    private func detail(for entry: GuestJournalEntry) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("My words").font(.subheadline.weight(.semibold)).foregroundStyle(Pingu.slate)
                Text(entry.originalWords).font(.body).foregroundStyle(Pingu.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 18))
                Text(entry.updatedAt, format: .dateTime.day().month().year().hour().minute())
                    .font(.caption).foregroundStyle(Pingu.slate)
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
                    .font(.subheadline).foregroundStyle(Pingu.ink)
            }
            Button {
                // Close only when everything typed is saved and there's no warning to read.
                Task { if await editor.save() == .saved { onDone() } }
            } label: {
                Text(editor.isSaving ? "Saving…" : "Save")
                    .frame(maxWidth: .infinity, minHeight: 54)
            }
            .buttonStyle(.borderedProminent)
            .tint(Pingu.accent)
            .disabled(!editor.canSave)
        }
        .padding(24)
        .background(Color("PinguIce").ignoresSafeArea())
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
