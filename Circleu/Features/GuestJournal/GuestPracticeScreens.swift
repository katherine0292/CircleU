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
    @Environment(\.dynamicTypeSize) private var typeSize

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
            VStack(spacing: 0) {
                if !typeSize.isAccessibilitySize {
                    GuestScene(.practiceStudio)
                }
                HStack(spacing: 8) {
                    Text("Practice a message")
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 8)
                    Image(systemName: "arrow.right").accessibilityHidden(true)
                }
                .font(GuestBrand.font(.headline, .semibold)).foregroundStyle(.white)
                .padding(.horizontal, 20).padding(.vertical, 16)
                .frame(maxWidth: .infinity, minHeight: 54)
                .background(GuestBrand.blue)
            }
            .frame(maxWidth: .infinity)
            .background(GuestBrand.wash)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .contentShape(RoundedRectangle(cornerRadius: 24))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Practice a message")
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            startCard
            Text("Nothing practised yet.").foregroundStyle(GuestBrand.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
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
    @State private var voiceTarget: VoiceTarget?
    /// "Compare with mine" on the result screen.
    @State private var comparing = false
    /// Context and tone stay folded on the first screen; words come first.
    @State private var showContext = false
    @Environment(\.dynamicTypeSize) private var typeSize
    private enum VoiceTarget: String, Identifiable {
        case wording, reply, context
        var id: String { rawValue }
    }

    private enum Field { case situation, goal, wording }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                tag
                if composer.isEditing {
                    switch composer.stage {
                    case .prepare: prepareForm
                    case .guide: guideForm
                    case .result: resultView
                    case .refine: form
                    case .reply: replyForm
                    }
                } else { savedMessage }
                // Both can apply: a save warning, then a failed delete.
                ForEach([deleteError, composer.isEditing ? nil : composer.saveError].compactMap { $0 }, id: \.self) { error in
                    Label(error, systemImage: "exclamationmark.circle")
                        .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
                }
            }
            .padding(24)
        }
        .accessibilityIdentifier("Practice form")
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            if composer.isEditing {
                VStack(alignment: .leading, spacing: 8) {
                    if let error = composer.saveError {
                        Label(error, systemImage: "exclamationmark.circle")
                            .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    switch composer.stage {
                    case .prepare:
                        // Words first: one filled action to review them; saving as they are stays available.
                        if composer.canFindWordsFromIntent {
                            Button("Find words from my intent") { focus = nil; Task { await composer.findWordsFromIntent() } }
                                .buttonStyle(GuestBrandButtonStyle())
                        } else {
                            Button("Review wording") { focus = nil; Task { await composer.reviewWording() } }
                                .buttonStyle(GuestBrandButtonStyle()).disabled(!composer.canReviewWording)
                        }
                        Button("Save without feedback") {
                            focus = nil
                            Task { if await composer.saveWithoutFeedback() { await finishSave() } }
                        }
                        .buttonStyle(GuestBrandButtonStyle(filled: false)).disabled(!composer.canCopy || composer.isSaving)
                    case .guide:
                        Button("Continue") { focus = nil; composer.continueGuidance() }
                            .buttonStyle(GuestBrandButtonStyle()).disabled(!composer.canContinueGuidance)
                    case .result:
                        Button("Use this wording") { composer.useSuggestedWording() }
                            .buttonStyle(GuestBrandButtonStyle()).disabled(composer.suggestedWording == nil)
                        if composer.suggestedWording != nil {
                            Button(comparing ? "Hide comparison" : "Compare with mine") { withAnimation { comparing.toggle() } }
                                .buttonStyle(GuestBrandButtonStyle(filled: false))
                        }
                        Button("Keep my wording") { composer.keepMyWording() }
                            .buttonStyle(GuestBrandButtonStyle(filled: false))
                    case .reply:
                        Button("Continue") { focus = nil; composer.continueReply() }
                            .buttonStyle(GuestBrandButtonStyle()).disabled(!composer.canContinueReply)
                    case .refine:
                        saveButton
                        if composer.wordingBeforeSuggestion != nil {
                            // Under Save, where it can't be covered by the pinned footer.
                            Button("Undo") { composer.undoSuggestion() }
                                .buttonStyle(GuestBrandButtonStyle(filled: false))
                                .accessibilityLabel("Undo suggestion")
                        }
                    }
                }
                .padding(.horizontal, 24).padding(.vertical, 12)
                .background(GuestBrand.ice)
            }
        }
        .onChange(of: composer.saveError) { _, error in
            if let error {
                // Give failure feedback room without discarding the person's draft.
                focus = nil
                UIAccessibility.post(notification: .announcement, argument: error)
            }
        }
        .background(GuestBrand.ice.ignoresSafeArea())
        .navigationTitle(composer.isEditing ? stageTitle : "Conversation")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Back") {
                    // A new message's words are kept as a draft; an edit to a saved one asks first.
                    if composer.isEditing && composer.stage == .reply {
                        focus = nil
                        composer.stage = .refine
                    } else if composer.isEditing && composer.stage == .guide {
                        focus = nil
                        composer.closeGuidance() // My words and intent are kept.
                    } else if composer.isEditing && composer.stage == .result {
                        composer.stage = .prepare // Nothing applied; my words are unchanged.
                    } else if composer.saved != nil && composer.isEditing && composer.hasChanges {
                        confirmDiscard = true
                    } else {
                        dismiss()
                    }
                }
                .disabled(!composer.canLeave)
            }
            if composer.isEditing && composer.stage == .refine {
                ToolbarItem(placement: .primaryAction) {
                    Button("Details", systemImage: "slider.horizontal.3") { focus = nil; composer.stage = .prepare }
                }
            }
            if composer.saved != nil && !composer.isEditing {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button { composer.edit() } label: { Image(systemName: "pencil") }
                        .accessibilityLabel("Edit")
                    // Rarely used, so it waits in the ••• menu; it still asks first.
                    Menu {
                        Button("Delete message", systemImage: "trash", role: .destructive) { confirmDelete = true }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .accessibilityLabel("More")
                }
            }
        }
        .sheet(item: $voiceTarget) { target in
            GuestVoiceReviewSheet(engine: practice.makeDictationEngine()) { text in
                switch target {
                case .wording: composer.wording = append(text, to: composer.wording)
                case .reply: composer.replyText = append(text, to: composer.replyText)
                case .context: composer.replyContext = append(text, to: composer.replyContext)
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

    private var stageTitle: String {
        switch composer.stage {
        case .prepare, .guide: "Prepare"
        case .result: "Refine"
        case .refine: "Your wording"
        case .reply: "Their reply"
        }
    }

    /// Words first. Guidance, context and tone are there when wanted, never required.
    private var prepareForm: some View {
        VStack(alignment: .leading, spacing: 18) {
            hero("What would you like to say?", asset: "GuestPinguPractising")
            wordingBubble
            voiceButton(.wording)
            intentCard
            if let warning = practice.draftWarning {
                Text(warning).font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
            }
            DisclosureGroup("Context and tone", isExpanded: $showContext) { contextAndTone }
                .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.blue)
        }
        .onAppear {
            showSituation = showSituation || !composer.situation.isEmpty
            showGoal = showGoal || !composer.goal.isEmpty
            showContext = showContext || !composer.situation.isEmpty
        }
    }

    /// "Help me get started" opens guidance; an intent from it is shown as intent, not as my words.
    @ViewBuilder private var intentCard: some View {
        let intent = composer.goal.trimmingCharacters(in: .whitespacesAndNewlines)
        if intent.isEmpty {
            Button("Help me get started", systemImage: "questionmark.circle") { focus = nil; composer.openGuidance() }
                .font(GuestBrand.font(.subheadline, .semibold)).frame(minHeight: 44)
        } else {
            Button { focus = nil; composer.openGuidance() } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your intent").font(GuestBrand.font(.caption, .semibold)).foregroundStyle(GuestBrand.blue)
                    Text(intent).font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading).padding(14)
                .background(.white, in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Your intent")
            .accessibilityValue(intent)
            .accessibilityHint("Change it")
        }
    }

    /// Optional guidance: what should happen, and the situation if it helps. Nothing is requested here.
    private var guideForm: some View {
        VStack(alignment: .leading, spacing: 18) {
            hero("What do you want to happen?", asset: "GuestPinguThoughtful")
            field("Your intent", icon: "scope", text: $composer.goal, prompt: "Agree on a fair split")
                .focused($focus, equals: .goal)
            field("Situation", icon: "person.2", text: $composer.situation, prompt: "What’s going on? Optional")
                .focused($focus, equals: .situation)
            Text("Kept with your draft. Nothing is sent.")
                .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
        }
        .onAppear { focus = .goal }
    }

    /// "Find your words": one suggestion first, the rest on request, my words always kept.
    private var resultView: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !typeSize.isAccessibilitySize {
                GuestScene(.refineWorkbench).clipShape(RoundedRectangle(cornerRadius: 24))
            }
            Text("Find your words").font(GuestBrand.font(.title2, .bold)).foregroundStyle(GuestBrand.ink)
                .accessibilityAddTraits(.isHeader)
            if composer.isSuggesting {
                HStack(spacing: 12) {
                    ProgressView()
                    Text("Reviewing your wording").foregroundStyle(GuestBrand.muted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else if let error = composer.suggestionError {
                Label(error, systemImage: "exclamationmark.circle")
                    .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
                Button("Try again") { Task { await composer.suggest() } }
                    .font(GuestBrand.font(.subheadline, .semibold)).frame(minHeight: 44)
            } else if let option = composer.suggestedWording, let suggestions = composer.suggestions {
                HStack(spacing: 10) {
                    GuestBrandIcon(asset: "GuestPinguThoughtful", size: 44)
                    Text("A \(option.tone.lowercased()) way to say it")
                        .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.muted)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Suggested wording").font(GuestBrand.font(.caption, .semibold)).foregroundStyle(.white.opacity(0.85))
                    Text(option.text).font(GuestBrand.font(.title3, .semibold)).foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading).padding(18)
                .background(GuestBrand.blue, in: RoundedRectangle(cornerRadius: 20))
                .accessibilityElement(children: .combine)
                Text(suggestions.source.label).font(GuestBrand.font(.caption)).foregroundStyle(GuestBrand.muted)
                if comparing { comparison }
            }
        }
    }

    /// Mine (or my intent) beside the other tones; each can be used on its own.
    private var comparison: some View {
        VStack(alignment: .leading, spacing: 12) {
            let mine = composer.wording.trimmingCharacters(in: .whitespacesAndNewlines)
            VStack(alignment: .leading, spacing: 6) {
                Text(composer.resultIsFromIntent ? "From your intent" : "My wording")
                    .font(GuestBrand.font(.caption, .semibold)).foregroundStyle(GuestBrand.blue)
                Text(composer.resultIsFromIntent ? composer.goal : mine).font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(14)
            .background(.white, in: RoundedRectangle(cornerRadius: 16))
            .accessibilityElement(children: .combine)
            ForEach(composer.otherWordings) { option in
                VStack(alignment: .leading, spacing: 8) {
                    Text(option.tone).font(GuestBrand.font(.caption, .bold)).foregroundStyle(GuestBrand.blue)
                    Text(option.text).font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Button("Use this") { composer.use(option); composer.stage = .refine }
                        .font(GuestBrand.font(.subheadline, .semibold)).frame(minHeight: 44)
                        .accessibilityLabel("Use the \(option.tone.lowercased()) option")
                }
                .frame(maxWidth: .infinity, alignment: .leading).padding(14)
                .background(.white, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private var contextAndTone: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Choose a scene").font(GuestBrand.font(.headline, .semibold))
            LazyVGrid(columns: [GridItem(.adaptive(minimum: typeSize.isAccessibilitySize ? 140 : 100))], spacing: 10) {
                ForEach(["Work", "Family", "Friends", "Relationship", "Other"], id: \.self) { scene in
                    Button { composer.scene = scene } label: {
                        VStack(spacing: 6) {
                            Image(sceneAsset(scene)).resizable().scaledToFit().frame(height: 56).accessibilityHidden(true)
                            Text(scene).font(GuestBrand.font(.caption, .semibold))
                                .fixedSize(horizontal: false, vertical: true)
                            if composer.scene == scene { Image(systemName: "checkmark.circle.fill").accessibilityHidden(true) }
                        }
                        .frame(maxWidth: .infinity).padding(10)
                        .background(.white, in: RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(
                            composer.scene == scene ? GuestBrand.blue : .clear, lineWidth: 2))
                    }
                    .buttonStyle(.plain).accessibilityAddTraits(composer.scene == scene ? .isSelected : [])
                }
            }
            Text("Tone").font(GuestBrand.font(.headline, .semibold))
            ViewThatFits(in: .horizontal) {
                HStack { toneButtons }
                VStack(alignment: .leading) { toneButtons }
            }
            details
        }
        .padding(.top, 8)
        .foregroundStyle(GuestBrand.ink)
    }

    private var toneButtons: some View {
        ForEach(["Soft", "Balanced", "Firm"], id: \.self) { tone in
            Button { composer.tone = tone } label: {
                Text(tone).font(GuestBrand.font(.subheadline, .semibold)).fixedSize()
                    .padding(.horizontal, 16).frame(minHeight: 44)
                    .background(composer.tone == tone ? GuestBrand.blue.opacity(0.15) : .white, in: Capsule())
            }
            .buttonStyle(.plain).accessibilityAddTraits(composer.tone == tone ? .isSelected : [])
        }
    }

    private var replyForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !typeSize.isAccessibilitySize {
                GuestScene(.replyReading).clipShape(RoundedRectangle(cornerRadius: 24))
            }
            Text("Keep the conversation going").font(GuestBrand.font(.title2, .bold)).foregroundStyle(GuestBrand.ink)
                .fixedSize(horizontal: false, vertical: true).accessibilityAddTraits(.isHeader)
            Text("Paste their reply, add context, or both")
                .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.muted)
            conversationHistory
            if !composer.wording.isEmpty {
                DisclosureGroup("Your prepared wording") { Text(composer.wording).font(GuestBrand.font(.body)) }
            }
            Text("Their reply").font(GuestBrand.font(.headline, .semibold))
            TextEditor(text: $composer.replyText).scrollContentBackground(.hidden)
                .frame(minHeight: 120).padding(12).background(.white, in: RoundedRectangle(cornerRadius: 18))
                .accessibilityLabel("Their reply")
            voiceButton(.reply)
            Text("More context").font(GuestBrand.font(.headline, .semibold))
            TextEditor(text: $composer.replyContext).scrollContentBackground(.hidden)
                .frame(minHeight: 100).padding(12).background(.white, in: RoundedRectangle(cornerRadius: 18))
                .accessibilityLabel("More context")
            voiceButton(.context)
        }
    }

    @ViewBuilder private var conversationHistory: some View {
        if let conversation = composer.conversation, !conversation.turns.isEmpty {
            DisclosureGroup("Conversation · \(conversation.turns.count) notes") {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(conversation.turns) { turn in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(turn.kind.label).font(GuestBrand.font(.caption, .semibold)).foregroundStyle(GuestBrand.blue)
                            Text(turn.text).font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading).padding(14)
                        .background(.white, in: RoundedRectangle(cornerRadius: 16))
                        .accessibilityElement(children: .combine)
                    }
                }
            }
            .font(GuestBrand.font(.subheadline, .semibold))
        }
    }

    private func hero(_ title: String, asset: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Text(title).font(GuestBrand.font(.title2, .bold)).foregroundStyle(GuestBrand.ink)
                .fixedSize(horizontal: false, vertical: true).accessibilityAddTraits(.isHeader)
            if !typeSize.isAccessibilitySize {
                Spacer(minLength: 0)
                Image(asset).resizable().scaledToFit().frame(width: 88, height: 100).accessibilityHidden(true)
            }
        }
    }

    private func voiceButton(_ target: VoiceTarget) -> some View {
        Button { focus = nil; voiceTarget = target } label: { Label("Record", systemImage: "mic") }
            .font(GuestBrand.font(.subheadline, .semibold)).frame(minHeight: 44)
            .accessibilityLabel(target == .wording ? "Record your words" : target == .reply ? "Record their reply" : "Record context")
    }

    private func sceneAsset(_ scene: String) -> String {
        switch scene {
        case "Work": "GuestPinguWorkTag"
        case "Family": "GuestPinguFamilyTag"
        case "Friends": "GuestPinguFriendsTag"
        case "Relationship": "GuestPinguRelationshipTag"
        default: "GuestPinguThoughtful"
        }
    }

    private func append(_ text: String, to existing: String) -> String {
        [existing.trimmingCharacters(in: .whitespacesAndNewlines), text]
            .filter { !$0.isEmpty }.joined(separator: "\n")
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
            hero("Make it sound like you", asset: "GuestPinguThoughtful")
            conversationHistory
            if let original = composer.conversation?.originalWords, !original.isEmpty {
                DisclosureGroup("Your first words") {
                    Text(original).font(GuestBrand.font(.body)).frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.muted)
            }
            Text("Your wording")
                .font(GuestBrand.font(.title2, .bold)).foregroundStyle(GuestBrand.ink)
                .accessibilityAddTraits(.isHeader)
            if let warning = practice.draftWarning {
                Label(warning, systemImage: "info.circle")
                    .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
            }
            wordingBubble
            voiceButton(.wording)
            Button("Continue conversation", systemImage: "bubble.left.and.bubble.right") {
                focus = nil; composer.openReply()
            }
            .font(GuestBrand.font(.subheadline, .semibold)).frame(minHeight: 44)
            if composer.didCopy {
                Text("Copied. Not saved or sent.")
                    .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            suggestionsSection
        }
        // Nothing changes while saving, so what's saved (and cleared from drafts) is what's shown.
        .disabled(composer.isSaving)
        .onAppear {
            showSituation = showSituation || !composer.situation.isEmpty
            showGoal = showGoal || !composer.goal.isEmpty
        }
    }

    /// Kept outside the scroll content so suggestions and the keyboard cannot push it away.
    /// After a save: a new message's kept draft is cleared, and the history refreshed.
    private func finishSave() async {
        if composer.ownsDraft, let id = composer.draftID { practice.clearDraft(id: id) }
        await practice.load()
    }

    private var saveButton: some View {
        Button {
            Task {
                let wasNew = composer.saved == nil
                focus = nil
                if await composer.save(), wasNew { await finishSave() }
            }
        } label: {
            Text(composer.isSaving ? "Saving…" : "Save")
        }
        .buttonStyle(GuestBrandButtonStyle())
        .disabled(!composer.canSave)
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
                .focused($focus, equals: .wording)
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
                                .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.blue)
                                .padding(.horizontal, 14).padding(.vertical, 10)
                                // Tinted, not filled: Save is the screen's one primary action.
                                .background(GuestBrand.blue.opacity(0.12), in: UnevenRoundedRectangle(
                                    topLeadingRadius: 16, bottomLeadingRadius: 4, bottomTrailingRadius: 16,
                                    topTrailingRadius: 16, style: .continuous))
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(composer.isSuggesting)
                    Spacer()
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
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(GuestBrand.blue, lineWidth: 1.5))
            }
            .buttonStyle(.plain)
            .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.blue)
            .accessibilityLabel("Use the \(option.tone.lowercased()) option")
        }
        .padding(16)
        .containerRelativeFrame(.horizontal, alignment: .leading) { width, _ in
            min(320, max(180, width - 64))
        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .background(.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private var savedMessage: some View {
        VStack(alignment: .leading, spacing: 16) {
            conversationHistory
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
                Text("Copied. Not sent.") // Already saved, so only "not sent".
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
            Button("Continue conversation", systemImage: "bubble.left.and.bubble.right") { composer.openReply() }
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
