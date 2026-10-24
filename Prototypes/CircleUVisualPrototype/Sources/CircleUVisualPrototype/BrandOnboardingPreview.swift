import SwiftUI

/// Design fixtures only. Opening never reads storage or advances automatically.
public enum BrandOnboardingScreen: String, CaseIterable {
    case welcome, privacy, earlierData, opening, locked, readError
}

/// Original Welcome composition, with the accepted identity and in-memory panel navigation.
/// No app stores, account services, network, imports or permission requests are used.
public struct BrandOnboardingPreview: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var history: [BrandOnboardingScreen]
    private let illustratedWelcome: Bool

    public init(initialScreen: BrandOnboardingScreen = .welcome, illustratedWelcome: Bool = true) {
        _history = State(initialValue: [.welcome] + (initialScreen == .welcome ? [] : [initialScreen]))
        self.illustratedWelcome = illustratedWelcome
    }

    private var screen: BrandOnboardingScreen { history.last ?? .welcome }

    public var body: some View {
        Group {
            switch screen {
            case .welcome: welcome
            case .privacy: privacy
            case .earlierData: earlierData
            case .opening: opening
            case .locked: failure(locked: true)
            case .readError: failure(locked: false)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(BrandDemoColor.ink)
        .background(BrandDemoColor.ice.ignoresSafeArea())
        .environment(\.colorScheme, .light)
        .tint(BrandDemoColor.blue)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: screen)
    }

    private var welcome: some View {
        ViewThatFits(in: .vertical) {
            welcomeContent
            ScrollView { welcomeContent }
        }
    }

    private var welcomeContent: some View {
        VStack(spacing: 0) {
            BrandWordmark(size: 22)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("CircleU")
                .padding(.top, 16)

            Spacer(minLength: 24)

            VStack(spacing: 0) {
                BrandArtwork(name: "PinguWelcomeV1")
                    .frame(width: 172, height: 172)
                    .frame(maxWidth: .infinity)
                    .background {
                        if illustratedWelcome {
                            WelcomeScene()
                                .padding(.horizontal, -32)
                                .padding(.vertical, -20)
                        }
                    }
                    .accessibilityHidden(true)
                Text("Find your words.")
                    .font(font(32, .bold, relativeTo: .largeTitle))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 32)
                    .accessibilityAddTraits(.isHeader)
                Text("Reflect on a difficult conversation.\nPractise what to say next.")
                    .font(font(17))
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(BrandDemoColor.muted)
                    .frame(maxWidth: 280)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 16)
            }

            Spacer(minLength: 24)

            VStack(spacing: 4) {
                VStack(spacing: 5) {
                    Label("Saved on this device", systemImage: "lock.shield")
                        .font(font(14, .semibold, relativeTo: .subheadline))
                    Text("No CircleU sync. Deleting the app\ncan lose your entries.")
                        .font(font(14, relativeTo: .subheadline))
                        .foregroundStyle(BrandDemoColor.muted)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, 4)
                quietButton("Privacy & data") { navigate(to: .privacy) }
                primaryButton("Get started") { navigate(to: .opening) }
                quietButton("Used CircleU before?") { navigate(to: .earlierData) }
            }
            .padding(.top, 12)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var privacy: some View {
        panel(title: "Your words, your choice.") {
            information("Saved here", symbol: "iphone", text: "No signup, CircleU sync or cloud AI. Suggestions run on-device when available. You can always write without them.")
            information("Backups & recovery", symbol: "arrow.counterclockwise", text: "Device backups may include entries. Recovery after losing your phone or deleting the app isn’t guaranteed.")
            information("Export & delete", symbol: "square.and.arrow.up", text: "Export entries you want to keep. Deleting here won’t remove exported copies or entries in existing device backups.")
            information("Optional voice", symbol: "mic", text: "Type anytime. Permission is requested only when you choose to record.")
            quietButton("Manage earlier CircleU data") { navigate(to: .earlierData) }
            primaryButton("Done") { back() }
        }
    }

    private var earlierData: some View {
        panel(title: "Your earlier words.") {
            Text("Choose whether to bring earlier CircleU entries into this space.")
                .font(font(17)).foregroundStyle(BrandDemoColor.muted)
            information("Your choice", symbol: "hand.raised", text: "Nothing is imported automatically or erased. You can return from Privacy & data anytime.")
            information("Old account recovery", symbol: "person.crop.circle", text: "This separate step may need internet access and sign-in.")
            // Recovery remains in Draft 02; this pass only reviews its introduction.
            Link("Review earlier data", destination: URL(string: "https://www.figma.com/proto/RVLtfmIVcO8gNk5fam0Vjd?node-id=65-663&starting-point-node-id=65%3A663")!)
                .font(font(17, .semibold)).frame(minHeight: 44)
                .accessibilityHint("Opens the existing recovery design in Figma; does not import data")
            primaryButton("Continue without importing") { navigate(to: .opening) }
        }
    }

    private var opening: some View {
        panel(title: "Opening your space…") {
            Image(systemName: "lock.shield")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(BrandDemoColor.blue).accessibilityHidden(true)
            Text("Checking that your saved words can be opened safely.")
                .font(font(17)).foregroundStyle(BrandDemoColor.muted)
            quietButton("Back to welcome") { history = [.welcome] }
        }
    }

    private func failure(locked: Bool) -> some View {
        panel(title: locked ? "Your space is locked." : "Couldn’t open your space.") {
            Text(locked
                 ? "Unlock your iPhone, then try again. Your saved words haven’t been changed."
                 : "Your saved words couldn’t be read. Nothing has been erased or replaced with an empty journal.")
                .font(font(17)).foregroundStyle(BrandDemoColor.muted)
            // Static failure fixtures remain failed; retry cannot manufacture readiness.
            primaryButton("Try again") { }
            quietButton("Privacy & data") { navigate(to: .privacy) }
            quietButton("Back to welcome") { history = [.welcome] }
        }
    }

    private func panel<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: back) { Label("Back", systemImage: "chevron.left") }
                .font(font(17, .medium)).buttonStyle(.plain)
                .foregroundStyle(BrandDemoColor.blue).frame(minHeight: 44)
                .padding(.horizontal, 24)
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(title).font(font(30, .bold, relativeTo: .largeTitle))
                        .accessibilityAddTraits(.isHeader)
                    content()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
            }
        }
    }

    private func information(_ title: String, symbol: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: symbol).font(font(17, .semibold))
            Text(text).font(font(17)).lineSpacing(4).foregroundStyle(BrandDemoColor.muted)
        }
        .padding(18).frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
    }

    private func primaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(font(17, .semibold)).multilineTextAlignment(.center)
                .padding(.horizontal, 16).padding(.vertical, 15)
                .frame(maxWidth: .infinity, minHeight: 54)
                .foregroundStyle(.white)
                .background(BrandDemoColor.blue, in: RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }

    private func quietButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .font(font(14, .semibold, relativeTo: .subheadline))
            .buttonStyle(.plain).foregroundStyle(BrandDemoColor.blue)
            .frame(maxWidth: .infinity, minHeight: 44)
    }

    private func font(_ size: CGFloat, _ weight: Font.Weight = .regular,
                      relativeTo style: Font.TextStyle = .body) -> Font {
        .custom(BrandDemoFont.postScriptName, size: size, relativeTo: style).weight(weight)
    }

    private func navigate(to destination: BrandOnboardingScreen) { history.append(destination) }
    private func back() { if history.count > 1 { history.removeLast() } }
}

/// Renderer-only comparison: review notes are outside the depicted screens.
public struct BrandOnboardingGallery: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Welcome · Original composition, new identity")
                .font(BrandDemoFont.font(24, .bold))
            Text("Visual prototype · No storage check, import or account access · Opening is a static endpoint")
                .font(BrandDemoFont.font(13)).foregroundStyle(BrandDemoColor.muted)
            HStack(alignment: .top, spacing: 28) {
                specimen("Regular · 390 × 844", width: 390, height: 844)
                specimen("Compact width · 375 × 844", width: 375, height: 844)
            }
        }
        .padding(28).background(.white).foregroundStyle(BrandDemoColor.ink)
    }

    private func specimen(_ title: String, width: CGFloat, height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(BrandDemoFont.font(13, .medium))
            BrandOnboardingPreview(illustratedWelcome: false).frame(width: width, height: height)
        }
    }
}

/// Reuses the accepted transparent mascot above; scenery stays behind the art, never the copy.
private struct WelcomeScene: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                LinearGradient(colors: [BrandDemoColor.sky.opacity(0.22), BrandDemoColor.ice],
                               startPoint: .top, endPoint: .bottom)
                Ellipse().fill(.white.opacity(0.85))
                    .frame(width: geometry.size.width * 0.95, height: 105)
                    .offset(x: -geometry.size.width * 0.3, y: 32)
                Ellipse().fill(BrandDemoColor.sky.opacity(0.12))
                    .frame(width: geometry.size.width * 0.9, height: 85)
                    .offset(x: geometry.size.width * 0.35, y: 24)
                Capsule().fill(.white.opacity(0.8)).frame(width: 57, height: 14)
                    .position(x: geometry.size.width * 0.16, y: 45)
                Capsule().fill(.white.opacity(0.65)).frame(width: 40, height: 10)
                    .position(x: geometry.size.width * 0.84, y: 72)
            }
            .mask(LinearGradient(stops: [.init(color: .clear, location: 0),
                                         .init(color: .white, location: 0.15),
                                         .init(color: .white, location: 0.75),
                                         .init(color: .clear, location: 1)],
                                 startPoint: .top, endPoint: .bottom))
            .clipped()
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#Preview("Onboarding · Welcome · phone") {
    BrandOnboardingPreview()
}

#Preview("Onboarding · Privacy · phone") {
    BrandOnboardingPreview(initialScreen: .privacy)
}

#Preview("Onboarding · Earlier data · phone") {
    BrandOnboardingPreview(initialScreen: .earlierData)
}

#Preview("Onboarding · Locked · phone") {
    BrandOnboardingPreview(initialScreen: .locked)
}

#Preview("Onboarding · Read error · phone") {
    BrandOnboardingPreview(initialScreen: .readError)
}

#Preview("Onboarding · Larger text · phone") {
    BrandOnboardingPreview().environment(\.dynamicTypeSize, .accessibility1)
}

#Preview("Onboarding · Comparison", traits: .sizeThatFitsLayout) {
    BrandOnboardingGallery()
}
