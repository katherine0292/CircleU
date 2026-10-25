import SwiftUI

/// Shared visual fixtures for this brand pass. Labels intentionally have no action handlers.
enum BrandFixture {
    static func eyebrow(_ text: String) -> some View {
        Text(text).font(BrandDemoFont.font(11, .bold)).tracking(1.5)
            .foregroundStyle(BrandDemoColor.blue)
    }

    static func title(_ text: String) -> some View {
        Text(text).font(BrandDemoFont.font(31, .bold)).tracking(-1)
            .fixedSize(horizontal: false, vertical: true)
    }

    static func detail(_ text: String, size: CGFloat = 15) -> some View {
        Text(text).font(BrandDemoFont.font(size)).lineSpacing(5)
            .foregroundStyle(BrandDemoColor.muted)
            .fixedSize(horizontal: false, vertical: true)
    }

    static func action(_ text: String, primary: Bool = true, symbol: String? = nil) -> some View {
        HStack(spacing: 9) {
            if let symbol {
                Image(systemName: symbol).font(.system(size: 16, weight: .medium, design: .rounded))
                    .accessibilityHidden(true)
            }
            Text(text).font(BrandDemoFont.font(16, .semibold))
        }
            .frame(maxWidth: .infinity).frame(height: 54)
            .foregroundStyle(primary ? .white : BrandDemoColor.blue)
            .background(primary ? BrandDemoColor.blue : .white, in: RoundedRectangle(cornerRadius: 17))
    }

    static func tabs(selected: PrototypeScreen) -> some View {
        HStack(spacing: 8) {
            ForEach(PrototypeScreen.allCases) { screen in
                VStack(spacing: 3) {
                    BrandArtwork(name: screen == .practice ? "BrandPracticeV2" : "Brand\(screen.rawValue)")
                        .frame(width: 32, height: 32)
                    Text(screen.rawValue).font(BrandDemoFont.font(11, screen == selected ? .bold : .medium))
                }
                .frame(maxWidth: .infinity).padding(.vertical, 5)
                .foregroundStyle(screen == selected ? BrandDemoColor.blue : BrandDemoColor.muted)
                .background(screen == selected ? BrandDemoColor.ice : .clear, in: RoundedRectangle(cornerRadius: 17))
            }
        }
        .padding(8).background(.white, in: RoundedRectangle(cornerRadius: 24))
    }

    static func card(title: String, subtitle: String, body: String, tag: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(subtitle).font(BrandDemoFont.font(11, .medium)).foregroundStyle(BrandDemoColor.muted)
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(BrandDemoColor.muted)
            }
            Text(title).font(BrandDemoFont.font(18, .semibold)).tracking(-0.3)
            detail(body, size: 14)
            if let tag {
                Text(tag).font(BrandDemoFont.font(11, .semibold)).foregroundStyle(BrandDemoColor.blue)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(BrandDemoColor.ice, in: Capsule())
            }
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 22))
    }
}

/// Brand application proposals; original Draft 02 reference views remain unchanged.
public struct BrandHubPreview: View {
    public let screen: PrototypeScreen

    public init(screen: PrototypeScreen) { self.screen = screen }

    public var body: some View {
        if screen == .today {
            BrandTodayPreview(practiceArtwork: "BrandPracticeV2")
        } else {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    BrandWordmark(size: 23)
                    Spacer()
                    Image(systemName: "slider.horizontal.3").font(.system(size: 20, weight: .medium))
                }
                .padding(.top, 12)
                HStack(alignment: .center) {
                    BrandFixture.title(screen.rawValue)
                    Spacer()
                    BrandArtwork(name: screen == .journal ? "BrandJournal" : "BrandPracticeV2")
                        .frame(width: 48, height: 48)
                }
                .padding(.top, 12)

                if screen == .journal {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                        Text("Search your journal").font(BrandDemoFont.font(14))
                        Spacer()
                    }
                    .foregroundStyle(BrandDemoColor.muted).padding(16)
                    .background(.white, in: RoundedRectangle(cornerRadius: 16)).padding(.top, 22)
                    BrandFixture.eyebrow("RECENT MOMENTS").padding(.top, 24).padding(.bottom, 12)
                    BrandFixture.card(
                        title: "The group deadline", subtitle: "Today · Reflection",
                        body: "I need a clear update and a shared plan.", tag: "Linked practice"
                    )
                    BrandFixture.card(
                        title: "Speaking up in class", subtitle: "Yesterday · My words",
                        body: "I had something to add, but I held back."
                    ).padding(.top, 12)
                    Spacer(minLength: 12)
                    BrandFixture.action("New reflection", symbol: "square.and.pencil").padding(.bottom, 16)
                } else {
                    BrandFixture.action("Practice a message", symbol: "bubble.left.and.bubble.right").padding(.top, 20)
                    BrandFixture.eyebrow("SAVED PRACTICE").padding(.top, 22).padding(.bottom, 12)
                    BrandFixture.card(
                        title: "A deadline update", subtitle: "Today · Linked to a reflection",
                        body: "Could you send me an update by 3 pm today?", tag: "Clear and considerate"
                    )
                    BrandFixture.card(
                        title: "Making some space", subtitle: "Yesterday · Standalone message",
                        body: "I can’t take this on today. Could we talk tomorrow?"
                    ).padding(.top, 12)
                    Spacer(minLength: 12)
                }
                BrandFixture.tabs(selected: screen)
            }
            .padding(.horizontal, 24).padding(.bottom, 22)
            .frame(width: 390, height: 844)
            .foregroundStyle(BrandDemoColor.ink).background(BrandDemoColor.ice)
            .clipShape(RoundedRectangle(cornerRadius: 36)).environment(\.colorScheme, .light)
        }
    }
}

/// Static editing specimens: original words and editable interpretation remain distinct.
public struct BrandEditorPreview: View {
    public let kind: EditorPreviewKind
    /// Static state for leaving with unsaved edits (walkthrough task 2); real behaviour is for the app.
    public let showsLeavePrompt: Bool

    public init(kind: EditorPreviewKind, showsLeavePrompt: Bool = false) {
        self.kind = kind
        self.showsLeavePrompt = showsLeavePrompt
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "chevron.left").font(.system(size: 18, weight: .semibold))
                Text(kind == .reflection ? "Reflection" : "Practice").font(BrandDemoFont.font(14, .semibold))
                Spacer()
            }
            .padding(.top, 25)
            BrandFixture.title(kind.title).padding(.top, 40)
            BrandFixture.detail(kind == .reflection
                ? "Edit the reflection. Your original words stay unchanged."
                : "Shape the message in your own voice. Nothing is sent.")
                .padding(.top, 12)

            VStack(alignment: .leading, spacing: 9) {
                HStack(spacing: 6) {
                    Image(systemName: kind == .reflection ? "quote.opening" : "text.bubble")
                    Text(kind == .reflection ? "MY WORDS · UNCHANGED" : "CONTEXT · STANDALONE PRACTICE")
                        .tracking(0.6)
                }
                .font(BrandDemoFont.font(10, .bold)).foregroundStyle(BrandDemoColor.muted)
                BrandFixture.detail(kind == .reflection
                    ? "My groupmate missed our deadline. I’m worried we won’t finish in time."
                    : "Ask a groupmate for a clear deadline update.", size: 14)
            }
            .padding(17).frame(maxWidth: .infinity, alignment: .leading)
            .background(BrandDemoColor.blue.opacity(0.04), in: RoundedRectangle(cornerRadius: 18))
            .padding(.top, 24)

            Text(kind == .reflection ? "Your reflection" : "Your message")
                .font(BrandDemoFont.font(14, .semibold)).padding(.top, 23).padding(.bottom, 10)
            Text(kind == .reflection
                ? "I feel frustrated and worried.\n\nI need a clear update and a shared plan. I can ask what is realistic without assuming why they are late."
                : "Could you send me an update by 3 pm today?\n\nIf you need more time, let’s agree on a plan together.")
                .font(BrandDemoFont.font(16)).lineSpacing(5)
                .frame(maxWidth: .infinity, minHeight: 163, alignment: .topLeading)
                .padding(18).background(.white, in: RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(BrandDemoColor.blue.opacity(0.2)))
            if kind == .message {
                BrandFixture.detail("Saving this message creates no journal entry.", size: 12).padding(.top, 10)
            }
            Spacer(minLength: 14)
            BrandFixture.action(kind == .reflection ? "Save reflection" : "Save message")
            if kind == .message {
                BrandFixture.action("Copy message", primary: false).padding(.top, 8)
            }
            Text("Discard edits").font(BrandDemoFont.font(14, .semibold))
                .foregroundStyle(BrandDemoColor.muted).frame(maxWidth: .infinity).frame(height: 42)
        }
        .padding(.horizontal, 24).padding(.bottom, 22)
        .frame(width: 390, height: 844)
        .foregroundStyle(BrandDemoColor.ink).background(BrandDemoColor.ice)
        .overlay { if showsLeavePrompt { leavePrompt } }
        .clipShape(RoundedRectangle(cornerRadius: 36)).environment(\.colorScheme, .light)
    }

    private var leavePrompt: some View {
        ZStack {
            BrandDemoColor.ink.opacity(0.28)
            VStack(spacing: 14) {
                Text("Discard your changes?").font(BrandDemoFont.font(18, .bold))
                BrandFixture.detail("Your edits to this reflection haven’t been saved.", size: 14)
                    .multilineTextAlignment(.center)
                BrandFixture.action("Keep editing")
                Text("Discard").font(BrandDemoFont.font(15, .semibold))
                    .foregroundStyle(.red) // System destructive colour; no new brand token.
                    .frame(maxWidth: .infinity).frame(height: 44)
            }
            .padding(22).background(.white, in: RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal, 28)
        }
    }
}

public struct BrandFlowGallery: View {
    public let editors: Bool
    public init(editors: Bool = false) { self.editors = editors }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                BrandWordmark(size: 30)
                Spacer()
                Text(editors ? "SPACE FOR YOUR WORDS" : "THREE PLACES. ONE FAMILIAR FEEL.")
                    .font(BrandDemoFont.font(11, .bold)).tracking(1.2)
            }
            HStack(alignment: .top, spacing: 24) {
                if editors {
                    ForEach(EditorPreviewKind.allCases) { kind in
                        VStack(alignment: .leading, spacing: 12) {
                            BrandFixture.eyebrow(kind == .reflection ? "01 / REFLECTION EDITOR" : "02 / MESSAGE EDITOR")
                            BrandEditorPreview(kind: kind)
                        }
                    }
                } else {
                    ForEach(PrototypeScreen.allCases) { screen in
                        VStack(alignment: .leading, spacing: 12) {
                            BrandFixture.eyebrow(screen.rawValue.uppercased())
                            BrandHubPreview(screen: screen)
                        }
                    }
                }
            }
            BrandFixture.detail("Brand demo 02 · Layout proposals · Invented content · Static fields and actions", size: 12)
        }
        .padding(32).foregroundStyle(BrandDemoColor.ink).background(.white)
        .environment(\.colorScheme, .light)
    }
}

#Preview("Brand · Journal", traits: .sizeThatFitsLayout) { BrandHubPreview(screen: .journal) }
#Preview("Brand · Practice", traits: .sizeThatFitsLayout) { BrandHubPreview(screen: .practice) }
#Preview("Brand · Edit reflection", traits: .sizeThatFitsLayout) { BrandEditorPreview(kind: .reflection) }
#Preview("Brand · Edit message", traits: .sizeThatFitsLayout) { BrandEditorPreview(kind: .message) }
#Preview("Brand · Hubs", traits: .sizeThatFitsLayout) { BrandFlowGallery() }
#Preview("Brand · Editors", traits: .sizeThatFitsLayout) { BrandFlowGallery(editors: true) }
