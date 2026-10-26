import SwiftUI
import UIKit

/// Guest experience shell: Today, Journal and Practice.
struct GuestHomeView: View {
    @ObservedObject var journal: GuestJournalViewModel
    @ObservedObject var practice: GuestPracticeViewModel
    let makeDictationEngine: () -> any GuestDictationEngine
    let suggester: any GuestSuggesting
    @State private var tab: Tab = .today

    enum Tab: Hashable { case today, journal, practice }

    var body: some View {
        TabView(selection: $tab) {
            GuestTodayView(journal: journal, practice: practice, makeDictationEngine: makeDictationEngine,
                           onSaved: { tab = .journal })
                .tabItem { GuestTabLabel(title: "Today", icon: "GuestIconToday") }
                .tag(Tab.today)
            GuestJournalListView(journal: journal, practice: practice, suggester: suggester)
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
    @ObservedObject var practice: GuestPracticeViewModel
    let makeDictationEngine: () -> any GuestDictationEngine
    let onSaved: () -> Void

    var body: some View {
        NavigationStack {
            // Straight to writing or talking: the text box and the big microphone, no extra tap.
            GuestWriteView(journal: journal, dictationEngine: makeDictationEngine(),
                           heading: "What’s on your mind?", showsLogo: true, onSaved: onSaved)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            GuestSettingsView(journal: journal, practice: practice)
                        } label: {
                            Image(systemName: "gearshape")
                        }
                        .accessibilityLabel("Settings")
                    }
                }
        }
    }
}

// MARK: - Write

struct GuestWriteView: View {
    @ObservedObject var journal: GuestJournalViewModel
    @StateObject private var dictation: GuestDictationViewModel
    let heading: String
    /// Today shows the CircleU logo in the toolbar.
    let showsLogo: Bool
    let onSaved: () -> Void
    @StateObject private var nudge = GuestNudgeModel()
    @FocusState private var focused: Bool
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    @AppStorage(GuestAvatars.storageKey) private var avatarID = GuestAvatars.defaultID
    @State private var choosingPingu = false

    init(journal: GuestJournalViewModel, dictationEngine: @autoclosure @escaping () -> any GuestDictationEngine,
         heading: String = "Start with your words.", showsLogo: Bool = false,
         onSaved: @escaping () -> Void) {
        self.journal = journal
        self.heading = heading
        self.showsLogo = showsLogo
        self.onSaved = onSaved
        _dictation = StateObject(wrappedValue: GuestDictationViewModel(journal: journal, engine: dictationEngine()))
    }

    var body: some View {
        // Scrolls rather than squeezing when the keyboard is up; Save stays visible above it.
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // While typing, the microphone moves up beside the heading so the nudge and the words
                // fit above the keyboard.
                if focused {
                    HStack(spacing: 12) {
                        headingText
                        Spacer(minLength: 0)
                        micButton(size: 52)
                    }
                } else {
                    headingText
                    micCard
                }
                prompts
                TextEditor(text: $journal.draft)
                    .focused($focused)
                    .disabled(dictation.isActive) // Spoken words are going in; type again after Stop.
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .frame(minHeight: 200)
                    .background(.white, in: RoundedRectangle(cornerRadius: 18))
                    .overlay(alignment: .topLeading) {
                        // A pencil instead of placeholder text, only while the box is empty.
                        if journal.draft.isEmpty {
                            Image(systemName: "pencil")
                                .font(.system(size: 18, weight: .semibold)).foregroundStyle(GuestBrand.muted.opacity(0.6))
                                .padding(.leading, 18).padding(.top, 20)
                                .allowsHitTesting(false).accessibilityHidden(true)
                        }
                    }
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
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: focused)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: dictation.isActive)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            let empty = journal.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            // One Save. A reflection is offered afterwards, on Journal, and only if wanted.
            Button {
                dictation.stopForSave() // Saving while listening keeps the words so far.
                Task { if await journal.saveDraft() { onSaved() } }
            } label: {
                Text(journal.isSaving ? "Saving…" : "Save")
            }
            .buttonStyle(GuestBrandButtonStyle())
            .disabled(empty || journal.isSaving)
            .padding(.horizontal, 24).padding(.vertical, 12)
            .background(GuestBrand.ice)
        }
        .background(GuestBrand.ice.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if showsLogo {
                ToolbarItem(placement: .topBarLeading) {
                    GuestBrandIcon(asset: "GuestIconLogo", size: 32)
                }
            }
        }
        .sheet(isPresented: $choosingPingu) { GuestAvatarPicker(selection: $avatarID) }
        // No automatic keyboard: it would cover the microphone. Tap the text to type.
        // Leaving the app or this screen stops listening; the words so far stay in the draft.
        // Only `.background`: the permission alert makes the app `.inactive`, and calls arrive
        // as audio-session interruptions.
        .onChange(of: scenePhase) { _, phase in if phase == .background { dictation.interrupt() } }
        .onChange(of: journal.draft) { _, words in nudge.wordsChanged(to: words) }
        .onDisappear { dictation.interrupt() }
    }

    private var headingText: some View {
        Text(heading)
            .font(GuestBrand.font(focused ? .title2 : .title, .bold)).foregroundStyle(GuestBrand.ink)
            .accessibilityAddTraits(.isHeader)
    }

    /// The ice-floe scene with the big microphone on its quiet right side. While listening, Pingu
    /// listens in the ripples, with stop and cancel below. The art is decorative and left out at
    /// the largest text sizes, where the microphone stays.
    private var micCard: some View {
        let showsArt = !typeSize.isAccessibilitySize
        return Group {
            if dictation.isActive {
                VStack(spacing: 12) {
                    if showsArt {
                        GuestScene(asset: "GuestSceneListening")
                            .transition(.opacity)
                    }
                    HStack(spacing: 20) {
                        if dictation.state == .listening || dictation.state == .finishing {
                            Button { dictation.cancel() } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .bold)).foregroundStyle(GuestBrand.blue)
                                    .frame(width: 44, height: 44)
                                    .background(.white, in: Circle())
                                    .overlay(Circle().stroke(GuestBrand.blue.opacity(0.3), lineWidth: 1))
                            }
                            .accessibilityLabel("Cancel dictation")
                            .accessibilityHint("Removes only the spoken words.")
                        }
                        micButton(size: 56)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, showsArt ? 0 : 20).padding(.bottom, 20)
            } else if showsArt {
                // The scene keeps its right side clear for the microphone.
                GuestScene(asset: "GuestSceneToday")
                    .overlay(alignment: .trailing) {
                        micButton(size: 84)
                            .padding(.trailing, 32).padding(.bottom, 12) // Room for the ring; above the plain bottom.
                    }
            } else {
                micButton(size: 92)
                    .padding(10) // Room for the ring.
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 20).padding(.vertical, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .background(GuestBrand.wash, in: RoundedRectangle(cornerRadius: 28))
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .overlay(alignment: .topLeading) { avatarBadge.padding(8) }
    }

    /// The person's Pingu as a small badge on the scene; tapping it opens the picker, which stops
    /// the microphone first.
    private var avatarBadge: some View {
        // 44 points: a full tap target that stays clear of the scene's Pingu.
        GuestAvatarButton(size: 34, onChoose: {
            dictation.interrupt()
            choosingPingu = true
        })
            .frame(width: 44, height: 44)
            .background(.white, in: Circle())
            .overlay(Circle().stroke(GuestBrand.blue.opacity(0.2), lineWidth: 1))
            .shadow(color: GuestBrand.ink.opacity(0.12), radius: 4, y: 1)
    }

    /// Tap to talk, tap again to stop. Its spoken name says which; any wait is its value.
    private func micButton(size: CGFloat) -> some View {
        Button {
            focused = false
            Task { await dictation.toggle() }
        } label: {
            Image(systemName: dictation.isActive ? "stop.fill" : "mic.fill")
                .font(.system(size: size * 0.36, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(GuestBrand.blue, in: Circle())
                .overlay(Circle().stroke(GuestBrand.blue.opacity(0.22), lineWidth: dictation.isActive || size < 60 ? 0 : 10)
                    .padding(-5))
        }
        .disabled(dictation.state == .finishing || journal.isSaving)
        .accessibilityLabel(dictation.isActive ? "Stop dictation" : "Start dictation")
        .accessibilityValue(statusText ?? "")
        .accessibilityHint(dictation.isActive ? "Keeps the words so far." : "Your words appear in the text, on this iPhone only.")
    }

    /// Question chips above the empty box; the "Need a nudge?" bubble from Pingu once there are words.
    /// Fixed guided prompts: only the starter is added, and only when tapped.
    @ViewBuilder private var prompts: some View {
        let empty = journal.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if empty, !dictation.isActive {
            GuestChipFlow {
                ForEach(GuestTodayPrompts.starters, id: \.self) { prompt in
                    Button { start(with: prompt.starter) } label: {
                        HStack(spacing: 8) {
                            if let icon = prompt.icon { GuestBrandIcon(asset: icon, size: 24) }
                            Text(prompt.question)
                        }
                    }
                    .buttonStyle(GuestChipButtonStyle())
                    .accessibilityLabel(prompt.question)
                    .accessibilityHint("Starts your words with “\(prompt.starter.trimmingCharacters(in: .whitespaces))”.")
                }
            }
        } else if nudge.isShown(for: journal.draft, isDictating: dictation.isActive) {
            HStack(alignment: .bottom, spacing: 8) {
                if !typeSize.isAccessibilitySize {
                    Image("GuestPinguThoughtful").resizable().scaledToFit().frame(width: 56, height: 56)
                        .accessibilityHidden(true)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(nudge.prompt.question)
                        .font(GuestBrand.font(.body)).foregroundStyle(.white)
                        .padding(.top, 8)
                    // Add, then two icon buttons; each is 44 points tall.
                    HStack(spacing: 4) {
                        Button { start(with: nil) } label: {
                            Label("Add", systemImage: "plus")
                                .font(GuestBrand.font(.footnote, .bold)).foregroundStyle(GuestBrand.blue)
                                .padding(.horizontal, 14).frame(minHeight: 36)
                                .background(.white, in: Capsule())
                                .frame(minHeight: 44).contentShape(Rectangle())
                        }
                        .accessibilityLabel("Add to my words")
                        Button { nudge.next() } label: { nudgeIcon("arrow.clockwise") }
                            .accessibilityLabel("Another question")
                        Spacer(minLength: 0)
                        Button { nudge.hide() } label: { nudgeIcon("xmark") }
                            .accessibilityLabel("Hide")
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.leading, 14).padding(.trailing, 4).padding(.bottom, 2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(GuestBrand.blue, in: UnevenRoundedRectangle(topLeadingRadius: 18, bottomLeadingRadius: 4,
                                                                       bottomTrailingRadius: 18, topTrailingRadius: 18))
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Need a nudge?")
        }
    }

    private func nudgeIcon(_ symbol: String) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
            .frame(width: 44, height: 44).contentShape(Rectangle())
    }

    /// Adds a chip's starter (or the nudge's) to the words and puts the cursor there to type.
    private func start(with starter: String?) {
        if let starter {
            journal.draft = GuestTodayPrompts.inserting(starter, into: journal.draft)
        } else {
            journal.draft = nudge.add(to: journal.draft)
        }
        focused = true
    }

    /// Spoken with the microphone while there's a wait; nothing is shown on screen.
    private var statusText: String? {
        switch dictation.state {
        case .requestingAccess: "Checking access…"
        case .finishing: "Finishing…"
        case .idle, .listening: nil
        }
    }
}

// MARK: - Journal

struct GuestJournalListView: View {
    @ObservedObject var journal: GuestJournalViewModel
    @ObservedObject var practice: GuestPracticeViewModel
    let suggester: any GuestSuggesting
    @State private var query = ""
    @State private var showsCalendar = false
    @State private var reflectingID: UUID?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedDay: Date?

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
                    GuestSceneMessage(asset: "GuestSceneJournalEmpty", text: "Nothing saved yet.")
                        .padding(24)
                case .loaded(let all):
                    let byDay = selectedDay.map { GuestCalendarModel.entries(on: $0, in: all) } ?? all
                    let entries = byDay.filter { GuestSearch.matches($0, query) }
                    List {
                        if showsCalendar {
                            GuestCalendarView(entries: all, selectedDay: $selectedDay)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        }
                        if let selectedDay {
                            // The chosen day as a chip; its × shows every entry again.
                            Button { self.selectedDay = nil } label: {
                                HStack(spacing: 6) {
                                    Text(selectedDay, format: .dateTime.day().month())
                                    Image(systemName: "xmark").font(.system(size: 12, weight: .bold))
                                }
                                .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.blue)
                                .padding(.leading, 14).padding(.trailing, 10).frame(minHeight: 36)
                                .background(GuestBrand.wash, in: Capsule())
                                .frame(minHeight: 44)
                            }
                            .buttonStyle(.borderless)
                            .accessibilityLabel("Show all")
                            .accessibilityValue(Text("Showing \(selectedDay.formatted(.dateTime.day().month(.wide)))"))
                            .listRowBackground(Color.clear)
                        }
                        if entries.isEmpty {
                            GuestPinguMessage(asset: query.isEmpty ? "GuestPinguSleeping" : "GuestPinguThoughtful",
                                              text: query.isEmpty ? "Nothing written that day." : "No entries match “\(query)”.",
                                              height: 110)
                                .listRowBackground(Color.clear)
                        }
                        ForEach(entries) { entry in
                            NavigationLink(value: entry.id) {
                                // The day is already the chip's when one is chosen.
                                GuestJournalRow(entry: entry, hasPractice: !practice.linkedMessages(to: entry.id).isEmpty,
                                                showsDate: selectedDay == nil)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .searchable(text: $query, prompt: "Search your journal")
                }
            }
            .background(GuestBrand.ice.ignoresSafeArea())
            .navigationTitle("Journal")
            // Pushes the list down rather than covering the entry that was just saved.
            .safeAreaInset(edge: .top) {
                if let entry = journal.reflectionOffer {
                    GuestReflectionOfferCard {
                        reflectingID = entry.id
                    } onNotNow: {
                        let motion: Animation? = reduceMotion ? nil : .default // No sliding with Reduce Motion.
                        withAnimation(motion) { journal.dismissReflectionOffer() }
                    }
                    .padding(.horizontal, 16).padding(.bottom, 4)
                    .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                }
            }
            .navigationDestination(item: $reflectingID) { id in
                if let entry = journal.entries.first(where: { $0.id == id }) {
                    GuestReflectionReviewView(entry: entry, journal: journal, suggester: suggester) { reflectingID = nil }
                }
            }
            .toolbar {
                Button { withAnimation { showsCalendar.toggle() } } label: {
                    Image(systemName: showsCalendar ? "list.bullet" : "calendar")
                }
                .accessibilityLabel(showsCalendar ? "Hide calendar" : "Show calendar")
            }
            .navigationDestination(for: UUID.self) { id in
                GuestEntryDetailView(entryID: id, journal: journal, practice: practice)
            }
        }
        .id(practice.dataGeneration) // Delete all closes anything open in Journal.
        // Outside the reset identity: the route lives in this view's state, so clear it here too.
        .onChange(of: practice.dataGeneration) { _, _ in reflectingID = nil }
    }
}

/// One entry in the list: a date tile, the person's words, then status icons and the time.
private struct GuestJournalRow: View {
    let entry: GuestJournalEntry
    let hasPractice: Bool
    let showsDate: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if showsDate {
                VStack(spacing: 0) {
                    // The day it was written, as the calendar files it; the year only if not this year.
                    Text(entry.createdAt, format: .dateTime.day())
                        .font(GuestBrand.font(.title3, .bold)).foregroundStyle(GuestBrand.blue)
                    Text(entry.createdAt, format: Calendar.current.isDate(entry.createdAt, equalTo: Date(), toGranularity: .year)
                         ? .dateTime.month(.abbreviated) : .dateTime.month(.abbreviated).year())
                        .font(GuestBrand.font(.caption, .semibold)).foregroundStyle(GuestBrand.muted)
                }
                .frame(minWidth: 48).padding(.vertical, 6)
                .background(GuestBrand.wash, in: RoundedRectangle(cornerRadius: 12))
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.originalWords).lineLimit(3).foregroundStyle(GuestBrand.ink)
                HStack(spacing: 10) {
                    HStack(spacing: 10) {
                        if entry.reflection != nil { GuestBrandIcon(asset: "GuestIconReflection", size: 18) }
                        if entry.nextStep != nil {
                            if entry.nextStepDone {
                                Image(systemName: "checkmark.circle").font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(GuestBrand.blue)
                            } else {
                                GuestBrandIcon(asset: "GuestIconNextStep", size: 18)
                            }
                        }
                        if hasPractice { GuestBrandIcon(asset: "GuestIconPractice", size: 18) }
                    }
                    // The icons, said in words.
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(statuses)
                    .accessibilityHidden(statuses.isEmpty)
                    Spacer(minLength: 0)
                    Text(entry.createdAt, format: .dateTime.hour().minute())
                        .font(GuestBrand.font(.caption)).foregroundStyle(GuestBrand.muted)
                }
            }
        }
    }

    /// The icons in words, for VoiceOver.
    private var statuses: String {
        var parts: [String] = []
        if entry.reflection != nil { parts.append("Has a reflection") }
        if entry.nextStep != nil { parts.append(entry.nextStepDone ? "Next step done" : "Next step not done") }
        if hasPractice { parts.append("Has a practice message") }
        return parts.joined(separator: ", ")
    }
}

/// After saving: a short "Saved" card with an optional reflection. Saving never needs one.
private struct GuestReflectionOfferCard: View {
    let onReflect: () -> Void
    let onNotNow: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        // One row; at the largest text sizes the buttons go under the heading.
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) { heading; Spacer(minLength: 0); actions }
            VStack(alignment: .leading, spacing: 10) { heading; HStack { actions } }
        }
        .padding(.vertical, 10).padding(.leading, 12).padding(.trailing, 6)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: GuestBrand.ink.opacity(0.08), radius: 10, y: 2)
    }

    private var heading: some View {
        HStack(spacing: 12) {
            if !typeSize.isAccessibilitySize {
                Image("GuestPinguJournal").resizable().scaledToFit().frame(width: 40, height: 40)
                    .accessibilityHidden(true)
            }
            Text("Saved").font(GuestBrand.font(.headline, .semibold)).foregroundStyle(GuestBrand.ink)
                .accessibilityAddTraits(.isHeader)
        }
    }

    @ViewBuilder private var actions: some View {
        Button(action: onReflect) {
            Label {
                Text("Reflect")
            } icon: {
                Image("GuestIconReflection").renderingMode(.template).resizable().scaledToFit()
                    .frame(width: 18, height: 18)
            }
            .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(.white)
            .padding(.horizontal, 16).frame(minHeight: 44)
            .background(GuestBrand.blue, in: Capsule())
        }
        .accessibilityLabel("Reflect on it")
        Button(action: onNotNow) {
            Image(systemName: "xmark").font(.system(size: 15, weight: .bold)).foregroundStyle(GuestBrand.muted)
                .frame(width: 44, height: 44).contentShape(Rectangle())
        }
        .accessibilityLabel("Not now")
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
            .navigationTitle(title)
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

    /// The date is the title.
    private var title: String {
        guard let entry = journal.entries.first(where: { $0.id == entryID }) else { return "Entry" }
        let format = Date.FormatStyle.dateTime.weekday(.abbreviated).day().month().hour().minute()
        return entry.createdAt.formatted(Calendar.current.isDate(entry.createdAt, equalTo: Date(), toGranularity: .year)
                                         ? format : format.year())
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
                Text(entry.originalWords).font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 18))
                    .accessibilityLabel(Text("My words: \(entry.originalWords)"))
                GuestEntryReflectionSection(entry: entry, journal: journal)
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
            }
            .padding(24)
        }
        .toolbar {
            Button { editor = GuestEntryEditorViewModel(entry: entry, store: journal.store) } label: {
                Image(systemName: "pencil")
            }
            .accessibilityLabel("Edit")
            // Rarely used, so it waits in the ••• menu. Delete stays a word.
            Menu {
                Button("Delete entry", systemImage: "trash", role: .destructive) { Task { await askToDelete() } }
            } label: {
                Image(systemName: "ellipsis")
            }
            .accessibilityLabel("More")
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

/// A kept reflection and next step, apart from the person's own words. Both can be removed, and
/// the next step can be marked done or not done at any time.
struct GuestEntryReflectionSection: View {
    let entry: GuestJournalEntry
    @ObservedObject var journal: GuestJournalViewModel
    @State private var error: String?
    @State private var isUpdating = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let reflection = entry.reflection {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image("GuestIconReflection").renderingMode(.original).resizable().scaledToFit()
                            .frame(width: 24, height: 24)
                            .accessibilityLabel("Reflection").accessibilityAddTraits(.isHeader)
                        // Where it came from stays in words: an icon alone could mislead.
                        Text(reflection.source.label).font(GuestBrand.font(.caption)).foregroundStyle(GuestBrand.muted)
                        Spacer(minLength: 0)
                        iconAction("xmark", "Remove reflection") {
                            await update(reflection: nil, nextStep: entry.nextStep, done: entry.nextStepDone)
                        }
                    }
                    if !reflection.summary.isEmpty { Text(reflection.summary) }
                    if !reflection.feeling.isEmpty {
                        Label { Text(reflection.feeling) } icon: { GuestBrandIcon(asset: "GuestIconFeelings", size: 18) }
                            .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.blue)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(GuestBrand.wash, in: Capsule())
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(Text("Feeling: \(reflection.feeling)"))
                    }
                    if !reflection.insight.isEmpty { Text(reflection.insight) }
                    if entry.isReflectionStale {
                        Label("Based on an earlier version of your words.", systemImage: "clock.arrow.circlepath")
                            .font(GuestBrand.font(.footnote, .semibold)).foregroundStyle(GuestBrand.ink)
                    }
                }
                .font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16).padding(.trailing, 4).padding(.vertical, 8)
                .background(.white, in: RoundedRectangle(cornerRadius: 18))
            }
            if let step = entry.nextStep {
                HStack(spacing: 4) {
                    iconAction(entry.nextStepDone ? "checkmark.circle.fill" : "circle",
                               entry.nextStepDone ? "Mark not done" : "Mark done", size: 22) {
                        await update(reflection: entry.reflection, nextStep: step, done: !entry.nextStepDone)
                    }
                    Text(step).font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink)
                        .strikethrough(entry.nextStepDone)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityLabel(Text("Next step: \(step)"))
                        .accessibilityValue(entry.nextStepDone ? "Done" : "Not done")
                    GuestBrandIcon(asset: "GuestIconNextStep", size: 22)
                    iconAction("xmark", "Remove step") {
                        await update(reflection: entry.reflection, nextStep: nil, done: false)
                    }
                }
                .padding(.vertical, 4).padding(.leading, 4).padding(.trailing, 4)
                .background(.white, in: RoundedRectangle(cornerRadius: 18))
            }
            if let error {
                Label(error, systemImage: "exclamationmark.circle")
                    .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
            }
        }
    }

    /// An icon-only action that keeps its words for VoiceOver, with a 44-point target.
    private func iconAction(_ symbol: String, _ title: String, size: CGFloat = 14,
                            _ perform: @escaping () async -> Void) -> some View {
        Button { Task { await perform() } } label: {
            Image(systemName: symbol)
                .font(.system(size: size, weight: size > 16 ? .regular : .bold))
                .foregroundStyle(size > 16 ? GuestBrand.blue : GuestBrand.muted)
                .frame(width: 44, height: 44).contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(title)
        .disabled(isUpdating)
    }

    private func update(reflection: GuestReflection?, nextStep: String?, done: Bool) async {
        isUpdating = true
        defer { isUpdating = false }
        error = await journal.updateReflection(of: entry, reflection: reflection, nextStep: nextStep, nextStepDone: done)
    }
}
