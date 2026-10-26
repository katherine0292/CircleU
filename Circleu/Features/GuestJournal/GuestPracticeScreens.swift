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
                VStack(alignment: .leading, spacing: 16) {
                    if isEmpty {
                        emptyState
                    } else {
                        startCard
                        if let draft = practice.keptDraft { draftCard(draft) }
                        history
                    }
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

    private var isEmpty: Bool {
        if case .loaded(let messages) = practice.loadState { return messages.isEmpty && practice.keptDraft == nil }
        return false
    }

    /// The one primary action, as a picture card.
    private var startCard: some View {
        Button { path.append(.new(sourceEntryID: nil)) } label: {
            HStack(alignment: .bottom, spacing: 0) {
                HStack(spacing: 8) {
                    Text("Practice a message")
                    Image(systemName: "arrow.right").accessibilityHidden(true)
                }
                .font(GuestBrand.font(.title3, .bold)).foregroundStyle(.white)
                .padding(22)
                Spacer(minLength: 0)
                Image("GuestPinguPractising").resizable().scaledToFit().frame(height: 140)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, minHeight: 150, alignment: .bottomLeading)
            .background(GuestBrand.blue, in: RoundedRectangle(cornerRadius: 24))
            .contentShape(RoundedRectangle(cornerRadius: 24))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Practice a message")
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image("GuestPinguPractising").resizable().scaledToFit().frame(height: 220)
                .accessibilityHidden(true)
            Text("Nothing practised yet.").foregroundStyle(GuestBrand.muted)
            Button { path.append(.new(sourceEntryID: nil)) } label: {
                Label("Practice a message", systemImage: "arrow.right")
                    .labelStyle(GuestTrailingIconLabelStyle())
            }
            .buttonStyle(GuestBrandButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private func draftCard(_ draft: GuestPracticeDraft) -> some View {
        let preview = draft.wording.isEmpty ? draft.situation : draft.wording
        return Button { path.append(.new(sourceEntryID: draft.sourceEntryID)) } label: {
            HStack(spacing: 12) {
                Image(systemName: "pencil")
                    .font(.system(size: 16, weight: .semibold)).foregroundStyle(GuestBrand.blue)
                    .frame(width: 36, height: 36)
                    .background(GuestBrand.blue.opacity(0.1), in: Circle())
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Continue your draft").font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.blue)
                    if !preview.isEmpty {
                        Text(preview).font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted).lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(12)
            .background(.white, in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(GuestBrand.blue.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])))
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Continue your draft")
        .accessibilityValue(preview)
        .accessibilityAddTraits(.isButton)
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
        case .loaded(let all):
            let messages = all.filter { GuestSearch.matches($0, query) }
            if messages.isEmpty && !query.isEmpty {
                GuestPinguMessage(asset: "GuestPinguThoughtful", text: "No messages match “\(query)”.", height: 110)
            }
            ForEach(messages) { message in
                Button { path.append(.message(message.id)) } label: {
                    GuestPracticeRow(message: message, entries: journal.entries)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// A saved message as a sent bubble: the words, a journal icon when it came from an entry, and the date.
struct GuestPracticeRow: View {
    let message: GuestPracticeMessage
    let entries: [GuestJournalEntry]

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(message.wording).lineLimit(3).foregroundStyle(GuestBrand.ink)
                .padding(.horizontal, 16).padding(.vertical, 12)
                .background(.white, in: GuestBubbleShape())
                .overlay(GuestBubbleShape().stroke(GuestBrand.muted.opacity(0.18)))
            HStack(spacing: 6) {
                if message.sourceEntryID != nil {
                    GuestBrandIcon(asset: "GuestIconJournal", size: 16)
                }
                Text(message.updatedAt, format: .dateTime.day().month())
            }
            .font(GuestBrand.font(.caption)).foregroundStyle(GuestBrand.muted)
        }
        .padding(.leading, 40)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .contentShape(Rectangle())
        .accessibilityHint(GuestPracticeTag.label(sourceEntryID: message.sourceEntryID, entries: entries))
    }
}

/// A chat bubble with its tail corner at the bottom right, for the person's own message.
struct GuestBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        UnevenRoundedRectangle(topLeadingRadius: 22, bottomLeadingRadius: 22, bottomTrailingRadius: 6,
                               topTrailingRadius: 22, style: .continuous).path(in: rect)
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
    /// Situation and Goal stay folded into chips until opened, or until they have words.
    @State private var showSituation = false
    @State private var showGoal = false
    @FocusState private var focus: Field?

    private enum Field { case situation, goal }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                tag
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
            if composer.saved != nil && !composer.isEditing {
                ToolbarItem(placement: .primaryAction) {
                    Button(role: .destructive) { confirmDelete = true } label: {
                        Image(systemName: "trash").foregroundStyle(GuestBrand.danger)
                    }
                    .accessibilityLabel("Delete message")
                }
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

    /// Where the message came from: a journal icon and the entry's opening words, or "On its own".
    private var tag: some View {
        HStack(spacing: 6) {
            if composer.sourceEntryID != nil { GuestBrandIcon(asset: "GuestIconJournal", size: 16) }
            Text(GuestPracticeTag.label(sourceEntryID: composer.sourceEntryID, entries: journal.entries))
        }
        .font(GuestBrand.font(.caption, .semibold)).foregroundStyle(GuestBrand.blue)
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(.white, in: Capsule())
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
            details
            wordingBubble
            if composer.didCopy {
                Text("Copied. Not saved or sent.")
                    .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                    .frame(maxWidth: .infinity, alignment: .trailing)
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
        }
        // Nothing changes while saving, so what's saved (and cleared from drafts) is what's shown.
        .disabled(composer.isSaving)
        .onAppear {
            showSituation = showSituation || !composer.situation.isEmpty
            showGoal = showGoal || !composer.goal.isEmpty
        }
    }

    /// Situation and Goal: optional, so they start as "+" chips and open into a field.
    @ViewBuilder private var details: some View {
        if !showSituation || !showGoal {
            HStack(spacing: 8) {
                if !showSituation { addChip("Situation") { showSituation = true; focus = .situation } }
                if !showGoal { addChip("Goal") { showGoal = true; focus = .goal } }
            }
        }
        if showSituation {
            field("Situation", icon: "person.2", text: $composer.situation, prompt: "What’s going on?")
                .focused($focus, equals: .situation)
        }
        if showGoal {
            field("Goal", icon: "scope", text: $composer.goal, prompt: "What do you hope happens?")
                .focused($focus, equals: .goal)
        }
    }

    private func addChip(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: "plus")
                .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.blue)
                .padding(.horizontal, 14).frame(minHeight: 44)
                .background(.white, in: Capsule())
                .overlay(Capsule().strokeBorder(GuestBrand.blue.opacity(0.3)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add \(title.lowercased())")
    }

    /// The person's words in a sent-message bubble, with Copy in its corner.
    private var wordingBubble: some View {
        ZStack(alignment: .bottomTrailing) {
            TextEditor(text: $composer.wording)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 12).padding(.top, 12).padding(.bottom, 52)
                .frame(minHeight: 180)
                .background(.white, in: GuestBubbleShape())
                .accessibilityLabel("Your wording")
            Button {
                composer.copy { UIPasteboard.general.string = $0 }
            } label: {
                Image(systemName: composer.didCopy ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 17, weight: .semibold)).foregroundStyle(GuestBrand.blue)
                    .frame(width: 44, height: 44)
                    .background(GuestBrand.blue.opacity(0.1), in: Circle())
            }
            .buttonStyle(.plain)
            .padding(10)
            .disabled(!composer.canCopy)
            .opacity(composer.canCopy ? 1 : 0.45)
            .accessibilityLabel(composer.didCopy ? "Copied" : "Copy")
        }
    }

    @ViewBuilder private var suggestionsSection: some View {
        if composer.suggester != nil {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Button {
                        Task { await composer.suggest() }
                    } label: {
                        HStack(spacing: 10) {
                            Image("GuestPinguThoughtful").resizable().scaledToFit().frame(width: 52, height: 52)
                                .accessibilityHidden(true)
                            Text(composer.isSuggesting ? "Making suggestions…" : "Get a suggestion")
                                .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(.white)
                                .padding(.horizontal, 14).padding(.vertical, 10)
                                .background(GuestBrand.blue, in: UnevenRoundedRectangle(
                                    topLeadingRadius: 16, bottomLeadingRadius: 4, bottomTrailingRadius: 16,
                                    topTrailingRadius: 16, style: .continuous))
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(composer.isSuggesting)
                    Spacer()
                    if composer.wordingBeforeSuggestion != nil {
                        Button("Undo") { composer.undoSuggestion() }
                            .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.blue)
                            .frame(minHeight: 44)
                            .accessibilityLabel("Undo suggestion")
                    }
                }
                if let error = composer.suggestionError {
                    Text(error).font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                }
                if let suggestions = composer.suggestions {
                    Text(suggestions.source.label).font(GuestBrand.font(.caption)).foregroundStyle(GuestBrand.muted)
                    if composer.suggestionsAreStale {
                        Label("Based on earlier words. Get a suggestion again to update.",
                              systemImage: "clock.arrow.circlepath")
                            .font(GuestBrand.font(.footnote, .semibold)).foregroundStyle(GuestBrand.ink)
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 12) {
                            ForEach(suggestions.options) { option in optionCard(option) }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .padding(.horizontal, -24).contentMargins(.horizontal, 24, for: .scrollContent)
                }
            }
        }
    }

    private func optionCard(_ option: GuestWordingOption) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(option.tone).font(GuestBrand.font(.caption, .bold)).foregroundStyle(GuestBrand.blue)
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(GuestBrand.blue.opacity(0.1), in: Capsule())
            Text(option.text).font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Button { composer.use(option) } label: {
                Text("Use this").padding(.horizontal, 18).frame(minHeight: 44)
                    .background(GuestBrand.blue, in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(.white)
            .accessibilityLabel("Use the \(option.tone.lowercased()) option")
        }
        .padding(16)
        .frame(width: 272, alignment: .leading)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private var savedMessage: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !composer.situation.isEmpty { detail("Situation", icon: "person.2", composer.situation) }
            if !composer.goal.isEmpty { detail("Goal", icon: "scope", composer.goal) }
            Text(composer.wording).font(GuestBrand.font(.title3)).foregroundStyle(.white)
                .padding(18).background(GuestBrand.blue, in: GuestBubbleShape())
                .padding(.leading, 32)
                .frame(maxWidth: .infinity, alignment: .trailing)
            HStack(spacing: 8) {
                GuestBrandIcon(asset: "GuestPinguThumbsUp", size: 40)
                Text("Saved · not sent")
            }
            .font(GuestBrand.font(.footnote, .semibold)).foregroundStyle(GuestBrand.muted)
            .frame(maxWidth: .infinity, alignment: .trailing)
            if composer.didCopy {
                Text("Copied. Not saved or sent.")
                    .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            Button {
                composer.copy { UIPasteboard.general.string = $0 }
            } label: {
                Label(composer.didCopy ? "Copied" : "Copy", systemImage: composer.didCopy ? "checkmark" : "doc.on.doc")
            }
            .buttonStyle(GuestBrandButtonStyle())
            .disabled(!composer.canCopy)
            Button("Edit") { composer.edit() }
                .buttonStyle(GuestBrandButtonStyle(filled: false))
        }
    }

    private func field(_ title: String, icon: String, text: Binding<String>, prompt: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: icon).foregroundStyle(GuestBrand.muted).accessibilityHidden(true)
            TextField(title, text: text, prompt: Text(prompt), axis: .vertical)
                .lineLimit(1...4)
                .accessibilityLabel(title)
        }
        .padding(12)
        .background(.white, in: RoundedRectangle(cornerRadius: 14))
    }

    private func detail(_ title: String, icon: String, _ text: String) -> some View {
        Label { Text(text) } icon: { Image(systemName: icon) }
            .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.muted)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title): \(text)")
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
