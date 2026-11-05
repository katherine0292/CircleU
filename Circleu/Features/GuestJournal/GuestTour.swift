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

// MARK: - Overlay

/// The dimmed screen with a lit window over the current target, and the step card.
struct GuestTourOverlay: View {
    @ObservedObject var tour: GuestTour
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var glow = false

    var body: some View {
        GeometryReader { geo in
            let origin = geo.frame(in: .global).origin
            let hole = currentHole(origin: origin)
            ZStack {
                GuestSpotlightShape(hole: hole ?? CGRect(x: geo.size.width / 2, y: geo.size.height / 2, width: 0, height: 0),
                                    radius: 22)
                    .fill(Color.black.opacity(0.58), style: FillStyle(eoFill: true))
                    .contentShape(Rectangle())
                    .onTapGesture {} // The guide leads; the app waits underneath.
                if let hole {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.95), lineWidth: 2.5)
                        .shadow(color: .white.opacity(glow ? 0.9 : 0.4), radius: glow ? 16 : 8)
                        .shadow(color: GuestWarm.apricotWash.opacity(0.9), radius: glow ? 22 : 10)
                        .frame(width: hole.width, height: hole.height)
                        .position(x: hole.midX, y: hole.midY)
                        .scaleEffect(glow && !reduceMotion ? 1.02 : 1, anchor: .center)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                }
                if let hole {
                    // A paw points at the lit area from the card's side.
                    let below = hole.midY < geo.size.height * 0.5
                    GuestPointer(symbol: below ? "hand.point.up.fill" : "hand.point.down.fill", dy: below ? -6 : 6)
                        .position(x: hole.midX, y: below ? hole.maxY + 22 : hole.minY - 22)
                        .allowsHitTesting(false)
                }
                card
                    .frame(maxWidth: 360)
                    .padding(.horizontal, 20)
                    .position(x: geo.size.width / 2, y: cardY(hole: hole, height: geo.size.height))
                    .id(tour.index)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
            .animation(reduceMotion ? nil : .spring(response: 0.5, dampingFraction: 0.85), value: hole)
            .animation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.85), value: tour.index)
        }
        .ignoresSafeArea()
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) { glow = true }
        }
        .accessibilityAddTraits(.isModal)
    }

    private func currentHole(origin: CGPoint) -> CGRect? {
        guard let target = tour.step?.target else { return nil }
        let rect = target == .tabBar ? Self.tabBarFrame() : tour.frames[target]
        guard let rect, rect.width > 1 else { return nil }
        return rect.offsetBy(dx: -origin.x, dy: -origin.y).insetBy(dx: -8, dy: -8)
    }

    /// The card sits below a target in the top half, above one in the bottom half, centred otherwise.
    private func cardY(hole: CGRect?, height: CGFloat) -> CGFloat {
        let half: CGFloat = 105
        guard let hole else { return height / 2 }
        let y = hole.midY < height * 0.5 ? hole.maxY + 44 + half : hole.minY - 44 - half
        return min(max(y, 70 + half), height - 40 - half)
    }

    private var card: some View {
        let i = tour.index ?? 0
        let step = GuestTour.steps[i]
        let last = i == GuestTour.steps.count - 1
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                // A different pose for each step; it breathes and hops on each new step.
                GuestLivingImage(asset: step.pose, breathes: true).frame(width: 60, height: 60)
                    .id(step.pose)
                    .transition(.scale(scale: 0.6).combined(with: .opacity))
                    .guestHop(on: i)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Step \(i + 1) of \(GuestTour.steps.count)")
                        .font(GuestBrand.font(.caption, .semibold)).foregroundStyle(GuestBrand.muted)
                    Text(step.title).font(GuestWarm.heading(.title3)).foregroundStyle(GuestBrand.ink)
                        .accessibilityAddTraits(.isHeader)
                }
                Spacer(minLength: 0)
                Button { tour.end() } label: {
                    Text("Skip").font(GuestBrand.font(.footnote, .semibold)).foregroundStyle(GuestBrand.muted)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityLabel("Skip the guide")
            }
            Text(step.body).font(GuestBrand.font(.body)).foregroundStyle(GuestBrand.ink)
                .fixedSize(horizontal: false, vertical: true)
            // Progress: one dot per step, the current one wider.
            HStack(spacing: 4) {
                ForEach(0..<GuestTour.steps.count, id: \.self) { k in
                    Capsule().fill(k == i ? GuestWarm.cocoa : GuestWarm.cocoa.opacity(0.18))
                        .frame(width: k == i ? 16 : 5, height: 5)
                }
            }
            .accessibilityHidden(true)
            HStack(spacing: 10) {
                if i > 0 {
                    Button("Back") { tour.back() }
                        .font(GuestBrand.font(.subheadline, .semibold)).foregroundStyle(GuestWarm.cocoa)
                        .padding(.horizontal, 16).frame(minHeight: 44)
                        .guestPill(in: Capsule())
                }
                Spacer(minLength: 0)
                Button(last ? "Done" : "Next") { tour.next() }
                    .buttonStyle(GuestSmallCocoaStyle())
            }
        }
        .padding(16)
        .background(GuestWarm.cream, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.25), radius: 20, y: 10)
    }

    /// The system tab bar isn't a SwiftUI view, so its frame is read from the window.
    static func tabBarFrame() -> CGRect? {
        let window = UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.keyWindow }.first
        func find(_ view: UIView) -> UITabBar? {
            if let bar = view as? UITabBar, !bar.isHidden { return bar }
            for sub in view.subviews { if let bar = find(sub) { return bar } }
            return nil
        }
        guard let window, let bar = find(window) else { return nil }
        return bar.convert(bar.bounds, to: window)
    }
}

/// A full-screen dim with a rounded window cut out; the window animates between targets.
struct GuestSpotlightShape: Shape {
    var hole: CGRect
    var radius: CGFloat

    var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>> {
        get { AnimatablePair(AnimatablePair(hole.origin.x, hole.origin.y), AnimatablePair(hole.width, hole.height)) }
        set { hole = CGRect(x: newValue.first.first, y: newValue.first.second, width: newValue.second.first, height: newValue.second.second) }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path(rect)
        if hole.width > 0 { path.addRoundedRect(in: hole, cornerSize: CGSize(width: radius, height: radius), style: .continuous) }
        return path
    }
}

/// The "?" on Write that starts the guide.
struct GuestTourButton: View {
    @Environment(\.guestTour) private var tour
    var body: some View {
        Button { tour?.start() } label: { Image(systemName: "questionmark.circle") }
            .accessibilityLabel("Guide")
            .accessibilityHint("A step-by-step tour of Write, Journal and Talk.")
    }
}
