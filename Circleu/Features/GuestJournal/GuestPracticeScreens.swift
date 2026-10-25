import SwiftUI
import UIKit

/// Where a practice screen leads: a new message (on its own or from an entry), or a saved one.
enum GuestPracticeRoute: Hashable {
    case new(sourceEntryID: UUID?)
    case message(UUID)
}

// MARK: - Practice tab

struct GuestPracticeHomeView: View {
    @ObservedObject var practice: GuestPracticeViewModel
    @ObservedObject var journal: GuestJournalViewModel
    @State private var path: [GuestPracticeRoute] = []
    @State private var query = ""

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Button { path.append(.new(sourceEntryID: nil)) } label: {
                        Label("Practice a message", systemImage: "arrow.right")
                            .labelStyle(GuestTrailingIconLabelStyle())
                    }
                    .buttonStyle(GuestBrandButtonStyle())
                    if let draft = practice.keptDraft {
                        Button { path.append(.new(sourceEntryID: draft.sourceEntryID)) } label: {
                            Label {
                                Text("Continue your draft")
                            } icon: {
                                Image("GuestIconPractice").renderingMode(.original).accessibilityHidden(true)
                            }
                        }
                        .buttonStyle(GuestBrandButtonStyle(filled: false))
                    }
                    history
                }
                .padding(24)
            }
            .background(GuestBrand.ice.ignoresSafeArea())
            .navigationTitle("Practice")
            .searchable(text: $query, prompt: "Search messages")
            .onChange(of: practice.dataGeneration) { path = [] } // Delete all closes open messages.
            .navigationDestination(for: GuestPracticeRoute.self) { route in
                GuestPracticeRouteView(route: route, practice: practice, journal: journal)
            }
            .task { await practice.load() }
        }
    }

    @ViewBuilder private var history: some View {
        switch practice.loadState {
        case .loading:
            ProgressView().frame(maxWidth: .infinity)
        case .failed(let message):
            VStack(spacing: 12) {
                Text(message).multilineTextAlignment(.center)
                Button("Try again") { Task { await practice.load() } }
            }
            .frame(maxWidth: .infinity)
        case .loaded(let messages) where messages.isEmpty:
            VStack(spacing: 12) {
                Image("GuestPinguPractising").resizable().scaledToFit().frame(height: 160)
                    .accessibilityHidden(true)
                Text("Nothing practised yet.").foregroundStyle(GuestBrand.muted)
            }
            .frame(maxWidth: .infinity)
        case .loaded(let all):
            let messages = all.filter { GuestSearch.matches($0, query) }
            if messages.isEmpty {
                Text("No messages match “\(query)”.").foregroundStyle(GuestBrand.muted)
            }
            Text("Saved messages").font(GuestBrand.font(.headline, .semibold)).foregroundStyle(GuestBrand.ink)
                .accessibilityAddTraits(.isHeader)
            ForEach(messages) { message in
                Button { path.append(.message(message.id)) } label: {
                    GuestPracticeRow(message: message, entries: journal.entries)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct GuestPracticeRow: View {
    let message: GuestPracticeMessage
    let entries: [GuestJournalEntry]

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(message.wording).lineLimit(2).foregroundStyle(GuestBrand.ink)
                Text(GuestPracticeTag.label(sourceEntryID: message.sourceEntryID, entries: entries))
                    .font(GuestBrand.font(.caption, .semibold)).foregroundStyle(GuestBrand.blue).lineLimit(1)
                Text(message.updatedAt, format: .dateTime.day().month().hour().minute())
                    .font(GuestBrand.font(.caption)).foregroundStyle(GuestBrand.muted)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right").foregroundStyle(GuestBrand.muted).accessibilityHidden(true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
        .contentShape(Rectangle())
    }
}

/// Resolves a route into a screen. The composer is created once and kept for the screen's life,
/// so a history refresh (or a failed one) never replaces what's being written.
struct GuestPracticeRouteView: View {
    let route: GuestPracticeRoute
    @ObservedObject var practice: GuestPracticeViewModel
    @ObservedObject var journal: GuestJournalViewModel
    @State private var composer: GuestPracticeComposerViewModel?

    /// A kept draft from somewhere else (on its own vs. another entry) is never replaced silently.
    private var otherDraft: GuestPracticeDraft? {
        guard composer == nil, case .new(let sourceEntryID) = route, let draft = practice.keptDraft,
              draft.sourceEntryID != sourceEntryID else { return nil }
        return draft
    }

    var body: some View {
        Group {
            if let composer {
                GuestPracticeMessageView(composer: composer, practice: practice, journal: journal)
            } else if let draft = otherDraft {
                VStack(alignment: .leading, spacing: 16) {
                    Text("You have an unsaved practice draft")
                        .font(GuestBrand.font(.title3, .bold)).foregroundStyle(GuestBrand.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text(GuestPracticeTag.label(sourceEntryID: draft.sourceEntryID, entries: journal.entries))
                        .font(GuestBrand.font(.caption, .semibold)).foregroundStyle(GuestBrand.blue)
                    Text(draft.wording.isEmpty ? draft.situation : draft.wording).lineLimit(3)
                        .foregroundStyle(GuestBrand.ink)
                    Button("Continue that draft") {
                        composer = GuestPracticeComposerViewModel(store: practice.store, sourceEntryID: draft.sourceEntryID,
                                                                  suggester: practice.suggester, restoring: draft,
                                                                  practice: practice)
                    }
                    .buttonStyle(GuestBrandButtonStyle())
                    Button("Start new and discard it") {
                        practice.clearDraft(id: draft.id)
                        makeComposer()
                    }
                    .buttonStyle(GuestBrandButtonStyle(filled: false))
                }
                .padding(24)
                .frame(maxHeight: .infinity, alignment: .top)
            } else if case .failed(let message) = practice.loadState {
                VStack(spacing: 16) {
                    Text(message).multilineTextAlignment(.center)
                    Button("Try again") { Task { await practice.load() } }
                }
                .padding(24)
            } else if case .loading = practice.loadState {
                ProgressView()
            } else {
                Text("This message no longer exists.").foregroundStyle(GuestBrand.muted)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GuestBrand.ice.ignoresSafeArea())
        .onAppear(perform: makeComposer)
        .onChange(of: practice.loadState) { makeComposer() }
    }

    private func makeComposer() {
        guard composer == nil, otherDraft == nil else { return }
        switch route {
        case .new(let sourceEntryID):
            // A kept draft for the same start (on its own, or the same entry) is restored.
            let draft = practice.keptDraft.flatMap { $0.sourceEntryID == sourceEntryID ? $0 : nil }
            composer = GuestPracticeComposerViewModel(store: practice.store, sourceEntryID: sourceEntryID,
                                                      suggester: practice.suggester, restoring: draft,
                                                      practice: practice)
        case .message(let id):
            if let message = practice.message(id: id) {
                composer = GuestPracticeComposerViewModel(store: practice.store, message: message,
                                                          suggester: practice.suggester)
            }
        }
    }
}

// MARK: - Message

struct GuestPracticeMessageView: View {
    @ObservedObject var composer: GuestPracticeComposerViewModel
    @ObservedObject var practice: GuestPracticeViewModel
    @ObservedObject var journal: GuestJournalViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var confirmDiscard = false
    @State private var confirmDelete = false
    @State private var deleteError: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(GuestPracticeTag.label(sourceEntryID: composer.sourceEntryID, entries: journal.entries))
                    .font(GuestBrand.font(.caption, .semibold)).foregroundStyle(GuestBrand.blue)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(.white, in: Capsule())
                if composer.isEditing { form } else { savedMessage }
                // Both can apply: a save warning, then a failed delete.
                ForEach([deleteError, composer.saveError].compactMap { $0 }, id: \.self) { error in
                    Label(error, systemImage: "exclamationmark.circle")
                        .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
                }
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(GuestBrand.ice.ignoresSafeArea())
        .navigationTitle(composer.saved == nil ? "Practice" : "Message")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Back") {
                    // A new message's words are kept as a draft; an edit to a saved one asks first.
                    if composer.saved != nil && composer.isEditing && composer.hasChanges {
                        confirmDiscard = true
                    } else {
                        dismiss()
                    }
                }
                .disabled(!composer.canLeave)
            }
        }
        .alert("Discard your changes?", isPresented: $confirmDiscard) {
            Button("Keep editing", role: .cancel) {}
            Button("Discard", role: .destructive) { if composer.canLeave { dismiss() } }
        } message: {
            Text("Your words haven’t been saved.")
        }
        .alert("Delete this message?", isPresented: $confirmDelete) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { Task { await delete() } }
        }
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What would you like to say?")
                .font(GuestBrand.font(.title2, .bold)).foregroundStyle(GuestBrand.ink)
                .accessibilityAddTraits(.isHeader)
            if let warning = practice.draftWarning {
                Label(warning, systemImage: "info.circle")
                    .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
            }
            field("Situation", text: $composer.situation, prompt: "What’s going on?")
            field("Goal", text: $composer.goal, prompt: "What do you hope happens?")
            VStack(alignment: .leading, spacing: 6) {
                Text("Your wording").font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.muted)
                TextEditor(text: $composer.wording)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .frame(minHeight: 160)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18))
                    .accessibilityLabel("Your wording")
            }
            suggestionsSection
            Button {
                Task {
                    let wasNew = composer.saved == nil
                    let owned = composer.ownsDraft
                    if await composer.save() {
                        if wasNew, owned, let id = composer.draftID { practice.clearDraft(id: id) }
                        await practice.load()
                    }
                }
            } label: {
                Text(composer.isSaving ? "Saving…" : "Save")
            }
            .buttonStyle(GuestBrandButtonStyle())
            .disabled(!composer.canSave)
            copyButton(filled: false)
            Text("Copying won’t save or send it.")
                .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
        }
        // Nothing changes while saving, so what's saved (and cleared from drafts) is what's shown.
        .disabled(composer.isSaving)
    }

    @ViewBuilder private var suggestionsSection: some View {
        if composer.suggester != nil {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Button {
                        Task { await composer.suggest() }
                    } label: {
                        Label(composer.isSuggesting ? "Making suggestions…" : "Get a suggestion", systemImage: "lightbulb")
                    }
                    .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.blue)
                    .disabled(composer.isSuggesting)
                    Spacer()
                    if composer.wordingBeforeSuggestion != nil {
                        Button("Undo") { composer.undoSuggestion() }
                            .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.blue)
                            .accessibilityLabel("Undo suggestion")
                    }
                }
                .frame(minHeight: 44)
                if let error = composer.suggestionError {
                    Text(error).font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                }
                if let suggestions = composer.suggestions {
                    Text(suggestions.source.label).font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                    if composer.suggestionsAreStale {
                        Label("Based on earlier details or wording. Get a suggestion again to update.",
                              systemImage: "clock.arrow.circlepath")
                            .font(GuestBrand.font(.footnote, .semibold)).foregroundStyle(GuestBrand.ink)
                    }
                    ForEach(suggestions.options) { option in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(option.tone).font(GuestBrand.font(.caption, .semibold)).foregroundStyle(GuestBrand.blue)
                            Text(option.text).font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink)
                            Button { composer.use(option) } label: {
                                Text("Use this").frame(minWidth: 44, minHeight: 44).contentShape(Rectangle())
                            }
                            .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.blue)
                                .accessibilityLabel("Use the \(option.tone.lowercased()) option")
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white, in: RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
        }
    }

    private var savedMessage: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !composer.situation.isEmpty { labelled("Situation", composer.situation) }
            if !composer.goal.isEmpty { labelled("Goal", composer.goal) }
            Text(composer.wording).font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 18))
            Label("Saved · not sent", systemImage: "checkmark.circle")
                .font(GuestBrand.font(.footnote, .semibold)).foregroundStyle(GuestBrand.muted)
            copyButton(filled: true)
            Button("Edit") { composer.edit() }
                .buttonStyle(GuestBrandButtonStyle(filled: false))
            Button("Delete message", role: .destructive) { confirmDelete = true }
                .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.danger)
                .frame(maxWidth: .infinity, minHeight: 44).contentShape(Rectangle())
        }
    }

    private func copyButton(filled: Bool) -> some View {
        Button {
            composer.copy { UIPasteboard.general.string = $0 }
        } label: {
            Label(composer.didCopy ? "Copied" : "Copy", systemImage: composer.didCopy ? "checkmark" : "doc.on.doc")
        }
        .buttonStyle(GuestBrandButtonStyle(filled: filled))
        .disabled(!composer.canCopy)
    }

    private func field(_ title: String, text: Binding<String>, prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.muted)
            TextField(title, text: text, prompt: Text(prompt), axis: .vertical)
                .lineLimit(1...4)
                .padding(12)
                .background(.white, in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private func labelled(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.muted)
            Text(text).font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink)
        }
    }

    private func delete() async {
        guard let id = composer.saved?.id else { return }
        if let error = await practice.deleteMessage(id: id, journal: journal) {
            deleteError = error // Kept; nothing changed.
        } else {
            dismiss()
        }
    }
}

struct GuestTrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack { configuration.title; Spacer(); configuration.icon }
    }
}
