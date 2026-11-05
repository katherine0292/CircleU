import SwiftUI

/// The warm, glass look for Tuanwei the otter (visual proposal of 6 November 2026), rolled out one
/// screen at a time: Today and the tab bar first. Colours come from the otter and its scenes.
enum GuestWarm {
    /// Cocoa, the otter's fur: the one filled action. White text on it is 8.9:1.
    static let cocoa = Color(red: 107 / 255, green: 63 / 255, blue: 44 / 255)
    static let cocoaLight = Color(red: 131 / 255, green: 80 / 255, blue: 57 / 255)
    /// Text. 13:1 on `oat`.
    static let ink = Color(red: 46 / 255, green: 29 / 255, blue: 20 / 255)
    /// Secondary text; 5.6:1 on `oat`.
    static let muted = Color(red: 110 / 255, green: 93 / 255, blue: 80 / 255)
    /// The scarf, deepened for text and selected states; 5.3:1 on `oat`.
    static let sage = Color(red: 78 / 255, green: 107 / 255, blue: 71 / 255)
    /// The page colour, from the scenes' walls.
    static let oat = Color(red: 243 / 255, green: 235 / 255, blue: 224 / 255)
    /// Solid stand-in for glass when Reduce Transparency is on.
    static let cream = Color(red: 252 / 255, green: 247 / 255, blue: 240 / 255)

    static let apricotWash = Color(red: 243 / 255, green: 217 / 255, blue: 194 / 255)
    static let sageWash = Color(red: 214 / 255, green: 227 / 255, blue: 204 / 255)
    static let creamWash = Color(red: 247 / 255, green: 231 / 255, blue: 207 / 255)
    static let roseWash = Color(red: 234 / 255, green: 213 / 255, blue: 196 / 255)

    /// Rounded headings, softer like the clay character; scales with Dynamic Type.
    static func heading(_ style: Font.TextStyle) -> Font { .system(style, design: .rounded, weight: .bold) }
}

/// A slow, warm gradient behind the page. It moves only when motion is allowed (iOS 18 and
/// later); otherwise it is a still wash. Decorative.
///
/// With a `mood` (only a feeling the person chose themselves, never one guessed from their words)
/// the colours drift toward that feeling's wash, cross-fading over about a second.
struct GuestFlowingBackground: View {
    var mood: GuestEntryFeeling? = nil
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if #available(iOS 18.0, *) {
                if reduceMotion {
                    layers(at: 0)
                } else {
                    TimelineView(.animation(minimumInterval: 1 / 20)) { context in
                        layers(at: context.date.timeIntervalSinceReferenceDate)
                    }
                }
            } else {
                still
            }
        }
        .animation(.easeInOut(duration: reduceMotion ? 0.2 : 1.2), value: mood)
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    @available(iOS 18.0, *)
    private func layers(at time: TimeInterval) -> some View {
        ZStack {
            mesh(at: time, colors: Self.base)
            ForEach(GuestEntryFeeling.allCases, id: \.self) { feeling in
                mesh(at: time, colors: Self.palette(feeling)).opacity(mood == feeling ? 1 : 0)
            }
        }
    }

    @available(iOS 18.0, *)
    private func mesh(at time: TimeInterval, colors: [Color]) -> some View {
        // One slow loop of about 18 seconds; the middle points drift a little.
        let t = Float(time.truncatingRemainder(dividingBy: 36) / 36 * 2 * .pi)
        let dx = 0.08 * sin(t), dy = 0.06 * cos(t)
        return MeshGradient(width: 3, height: 3, points: [
            [0, 0], [0.5, 0], [1, 0],
            [0, 0.5 + dy], [0.5 + dx, 0.5 - dy], [1, 0.5 + dx],
            [0, 1], [0.5 - dx, 1], [1, 1],
        ], colors: colors)
    }

    private static let base: [Color] = [
        GuestWarm.creamWash, GuestWarm.oat, GuestWarm.sageWash,
        GuestWarm.apricotWash, GuestWarm.oat, GuestWarm.sageWash,
        GuestWarm.creamWash, GuestWarm.roseWash, GuestWarm.oat,
    ]

    /// Pale washes only, so text contrast on cards and glass is unchanged.
    private static func palette(_ feeling: GuestEntryFeeling) -> [Color] {
        let tint: Color
        switch feeling {
        case .calm: tint = Color(red: 0.80, green: 0.89, blue: 0.80)        // soft sage
        case .worried: tint = Color(red: 0.86, green: 0.84, blue: 0.93)     // lavender
        case .overloaded: tint = Color(red: 0.84, green: 0.86, blue: 0.89)  // misty grey-blue
        case .happy: tint = Color(red: 0.98, green: 0.88, blue: 0.70)       // sunny apricot
        case .sad: tint = Color(red: 0.80, green: 0.87, blue: 0.94)         // pale rain blue
        case .frustrated: tint = Color(red: 0.94, green: 0.80, blue: 0.76)  // dusty rose
        }
        return [
            GuestWarm.creamWash, tint, GuestWarm.oat,
            tint, GuestWarm.oat, tint,
            GuestWarm.oat, tint, GuestWarm.creamWash,
        ]
    }

    private var still: some View {
        ZStack {
            GuestWarm.oat
            Circle().fill(GuestWarm.apricotWash).frame(width: 320).blur(radius: 90).offset(x: -120, y: -40)
            Circle().fill(GuestWarm.sageWash).frame(width: 300).blur(radius: 90).offset(x: 140, y: 120)
            Circle().fill(GuestWarm.creamWash).frame(width: 300).blur(radius: 90).offset(x: -80, y: 360)
            ForEach(GuestEntryFeeling.allCases, id: \.self) { feeling in
                Self.palette(feeling)[1].opacity(mood == feeling ? 0.5 : 0)
            }
        }
    }
}

/// Glass behind a control or card: system Liquid Glass on iOS 26, a frosted material before that,
/// and solid cream when Reduce Transparency is on, so text on it stays readable.
private struct GuestGlassBackground<S: Shape>: ViewModifier {
    let shape: S
    var interactive = false
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        if reduceTransparency {
            content.background(GuestWarm.cream, in: shape)
                .overlay(shape.stroke(GuestWarm.muted.opacity(0.25), lineWidth: 1))
        } else if #available(iOS 26.0, *) {
            content.glassEffect(interactive ? .regular.interactive() : .regular, in: shape)
        } else {
            content.background(.ultraThinMaterial, in: shape)
                .overlay(shape.stroke(.white.opacity(0.6), lineWidth: 1))
                .shadow(color: GuestWarm.ink.opacity(0.08), radius: 12, y: 6)
        }
    }
}

extension View {
    func guestGlass<S: Shape>(in shape: S, interactive: Bool = false) -> some View {
        modifier(GuestGlassBackground(shape: shape, interactive: interactive))
    }
}

/// A content card: warm, nearly solid paper with a soft lift. Glass is kept for controls that
/// float above content (Apple's Liquid Glass guidance); cards stay readable.
private struct GuestCardBackground<S: Shape>: ViewModifier {
    let shape: S
    var fill: Color?
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        content
            .background(fill ?? GuestWarm.cream.opacity(reduceTransparency ? 1 : 0.9), in: shape)
            .overlay(shape.stroke(.white.opacity(0.7), lineWidth: 1))
            .shadow(color: GuestWarm.ink.opacity(0.07), radius: 14, y: 6)
    }
}

extension View {
    func guestCard<S: Shape>(in shape: S, fill: Color? = nil) -> some View {
        modifier(GuestCardBackground(shape: shape, fill: fill))
    }
}

/// A small in-content control (chips, tone choices): a cream pill with a hairline edge. Glass is
/// not used inside content, where it draws an extra glass layer around the whole group.
private struct GuestPillBackground<S: InsettableShape>: ViewModifier {
    let shape: S
    var selected = false

    func body(content: Content) -> some View {
        content
            .background(selected ? GuestWarm.cocoa : GuestWarm.cream.opacity(0.92), in: shape)
            .overlay(shape.strokeBorder(selected ? .clear : GuestWarm.cocoa.opacity(0.18), lineWidth: 1))
            .shadow(color: GuestWarm.ink.opacity(0.05), radius: 4, y: 2)
    }
}

extension View {
    func guestPill<S: InsettableShape>(in shape: S, selected: Bool = false) -> some View {
        modifier(GuestPillBackground(shape: shape, selected: selected))
    }
}

/// Behind a pinned bottom action: the page fades to oat so scrolled words don't show through.
struct GuestBottomFade: View {
    var body: some View {
        LinearGradient(colors: [GuestWarm.oat.opacity(0), GuestWarm.oat.opacity(0.92)], startPoint: .top, endPoint: .center)
            .ignoresSafeArea(edges: .bottom)
            .allowsHitTesting(false)
    }
}

/// A secondary action: clear glass with cocoa words, same height and spring as the main one.
struct GuestGlassButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(GuestWarm.heading(.headline))
            .multilineTextAlignment(.center)
            .foregroundStyle(isEnabled ? GuestWarm.cocoa : GuestWarm.muted)
            .frame(maxWidth: .infinity, minHeight: 54)
            .padding(.horizontal, 16)
            .contentShape(Capsule())
            .guestGlass(in: Capsule())
            .opacity(isEnabled ? 1 : 0.7)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.96 : 1)
            .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.55), value: configuration.isPressed)
    }
}

/// Content that rises gently into place when it first appears, `order` steps after the first.
/// No movement with Reduce Motion.
private struct GuestRiseIn: ViewModifier {
    let order: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .opacity(shown || reduceMotion ? 1 : 0)
            .offset(y: shown || reduceMotion ? 0 : 14)
            .onAppear {
                guard !reduceMotion, !shown else { return }
                withAnimation(.spring(response: 0.55, dampingFraction: 0.82).delay(Double(order) * 0.07)) { shown = true }
            }
    }
}

extension View {
    func guestRiseIn(_ order: Int = 0) -> some View { modifier(GuestRiseIn(order: order)) }
}

/// The page's one main action: solid cocoa when it can be used, quiet glass when it can't.
/// Presses dip slightly and spring back (no movement with Reduce Motion).
struct GuestCocoaButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        let label = configuration.label
            .font(GuestWarm.heading(.headline))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 54)
            .padding(.horizontal, 16)
            .contentShape(Capsule())
        Group {
            if isEnabled {
                label.foregroundStyle(.white)
                    .background(LinearGradient(colors: [GuestWarm.cocoaLight, GuestWarm.cocoa],
                                               startPoint: .top, endPoint: .bottom), in: Capsule())
                    .overlay(Capsule().strokeBorder(.white.opacity(0.25), lineWidth: 1))
                    .shadow(color: GuestWarm.cocoa.opacity(0.3), radius: 10, y: 6)
            } else {
                label.foregroundStyle(GuestWarm.muted).guestGlass(in: Capsule())
            }
        }
        .scaleEffect(configuration.isPressed && !reduceMotion ? 0.96 : 1)
        .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.55), value: configuration.isPressed)
        .animation(.easeInOut(duration: 0.25), value: isEnabled)
    }
}

/// A soft ring that breathes around the microphone while it listens. Still with Reduce Motion.
struct GuestBreathingRing: View {
    let active: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var expanded = false

    var body: some View {
        Circle()
            .stroke(GuestWarm.sage.opacity(active ? 0.5 : 0), lineWidth: 2)
            .scaleEffect(active && expanded && !reduceMotion ? 1.22 : 1)
            .opacity(active ? (expanded && !reduceMotion ? 0.35 : 1) : 0)
            .onChange(of: active) { _, isActive in
                guard isActive, !reduceMotion else {
                    withAnimation(.easeOut(duration: 0.2)) { expanded = false }
                    return
                }
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { expanded = true }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

/// A plain control that dips slightly and springs back when pressed (no movement with Reduce Motion).
struct GuestSpringPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.92 : 1)
            .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.55), value: configuration.isPressed)
    }
}

/// A small happy hop when something appears (the "Saved" otter): squash, jump, settle.
/// Only confirms the action; it isn't praise. Still with Reduce Motion.
private struct GuestHop<Value: Equatable>: ViewModifier {
    /// Hops again whenever this changes; `nil` hops once, when the view appears.
    let on: Value?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var trigger = 0

    func body(content: Content) -> some View {
        content
            .keyframeAnimator(initialValue: GuestHopFrame(), trigger: trigger) { view, frame in
                view.scaleEffect(x: frame.scaleX, y: frame.scaleY, anchor: .bottom).offset(y: frame.y)
            } keyframes: { _ in
                KeyframeTrack(\.y) {
                    LinearKeyframe(0, duration: 0.12)
                    SpringKeyframe(-14, duration: 0.25, spring: .snappy)
                    SpringKeyframe(0, duration: 0.4, spring: .bouncy)
                }
                KeyframeTrack(\.scaleX) {
                    SpringKeyframe(1.1, duration: 0.12)
                    SpringKeyframe(0.95, duration: 0.25)
                    SpringKeyframe(1, duration: 0.4, spring: .bouncy)
                }
                KeyframeTrack(\.scaleY) {
                    SpringKeyframe(0.88, duration: 0.12)
                    SpringKeyframe(1.06, duration: 0.25)
                    SpringKeyframe(1, duration: 0.4, spring: .bouncy)
                }
            }
            .onAppear { if on == nil, !reduceMotion { trigger += 1 } }
            .onChange(of: on) { _, _ in if !reduceMotion { trigger += 1 } }
    }
}

private struct GuestHopFrame {
    var y: CGFloat = 0
    var scaleX: CGFloat = 1
    var scaleY: CGFloat = 1
}

extension View {
    func guestHop() -> some View { modifier(GuestHop<Int>(on: nil)) }
    func guestHop<Value: Equatable>(on value: Value) -> some View { modifier(GuestHop(on: value)) }
}

/// Text that arrives letter by letter, each one easing from soft blur into place (iOS 18
/// TextRenderer); earlier systems and Reduce Motion show it at once. Calls `onDone` when shown.
struct GuestRevealText: View {
    let text: String
    var delay: Double = 0
    var onDone: () -> Void = {}
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var progress = 0.0

    var body: some View {
        if #available(iOS 18.0, *) {
            Text(text)
                .textRenderer(GuestRevealRenderer(progress: reduceMotion ? 1 : progress))
                .onAppear {
                    if reduceMotion { onDone(); return }
                    // Longer text takes a little longer, within 0.8–2 seconds.
                    let duration = min(2, max(0.8, Double(text.count) / 60))
                    withAnimation(.easeOut(duration: duration).delay(delay)) { progress = 1 } completion: { onDone() }
                }
        } else {
            Text(text).onAppear { onDone() }
        }
    }
}

@available(iOS 18.0, *)
private struct GuestRevealRenderer: TextRenderer {
    var progress: Double
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func draw(layout: Text.Layout, in context: inout GraphicsContext) {
        let slices = layout.flatMap { line in line.flatMap { run in run.map { $0 } } }
        let count = Double(max(slices.count, 1))
        for (index, slice) in slices.enumerated() {
            // Each letter starts a little after the one before and takes 25% of the time.
            let start = Double(index) / count * 0.75
            let local = min(max((progress - start) / 0.25, 0), 1)
            var copy = context
            copy.opacity = local
            if local < 1 { copy.addFilter(.blur(radius: (1 - local) * 5)) }
            copy.translateBy(x: 0, y: (1 - local) * 6)
            copy.draw(slice)
        }
    }
}

/// A clay squish when a choice changes: squashes wide, stretches tall, then settles, with a light
/// tap of haptics. Still (haptic only) with Reduce Motion.
private struct GuestSquish<Value: Equatable>: ViewModifier {
    let trigger: Value
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .keyframeAnimator(initialValue: CGSize(width: 1, height: 1), trigger: trigger) { view, scale in
                view.scaleEffect(x: reduceMotion ? 1 : scale.width, y: reduceMotion ? 1 : scale.height)
            } keyframes: { _ in
                KeyframeTrack(\.width) {
                    SpringKeyframe(1.12, duration: 0.1)
                    SpringKeyframe(0.94, duration: 0.16)
                    SpringKeyframe(1, duration: 0.35, spring: .bouncy)
                }
                KeyframeTrack(\.height) {
                    SpringKeyframe(0.86, duration: 0.1)
                    SpringKeyframe(1.08, duration: 0.16)
                    SpringKeyframe(1, duration: 0.35, spring: .bouncy)
                }
            }
            .sensoryFeedback(.selection, trigger: trigger)
    }
}

extension View {
    func guestSquish<Value: Equatable>(on trigger: Value) -> some View { modifier(GuestSquish(trigger: trigger)) }
}

// MARK: - Hold to confirm

/// A row that must be held to act, for things that can't be undone. Holding fills the row in red;
/// letting go early empties it, gives a small shake and says "Hold to delete". VoiceOver and
/// Switch Control get a plain action instead of the hold.
struct GuestHoldToConfirm<Label: View>: View {
    var duration: Double = 1.2
    var hint = "Hold to delete"
    let onConfirm: () -> Void
    @ViewBuilder let label: () -> Label
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var progress: CGFloat = 0
    @State private var completed = false
    @State private var showsHint = false
    @State private var shakes = 0
    @State private var confirms = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            label()
                .background(alignment: .leading) {
                    GeometryReader { geo in
                        Rectangle().fill(GuestBrand.danger.opacity(0.14)).frame(width: geo.size.width * progress)
                    }
                }
                .contentShape(Rectangle())
                .keyframeAnimator(initialValue: 0, trigger: shakes) { view, x in
                    view.offset(x: reduceMotion ? 0 : x)
                } keyframes: { _ in
                    KeyframeTrack {
                        LinearKeyframe(-6, duration: 0.06)
                        LinearKeyframe(6, duration: 0.08)
                        LinearKeyframe(-3, duration: 0.08)
                        SpringKeyframe(0, duration: 0.2)
                    }
                }
                .onLongPressGesture(minimumDuration: duration, maximumDistance: 40) {
                    completed = true
                    confirms += 1
                    onConfirm()
                    withAnimation(.easeOut(duration: 0.3).delay(0.3)) { progress = 0 }
                } onPressingChanged: { pressing in
                    guard isEnabled else { return }
                    if pressing {
                        completed = false
                        withAnimation(.linear(duration: duration)) { progress = 1 }
                    } else if !completed {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { progress = 0; showsHint = true }
                        shakes += 1
                    }
                }
            if showsHint {
                Text(hint).font(GuestBrand.font(.footnote)).foregroundStyle(GuestBrand.muted)
                    .padding(.horizontal, 16).padding(.bottom, 10)
                    .transition(.opacity)
            }
        }
        .sensoryFeedback(.warning, trigger: confirms)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { onConfirm() }
    }
}

/// A friendly wave when something appears (Talk's empty page): a small rock, twice, then still.
private struct GuestWave: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var trigger = 0

    func body(content: Content) -> some View {
        content
            .keyframeAnimator(initialValue: 0.0, trigger: trigger) { view, angle in
                view.rotationEffect(.degrees(reduceMotion ? 0 : angle), anchor: .bottom)
            } keyframes: { _ in
                KeyframeTrack {
                    SpringKeyframe(-8, duration: 0.18)
                    SpringKeyframe(7, duration: 0.22)
                    SpringKeyframe(-5, duration: 0.2)
                    SpringKeyframe(0, duration: 0.35, spring: .bouncy)
                }
            }
            .onAppear { if !reduceMotion { trigger += 1 } }
    }
}

extension View {
    func guestWave() -> some View { modifier(GuestWave()) }
}
