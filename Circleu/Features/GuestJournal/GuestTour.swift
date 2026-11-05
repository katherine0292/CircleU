import Combine
import SwiftUI
import UIKit

// A step-by-step guide through the whole app (owner request, 6 November 2026): opened from the "?"
// on Write, it moves across Write, Journal and Talk. Each step lights up one control or area and dims
// the rest, with a short card beside it. Nothing is changed by the guide; it only shows.

enum GuestTourTarget: Hashable {
    case writeCard, writePrompt, writeMic, writeSave, avatar, settings
    case journalList, journalCalendar
    case talkStart, talkHistory
    case tabBar
}

struct GuestTourStep {
    /// 0 Write, 1 Journal, 2 Talk.
    let tab: Int
    let target: GuestTourTarget?
    let title: String
    let body: String
    /// The otter's pose for this step.
    var pose = "GuestPinguWelcome"
}

@MainActor
final class GuestTour: ObservableObject {
    @Published private(set) var index: Int?
    @Published private(set) var frames: [GuestTourTarget: CGRect] = [:]
    /// Asks targets to say where they are again once a tab switch has settled.
    @Published private(set) var pulse = 0

    static let steps: [GuestTourStep] = [
        .init(tab: 0, target: .tabBar, title: "A quick tour",
              body: "CircleU has three parts: Write, Journal and Talk. Here’s how they work together.", pose: "GuestPinguWelcome"),
        .init(tab: 0, target: .writeCard, title: "Write what happened",
              body: "Type what happened and how it felt. It stays on this iPhone.", pose: "GuestPinguWriting"),
        .init(tab: 0, target: .writePrompt, title: "Need a start?",
              body: "Pick a question to guide you. It never changes your words.", pose: "GuestPinguThoughtful"),
        .init(tab: 0, target: .writeMic, title: "Rather say it?",
              body: "Speak, and your words appear here to edit.", pose: "GuestPinguListening"),
        .init(tab: 0, target: .writeSave, title: "Save",
              body: "Your words become a moment in Journal.", pose: "GuestPinguJournal"),
        .init(tab: 0, target: .avatar, title: "Your otter",
              body: "Tap to choose the otter that stands for you.", pose: "GuestPinguHeart"),
        .init(tab: 0, target: .settings, title: "Settings",
              body: "Export or delete your data, and see how privacy works.", pose: "GuestPinguLaptop"),
        .init(tab: 1, target: .journalList, title: "Every moment",
              body: "Open one to see its timeline: what happened, reflection, conversation, how it went.", pose: "GuestPinguReading"),
        .init(tab: 1, target: .journalCalendar, title: "By day",
              body: "See the days you wrote. Search finds words and tags.", pose: "GuestPinguExplorer"),
        .init(tab: 1, target: .journalList, title: "Reflect, then talk",
              body: "On a moment, Reflect finds what’s underneath. Then Talk it through to prepare what to say.", pose: "GuestPinguPractising"),
        .init(tab: 2, target: .talkStart, title: "Talk it through",
              body: "Write what you mean and get it back in your tone. Copy it, then say it.", pose: "GuestPinguPractising"),
        .init(tab: 2, target: .talkHistory, title: "When they reply",
              body: "Add their reply, pick how you read it, and get ideas for what to say back.", pose: "GuestPinguListening"),
        .init(tab: 2, target: nil, title: "Close the loop",
              body: "Back on the moment, note how it went. Next time starts from there.", pose: "GuestPinguHeart"),
    ]

    var step: GuestTourStep? { index.map { Self.steps[$0] } }
    var isActive: Bool { index != nil }

    func start() { frames = [:]; index = 0; settle() }
    func next() { guard let i = index else { return }; index = i + 1 < Self.steps.count ? i + 1 : nil; settle() }
    func back() { if let i = index, i > 0 { index = i - 1 }; settle() }

    private func settle() {
        for delay in [0.35, 0.8] { DispatchQueue.main.asyncAfter(deadline: .now() + delay) { self.pulse += 1 } }
    }
    func end() { index = nil }

    /// Targets say where they are only while the guide runs, so normal use isn't slowed.
    func report(_ target: GuestTourTarget, _ rect: CGRect) {
        guard isActive, rect.width > 1, frames[target] != rect else { return }
        DispatchQueue.main.async { self.frames[target] = rect }
    }
}

private struct GuestTourKey: EnvironmentKey { static let defaultValue: GuestTour? = nil }
extension EnvironmentValues {
    var guestTour: GuestTour? {
        get { self[GuestTourKey.self] }
        set { self[GuestTourKey.self] = newValue }
    }
}

extension View {
    /// Marks a control or area the guide can light up.
    func guestTourTarget(_ target: GuestTourTarget) -> some View { modifier(GuestTourTargetModifier(target: target)) }
}

private struct GuestTourTargetModifier: ViewModifier {
    let target: GuestTourTarget
    @Environment(\.guestTour) private var tour

    func body(content: Content) -> some View {
        if let tour {
            content.background(GuestTourReporter(tour: tour, target: target))
        } else {
            content
        }
    }
}

private struct GuestTourReporter: View {
    @ObservedObject var tour: GuestTour
    let target: GuestTourTarget

    var body: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear { tour.report(target, proxy.frame(in: .global)) }
                .onChange(of: proxy.frame(in: .global)) { _, frame in tour.report(target, frame) }
                .onChange(of: tour.index) { _, _ in tour.report(target, proxy.frame(in: .global)) }
                .onChange(of: tour.pulse) { _, _ in tour.report(target, proxy.frame(in: .global)) }
        }
        .allowsHitTesting(false)
    }
}
