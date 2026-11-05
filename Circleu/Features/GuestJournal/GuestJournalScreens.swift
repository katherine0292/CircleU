import SwiftUI
import UIKit

/// Guest experience shell: Today, Journal and Practice.
struct GuestHomeView: View {
    @ObservedObject var journal: GuestJournalViewModel
    @ObservedObject var practice: GuestPracticeViewModel
    let makeDictationEngine: () -> any GuestDictationEngine
    let suggester: any GuestSuggesting
    @State private var tab: Tab = .today
    @StateObject private var tour = GuestTour()

    enum Tab: Hashable { case today, journal, practice }

    var body: some View {
        TabView(selection: $tab) {
            GuestTodayView(journal: journal, practice: practice, makeDictationEngine: makeDictationEngine,
                           onSaved: { tab = .journal })
                .tabItem { GuestTabLabel(title: "Write", icon: "GuestIconToday") }
                .tag(Tab.today)
            GuestJournalListView(journal: journal, practice: practice, suggester: suggester)
                .tabItem { GuestTabLabel(title: "Journal", icon: "GuestIconJournal") }
                .tag(Tab.journal)
            GuestPracticeHomeView(practice: practice, journal: journal)
                .tabItem { GuestTabLabel(title: "Talk", icon: "GuestIconPractice") }
                .tag(Tab.practice)
        }
        .tint(GuestWarm.cocoa)
        .environment(\.guestTour, tour)
        // The guide moves to each step's tab, then lights up its target.
        .onChange(of: tour.index) { _, _ in
            guard let step = tour.step else { return }
            let target: Tab = [.today, .journal, .practice][step.tab]
            if tab != target { withAnimation(.easeInOut(duration: 0.25)) { tab = target } }
        }
        .overlay { if tour.isActive { GuestTourOverlay(tour: tour).transition(.opacity) } }
        .animation(.easeInOut(duration: 0.3), value: tour.isActive)
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
                .guestCard(in: RoundedRectangle(cornerRadius: 14))
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
            // Writing and voice share the same composer; neither requires an extra route.
            GuestWriteView(journal: journal, dictationEngine: makeDictationEngine(),
                           heading: "What’s on your mind?", showsLogo: true, onSaved: onSaved)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            GuestSettingsView(journal: journal, practice: practice)
                        } label: {
                            Image(systemName: "gearshape").guestTourTarget(.settings)
                        }
                        .accessibilityLabel("Settings")
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        GuestTourButton()
                    }
                }
        }
        .tint(GuestWarm.cocoa)
    }
}

// MARK: - Write

struct GuestWriteView: View {
    @ObservedObject var journal: GuestJournalViewModel
    @StateObject private var dictation: GuestDictationViewModel
    let heading: String
    let showsLogo: Bool
    let onSaved: () -> Void
    @FocusState private var focused: Bool
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @Environment(\.dynamicTypeSize) private var typeSize
    @AppStorage(GuestAvatars.storageKey) private var avatarID = GuestAvatars.defaultID
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var choosingPingu = false
    @State private var choosingQuestion = false

    /// How tall the scene behind the top of Today is, from the top of the screen.
    private static let sceneHeight: CGFloat = 310
    /// The space above the heading that lets the scene show between the top bar and the words.
    private static let sceneGap: CGFloat = 118
    /// The scene is decorative: it gives way to the keyboard and to accessibility text sizes.
    private var showsScene: Bool { !typeSize.isAccessibilitySize && !focused }

    init(journal: GuestJournalViewModel, dictationEngine: @autoclosure @escaping () -> any GuestDictationEngine,
         heading: String = "Start with your words", showsLogo: Bool = false, onSaved: @escaping () -> Void) {
        self.journal = journal
        self.heading = heading
        self.showsLogo = showsLogo
        self.onSaved = onSaved
        _dictation = StateObject(wrappedValue: GuestDictationViewModel(journal: journal, engine: dictationEngine()))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                // Room for the scene behind the top of the page (`backdrop`).
                if showsScene { Color.clear.frame(height: Self.sceneGap) }
                Text(heading)
                    .font(GuestWarm.heading(.title2))
                    .shadow(color: GuestWarm.cream.opacity(showsScene ? 0.9 : 0), radius: 10)
                    .accessibilityAddTraits(.isHeader)
                VStack(alignment: .leading, spacing: 0) {
                    if let question = journal.selectedQuestion {
                        HStack(alignment: .top, spacing: 8) {
                            Text(question.rawValue).font(GuestBrand.font(.subheadline, .semibold))
                                .foregroundStyle(GuestWarm.sage).fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                            Button { journal.selectedQuestion = nil } label: {
                                Image(systemName: "xmark").frame(width: 44, height: 44)
                            }
                            .accessibilityLabel("Remove question").disabled(journal.isSaving)
                        }
                        .padding(.leading, 16).padding(.trailing, 4).padding(.top, 8)
                    }
                    TextEditor(text: $journal.draft)
                        .focused($focused).disabled(dictation.isActive)
                        .scrollContentBackground(.hidden).padding(12)
                        .frame(minHeight: typeSize.isAccessibilitySize ? 160 : 190)
                        .overlay(alignment: .topLeading) {
                            if journal.draft.isEmpty {
                                Text("Write your words…").foregroundStyle(GuestWarm.muted)
                                    .padding(.leading, 17).padding(.top, 20)
                                    .allowsHitTesting(false).accessibilityHidden(true)
                            }
                        }
                        .accessibilityLabel("Your words")
                    HStack(spacing: 8) {
                        if dictation.isActive {
                            Text(statusText ?? "Listening…")
                                .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestWarm.muted)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 0)
                            Button { dictation.cancel() } label: {
                                Image(systemName: "xmark").frame(width: 44, height: 44)
                            }.accessibilityLabel("Cancel dictation")
                        } else {
                            Button {
                                focused = false
                                choosingQuestion = true
                            } label: {
                                HStack(spacing: 6) {
                                    Text(journal.selectedQuestion == nil ? "What stayed with you?" : "Change question")
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Image(systemName: "chevron.down").font(.caption)
                                }
                                .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestWarm.muted)
                                .frame(minHeight: 44)
                            }
                            .accessibilityLabel(journal.selectedQuestion == nil ? "Suggest a question" : "Change question")
                            .guestTourTarget(.writePrompt)
                            .disabled(journal.isSaving)
                            Spacer(minLength: 0)
                        }
                        micButton.guestTourTarget(.writeMic)
                    }
                    .padding(.horizontal, 16).padding(.bottom, 12)
                }
                .guestCard(in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                .guestTourTarget(.writeCard)
                if let message = dictation.message {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(message, systemImage: "info.circle")
                            .font(GuestBrand.font(.footnote)).foregroundStyle(GuestWarm.muted)
                        if dictation.needsSettings, let url = URL(string: UIApplication.openSettingsURLString) {
                            Button("Open Settings") { openURL(url) }.frame(minHeight: 44)
                        }
                    }
                }
                if let error = journal.saveError {
                    Label(error, systemImage: "exclamationmark.circle").font(GuestBrand.font(.subheadline))
                }
                if let warning = journal.draftWarning {
                    Label(warning, systemImage: "info.circle")
                        .font(GuestBrand.font(.footnote)).foregroundStyle(GuestWarm.muted)
                }
            }
            .padding(.horizontal, 24).padding(.vertical, 14)
        }
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            Button(journal.isSaving ? "Saving…" : "Save") {
                dictation.stopForSave()
                Task {
                    if await journal.saveDraft() {
                        focused = false
                        onSaved()
                    }
                }
            }
            .buttonStyle(GuestCocoaButtonStyle())
            .guestTourTarget(.writeSave)
            .disabled(journal.draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || journal.isSaving)
            .padding(.horizontal, 24).padding(.vertical, 12)
        }
        .foregroundStyle(GuestWarm.ink)
        .background { backdrop }
        .animation(reduceMotion ? nil : .spring(response: 0.55, dampingFraction: 0.82), value: showsScene)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if showsLogo {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 8) {
                        GuestBrandIcon(asset: "GuestIconLogo", size: 32)
                        if !typeSize.isAccessibilitySize {
                            Text("CircleU").font(GuestBrand.font(.callout, .semibold))
                        }
                    }
                    .fixedSize(horizontal: true, vertical: false)
                    .accessibilityElement(children: .ignore).accessibilityLabel("CircleU")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                GuestAvatarButton(size: 30, onChoose: {
                    dictation.interrupt(); focused = false; choosingPingu = true
                })
                .frame(width: 44, height: 44)
                .guestTourTarget(.avatar)
                .guestHop(on: showsScene) // Catches the scene as it shrinks away, and lets it go again.
            }
        }
        .sheet(isPresented: $choosingPingu) { GuestAvatarPicker(selection: $avatarID) }
        .sheet(isPresented: $choosingQuestion) {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(GuestWritingQuestion.allCases) { question in
                            Button {
                                journal.selectedQuestion = question
                                choosingQuestion = false
                            } label: {
                                HStack {
                                    Text(question.rawValue).fixedSize(horizontal: false, vertical: true)
                                    Spacer(minLength: 8)
                                    Image(systemName: "chevron.right").font(.caption)
                                }
                                .padding(16).frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                                .guestCard(in: RoundedRectangle(cornerRadius: 16))
                            }
                            .buttonStyle(.plain).accessibilityLabel(question.rawValue)
                        }
                    }.padding(24)
                }
                .background { GuestFlowingBackground() }.font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink)
                .navigationTitle("Choose a question").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button { choosingQuestion = false } label: {
                            Image(systemName: "xmark").frame(width: 44, height: 44)
                        }.accessibilityLabel("Close questions")
                    }
                }
            }
            .presentationDetents(typeSize.isAccessibilitySize ? [.large] : [.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onChange(of: scenePhase) { _, phase in if phase == .background { dictation.interrupt() } }
        .onDisappear { dictation.interrupt() }
    }

    /// The flowing warm background with the Today scene across the top, fading into it.
    private var backdrop: some View {
        ZStack(alignment: .top) {
            GuestFlowingBackground()
            if showsScene {
                // The room drifts very slowly, so Write feels lived in.
                GuestLivingImage(asset: GuestSceneArt.today(listening: dictation.isActive).asset, drifts: true)
                    .aspectRatio(2, contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: Self.sceneHeight)
                    .clipped()
                    .mask(LinearGradient(stops: [.init(color: .black, location: 0.55),
                                                 .init(color: .clear, location: 1)],
                                         startPoint: .top, endPoint: .bottom))
                    // While writing, the scene shrinks up into the avatar at the top right.
                    .transition(reduceMotion ? .opacity
                                : .scale(scale: 0.06, anchor: UnitPoint(x: 0.9, y: 0.1)).combined(with: .opacity))
                    .accessibilityHidden(true)
            }
        }
        .ignoresSafeArea()
    }

    private var micButton: some View {
        Button {
            focused = false
            Task { await dictation.toggle() }
        } label: {
            Image(systemName: dictation.isActive ? "stop.fill" : "mic")
                .font(.system(size: 20, weight: .semibold)).foregroundStyle(GuestWarm.sage)
                .frame(width: 44, height: 44)
                .guestGlass(in: Circle(), interactive: true)
                .background { GuestBreathingRing(active: dictation.isActive).padding(-6) }
        }
        .disabled(dictation.state == .finishing || journal.isSaving)
        .accessibilityLabel(dictation.isActive ? "Stop dictation" : "Start dictation")
        .accessibilityValue(statusText ?? "")
        .accessibilityHint(dictation.isActive ? "Keeps the words so far." : "Your words appear in the text, on this iPhone only.")
    }

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
    /// "Save and prepare what to say" from a reflection opens Talk for that entry, filled in.
    @State private var talkingEntryID: UUID?
    @State private var taggingEntry: GuestJournalEntry?
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
                    GuestSceneMessage(scene: .journalDesk, text: "Nothing saved yet.")
                        .guestTourTarget(.journalList)
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
                        ForEach(GuestJournalDayGroup.make(entries)) { group in
                            Section {
                                ForEach(group.entries) { entry in
                                    GuestJournalRow(entry: entry,
                                        hasPractice: !practice.linkedMessages(to: entry.id).isEmpty,
                                        asksOutcome: practice.linkedMessages(to: entry.id).contains { m in
                                            let turns = m.conversation?.turns ?? []
                                            return turns.contains { $0.kind == .wording } && !turns.contains { $0.kind == .outcome }
                                        },
                                        onTags: { taggingEntry = entry })
                                        .modifier(GuestFirstRowTarget(isFirst: entry.id == entries.first?.id))
                                        .guestRiseIn()
                                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                                        .listRowSeparator(.hidden).listRowBackground(Color.clear)
                                }
                            } header: {
                                Text(group.id, format: Calendar.current.isDate(group.id, equalTo: Date(), toGranularity: .year)
                                     ? .dateTime.day().month(.abbreviated) : .dateTime.day().month(.abbreviated).year())
                                    .font(GuestBrand.font(.footnote, .semibold)).foregroundStyle(GuestBrand.muted)
                                    .textCase(nil).accessibilityAddTraits(.isHeader)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search your journal")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { GuestFlowingBackground() }
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $taggingEntry) { entry in GuestEntryTagPicker(entry: entry, journal: journal) }
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
                    GuestReflectionReviewView(entry: entry, journal: journal, suggester: suggester,
                                              onDone: { reflectingID = nil },
                                              onPrepare: {
                                                  reflectingID = nil
                                                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { talkingEntryID = id }
                                              })
                }
            }
            .navigationDestination(item: $talkingEntryID) { id in
                // The moment first, then Talk on top of it: Back lands on the moment's timeline.
                GuestEntryDetailView(entryID: id, journal: journal, practice: practice, suggester: suggester, startsTalk: true)
            }
            .toolbar {
                Button { withAnimation { showsCalendar.toggle() } } label: {
                    Image(systemName: showsCalendar ? "list.bullet" : "calendar").guestTourTarget(.journalCalendar)
                }
                .accessibilityLabel(showsCalendar ? "Hide calendar" : "Show calendar")
            }
            .navigationDestination(for: UUID.self) { id in
                GuestEntryDetailView(entryID: id, journal: journal, practice: practice, suggester: suggester)
            }
        }
        .id(practice.dataGeneration) // Delete all closes anything open in Journal.
        // Outside the reset identity: the route lives in this view's state, so clear it here too.
        .onChange(of: practice.dataGeneration) { _, _ in reflectingID = nil; taggingEntry = nil }
    }
}

/// The read action and the two tag actions are siblings, so tags never open the entry by accident.
private struct GuestJournalRow: View {
    let entry: GuestJournalEntry
    let hasPractice: Bool
    /// Something was said in a linked conversation, and how it went isn't written yet.
    var asksOutcome = false
    let onTags: () -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            NavigationLink(value: entry.id) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.createdAt, format: .dateTime.hour().minute())
                        .font(GuestBrand.font(.caption)).foregroundStyle(GuestBrand.muted)
                    Text(entry.originalWords).font(GuestBrand.font(.callout))
                        .lineLimit(typeSize.isAccessibilitySize ? 6 : 4)
                        .foregroundStyle(GuestBrand.ink).frame(maxWidth: .infinity, alignment: .leading)
                    if !statuses.isEmpty {
                        HStack(spacing: 10) {
                            if entry.reflection != nil { GuestBrandIcon(asset: "GuestIconReflection", size: 18) }
                            if entry.nextStep != nil {
                                Image(systemName: entry.nextStepDone ? "checkmark.circle" : "circle")
                                    .font(.system(size: 16)).foregroundStyle(GuestBrand.blue)
                            }
                            if hasPractice { GuestBrandIcon(asset: "GuestIconPractice", size: 18) }
                            if asksOutcome {
                                Text("How did it go?").font(GuestBrand.font(.caption2, .bold)).foregroundStyle(GuestBrand.blue)
                                    .padding(.horizontal, 8).padding(.vertical, 2).background(GuestBrand.wash, in: Capsule())
                            }
                        }
                        .accessibilityElement(children: .ignore).accessibilityLabel(statuses)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading).contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            if typeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 4) { contextButton; feelingButton }
            } else {
                HStack(spacing: 8) { contextButton; Spacer(minLength: 0); feelingButton }
            }
        }
        .padding(16)
        .guestCard(in: RoundedRectangle(cornerRadius: 20))
    }

    private var contextButton: some View {
        Button(action: onTags) {
            HStack(spacing: 5) {
                if let context = entry.context {
                    Image(context.asset).resizable().scaledToFit().frame(width: 26, height: 26).accessibilityHidden(true)
                    Text(context.title)
                } else { Text("+ Context") }
            }
            .font(GuestBrand.font(.caption, .semibold)).foregroundStyle(GuestBrand.blue)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(GuestBrand.wash, in: Capsule())
            .guestSquish(on: entry.context)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(entry.context.map { "Context: \($0.title)" } ?? "Add context")
    }

    private var feelingButton: some View {
        Button(action: onTags) {
            HStack(spacing: 5) {
                if let feeling = entry.feeling {
                    Image(feeling.asset).resizable().scaledToFit().frame(width: 36, height: 32).accessibilityHidden(true)
                    Text(feeling.title)
                } else { Text("+ Feeling") }
            }
            .font(GuestBrand.font(.caption)).foregroundStyle(GuestBrand.muted)
            .guestSquish(on: entry.feeling)
            .frame(minHeight: 44).contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(entry.feeling.map { "Feeling: \($0.title)" } ?? "Add feeling")
    }

    private var statuses: String {
        var parts: [String] = []
        if entry.reflection != nil { parts.append("Has a reflection") }
        if entry.nextStep != nil { parts.append(entry.nextStepDone ? "Next step done" : "Next step not done") }
        if hasPractice { parts.append("Has a conversation") }
        if asksOutcome { parts.append("How did it go? Not written yet") }
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
        .guestCard(in: RoundedRectangle(cornerRadius: 18))
        .guestRiseIn()
    }

    private var heading: some View {
        HStack(spacing: 12) {
            if !typeSize.isAccessibilitySize {
                GuestLivingImage(asset: "GuestPinguJournal", breathes: true).frame(width: 40, height: 40)
                    .guestHop().accessibilityHidden(true)
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
    /// Reflect from this page; nil hides it.
    var suggester: (any GuestSuggesting)? = nil
    /// Opens Talk for this moment right away (after "Save and prepare what to say").
    var startsTalk = false
    @State private var startedTalk = false
    /// Owned here, outside the content that refreshes, so an open editor survives list reloads.
    @State private var editor: GuestEntryEditorViewModel?
    @State private var practiceRoute: GuestPracticeRoute?
    @State private var reflecting = false
    @State private var tagging: GuestJournalEntry?
    @State private var keyboardShown = false
    @State private var confirmDelete = false
    @State private var deleteError: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        content
            .background { GuestFlowingBackground(mood: journal.entries.first { $0.id == entryID }?.feeling) }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $practiceRoute) { route in
                GuestPracticeRouteView(route: route, practice: practice, journal: journal)
            }
            .navigationDestination(isPresented: $reflecting) {
                if let suggester, let entry = journal.entries.first(where: { $0.id == entryID }) {
                    GuestReflectionReviewView(entry: entry, journal: journal, suggester: suggester,
                                              onDone: { reflecting = false },
                                              onPrepare: {
                                                  reflecting = false
                                                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                                                      practiceRoute = .new(sourceEntryID: entryID)
                                                  }
                                              })
                }
            }
            .sheet(item: $tagging) { entry in GuestEntryTagPicker(entry: entry, journal: journal) }
            .onAppear {
                guard startsTalk, !startedTalk else { return }
                startedTalk = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { practiceRoute = .new(sourceEntryID: entryID) }
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
        let format = Date.FormatStyle.dateTime.day().month(.abbreviated)
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

    /// One moment and everything that grew from it, as a timeline: what happened, the reflection,
    /// the conversation, how it went. The next step on the line waits at the bottom.
    private func detail(for entry: GuestJournalEntry) -> some View {
        let linked = practice.linkedMessages(to: entry.id)
        let hasReflection = entry.reflection != nil || entry.nextStep != nil
        let said = linked.contains { $0.conversation?.turns.contains { $0.kind == .wording } ?? !$0.wording.isEmpty }
        return ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                GuestTimelineStep(title: "What happened · your words", done: true, isLast: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(entry.createdAt, format: .dateTime.hour().minute())
                            .font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                            .accessibilityLabel(Text("Created \(entry.createdAt.formatted(date: .complete, time: .shortened))"))
                        Text(entry.originalWords).font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityLabel(Text("My words: \(entry.originalWords)"))
                        HStack(spacing: 8) {
                            tagButton(entry.context.map { ($0.title, $0.asset) }, empty: "+ Context", entry: entry)
                            tagButton(entry.feeling.map { ($0.title, $0.asset) }, empty: "+ Feeling", entry: entry)
                        }
                    }
                    .padding(16).guestCard(in: RoundedRectangle(cornerRadius: 18))
                }
                GuestTimelineStep(title: "Reflection", done: hasReflection, isLast: false) {
                    if hasReflection {
                        GuestEntryReflectionSection(entry: entry, journal: journal)
                    } else {
                        GuestTimelinePlaceholder(text: "Not yet. It can help to see what’s underneath.")
                    }
                }
                GuestTimelineStep(title: "Conversation", done: !linked.isEmpty, isLast: !said) {
                    if case .failed(let message) = practice.loadState {
                        // Unknown is not "none": say so rather than hiding linked messages.
                        HStack {
                            Text(message).font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                            Button("Try again") { Task { await practice.load() } }
                                .font(GuestBrand.font(.footnote, .semibold))
                        }
                    } else if linked.isEmpty {
                        GuestTimelinePlaceholder(text: "Need to talk to someone about this? Prepare what to say.")
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(linked) { message in
                                Button { practiceRoute = .message(message.id) } label: {
                                    GuestPracticeRow(message: message, entries: journal.entries)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                if said {
                    // Once something was said, this moment asks how it went.
                    GuestTimelineStep(title: "How did it go?", done: linked.contains { $0.conversation?.turns.contains { $0.kind == .outcome } ?? false }, isLast: true) {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(linked) { message in GuestOutcomeCard(message: message, practice: practice) }
                        }
                    }
                }
                if let deleteError {
                    Label(deleteError, systemImage: "exclamationmark.circle")
                        .font(GuestBrand.font(.subheadline)).foregroundStyle(GuestBrand.ink)
                        .padding(.top, 12)
                }
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in keyboardShown = true }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in keyboardShown = false }
        .safeAreaInset(edge: .bottom) {
            // One main action: the next step on the line. Hidden while typing.
            if !keyboardShown {
            VStack(spacing: 6) {
                if linked.isEmpty && !hasReflection && suggester != nil {
                    Button("Reflect") { reflecting = true }.buttonStyle(GuestBrandButtonStyle())
                    Button("Talk it through instead") { practiceRoute = .new(sourceEntryID: entry.id) }
                        .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestBrand.blue).frame(minHeight: 44)
                } else if linked.isEmpty {
                    Button { practiceRoute = .new(sourceEntryID: entry.id) } label: {
                        Label { Text("Talk it through") } icon: {
                            Image("GuestIconPractice").renderingMode(.original).accessibilityHidden(true)
                        }
                    }
                    .buttonStyle(GuestBrandButtonStyle())
                } else if let latest = linked.first {
                    Button("Continue the conversation") { practiceRoute = .message(latest.id) }
                        .buttonStyle(GuestBrandButtonStyle(filled: false))
                }
            }
            .padding(.horizontal, 24).padding(.vertical, 12)
            .background { GuestBottomFade() }
            }
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

extension GuestEntryDetailView {
    /// A context or feeling chip; tapping opens the tag picker.
    fileprivate func tagButton(_ value: (title: String, asset: String)?, empty: String, entry: GuestJournalEntry) -> some View {
        Button { tagging = entry } label: {
            HStack(spacing: 5) {
                if let value {
                    Image(value.asset).resizable().scaledToFit().frame(width: 24, height: 24).accessibilityHidden(true)
                    Text(value.title)
                } else { Text(empty) }
            }
            .font(GuestBrand.font(.caption, .semibold)).foregroundStyle(GuestBrand.blue)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(GuestBrand.wash, in: Capsule())
            .guestSquish(on: value?.title)
            .frame(minHeight: 44)
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(value.map { "\(empty.contains("Context") ? "Context" : "Feeling"): \($0.title)" } ?? empty.replacingOccurrences(of: "+ ", with: "Add "))
    }
}

/// One stop on a moment's timeline: a dot (filled once it's done), a rail to the next stop, and its content.
struct GuestTimelineStep<Content: View>: View {
    let title: String
    let done: Bool
    let isLast: Bool
    @ViewBuilder let content: Content
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// The rail to the next stop grows down once the stop is shown.
    @State private var grown = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Circle().fill(done ? GuestWarm.sage : GuestWarm.muted.opacity(0.3))
                    .frame(width: 12, height: 12)
                    .overlay(Circle().stroke(GuestWarm.oat, lineWidth: 2))
                    .padding(.top, 3)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: done)
                if !isLast {
                    Rectangle().fill(done ? GuestWarm.sage.opacity(0.55) : GuestWarm.muted.opacity(0.22))
                        .frame(width: 2).frame(maxHeight: .infinity)
                        .scaleEffect(x: 1, y: grown || reduceMotion ? 1 : 0, anchor: .top)
                        .onAppear { withAnimation(.easeOut(duration: 0.7).delay(0.25)) { grown = true } }
                        .animation(.easeInOut(duration: 0.4), value: done)
                }
            }
            .frame(width: 12)
            .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 8) {
                Text(title.uppercased()).font(GuestBrand.font(.caption2, .bold)).foregroundStyle(GuestBrand.muted)
                    .accessibilityAddTraits(.isHeader)
                content
            }
            .padding(.bottom, isLast ? 0 : 18)
        }
        .fixedSize(horizontal: false, vertical: true)
        .guestRiseIn()
    }
}

/// A stop that hasn't happened yet: a quiet dashed card.
struct GuestTimelinePlaceholder: View {
    let text: String
    var body: some View {
        Text(text).font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
            .frame(maxWidth: .infinity, alignment: .leading).padding(14)
            .background(GuestWarm.cream.opacity(0.55), in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(GuestWarm.muted.opacity(0.35), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4])))
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
                .guestCard(in: RoundedRectangle(cornerRadius: 18))
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
        .background { GuestFlowingBackground() }
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
                .guestCard(in: RoundedRectangle(cornerRadius: 18))
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
                .guestCard(in: RoundedRectangle(cornerRadius: 18))
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

/// The guide lights up the newest moment rather than the whole list.
private struct GuestFirstRowTarget: ViewModifier {
    let isFirst: Bool
    func body(content: Content) -> some View {
        if isFirst { content.guestTourTarget(.journalList) } else { content }
    }
}
