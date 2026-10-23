import SwiftUI

/// Fixed scenarios for visual review. These cases never navigate, edit or persist data.
public enum BrandJourneyScreen: String, CaseIterable, Identifiable, Sendable {
    case capture
    case reflection
    case entry
    case practiceContext = "practice-context"
    case wording
    case practiceDetail = "practice-detail"

    public var id: String { rawValue }

    var title: String {
        switch self {
        case .capture: "Start with\nyour words."
        case .reflection: "Does this\nfeel right?"
        case .entry: "The group\ndeadline"
        case .practiceContext: "Start with\nthe situation."
        case .wording: "Words you\ncan work with."
        case .practiceDetail: "A deadline\nupdate"
        }
    }

    var eyebrow: String {
        switch self {
        case .capture: "DESCRIBE A MOMENT"
        case .reflection: "REVIEW THE REFLECTION"
        case .entry: "SAMPLE SAVED ENTRY"
        case .practiceContext: "STANDALONE PRACTICE"
        case .wording: "REVIEW THE WORDING"
        case .practiceDetail: "SAMPLE SAVED MESSAGE"
        }
    }
}

/// Branded core-route specimens. All writing and action affordances are inert sample content.
public struct BrandJourneyPreview: View {
    public let screen: BrandJourneyScreen
    public let linkedContext: Bool
    public let updatedSource: Bool
    private let originalWords = "My groupmate missed our deadline. I’m worried we won’t finish in time."
    private let acceptedReflection = "I feel frustrated and worried. I need a clear update and a shared plan."
    private let message = "Could you send me an update by 3 pm today? If you need more time, let’s agree on a plan together."

    public init(screen: BrandJourneyScreen, linkedContext: Bool = false, updatedSource: Bool = false) {
        self.screen = screen
        self.linkedContext = linkedContext
        self.updatedSource = updatedSource
    }

    private var isPractice: Bool { [.practiceContext, .wording, .practiceDetail].contains(screen) }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left").font(.system(size: 17, weight: .semibold))
                Text(isPractice ? "Practice" : (screen == .entry ? "Journal" : "Today"))
                    .font(BrandDemoFont.font(14, .semibold))
                Spacer()
                Text(screen == .capture ? "Draft" : "Sample")
                    .font(BrandDemoFont.font(12)).foregroundStyle(BrandDemoColor.muted)
            }
            .frame(height: 24).padding(.top, 10).padding(.bottom, 6)

            BrandFixture.eyebrow(linkedContext && screen == .practiceContext
                ? (updatedSource ? "UPDATED LINKED CONTEXT" : "PRACTICE FROM AN ENTRY") : screen.eyebrow)
            BrandFixture.title(screen.title)
            VStack(alignment: .leading, spacing: 12) { content }
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            VStack(spacing: 8) { actions }
                .fixedSize(horizontal: false, vertical: true)
            BrandFixture.footer
        }
        .padding(.horizontal, 24).padding(.vertical, 20)
        .frame(width: 390, height: 844)
        .foregroundStyle(BrandDemoColor.ink).background(BrandDemoColor.ice)
        .clipShape(RoundedRectangle(cornerRadius: 36)).environment(\.colorScheme, .light)
    }

    @ViewBuilder
    private var content: some View {
        switch screen {
        case .capture:
            BrandFixture.detail("What happened, and what matters to you?")
            block("Your words", text: originalWords, minimumHeight: 185)
            HStack(spacing: 8) {
                Image(systemName: "mic").font(.system(size: 14))
                Text("Prefer to speak? Record your words.").font(BrandDemoFont.font(12, .medium))
            }
            .foregroundStyle(BrandDemoColor.blue).padding(.vertical, 4)
            BrandFixture.detail("You can keep just your words. A reflection and next step are optional.", size: 13)
        case .reflection:
            BrandFixture.detail("A suggestion to consider. Change anything that doesn’t fit.")
            block("My words", text: originalWords, edit: "Edit my words")
            block("Suggested reflection", text: "You might feel frustrated and worried. A clear update and a shared plan may help.", edit: "Edit reflection")
            BrandFixture.detail("Your words stay separate from this interpretation.", size: 12)
        case .entry:
            BrandFixture.detail("24 October 2026 · 10:30 am", size: 12)
            block("My original words", text: originalWords)
            block("My reflection", text: acceptedReflection, edit: "Edit reflection")
            VStack(alignment: .leading, spacing: 7) {
                Text("Next step · optional").font(BrandDemoFont.font(13, .semibold))
                Text("No step chosen").font(BrandDemoFont.font(13)).foregroundStyle(BrandDemoColor.muted)
                Text("Add a next step").font(BrandDemoFont.font(12, .semibold)).foregroundStyle(BrandDemoColor.blue)
            }
            .padding(14).frame(maxWidth: .infinity, alignment: .leading)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(BrandDemoColor.blue.opacity(0.13)))
        case .practiceContext:
            BrandFixture.detail(linkedContext
                ? "Only this reflection is carried over. Check it before continuing."
                : "No journal entry needed. What would you like to say?")
            if linkedContext {
                block(updatedSource ? "Updated reflection · The group deadline" : "From · The group deadline",
                      text: updatedSource
                        ? "I feel worried. I need a realistic revised deadline, rather than an update today."
                        : acceptedReflection)
            } else {
                block("The situation", text: "Ask a groupmate for a clear deadline update.", minimumHeight: 55)
            }
            block("My aim", text: updatedSource
                ? "Agree on a revised deadline that works for both of us."
                : "Ask for an update and agree on a realistic plan.")
            block("My draft · optional", text: "Could you let me know where things stand?")
            if updatedSource {
                BrandFixture.detail("Your draft stays here. Earlier wording needs review because the reflection changed.", size: 13)
            }
        case .wording:
            BrandFixture.detail(linkedContext ? "Linked to The group deadline" : "Standalone practice · No journal entry", size: 12)
            block("My aim", text: "Ask for an update and agree on a realistic plan.")
            block("Suggested message", text: message, edit: "Edit message", minimumHeight: 135)
            BrandFixture.detail("One option to work with. Change it until it sounds like you.", size: 13)
            BrandFixture.detail("Copying doesn’t save or send the message.", size: 12)
        case .practiceDetail:
            BrandFixture.detail(linkedContext ? "Source · The group deadline" : "Standalone message · 24 October 2026", size: 12)
            block("My message", text: message, edit: "Edit message", minimumHeight: 135)
            BrandFixture.detail("Saved here for you to revisit. Nothing is sent for you.", size: 13)
        }
    }

    @ViewBuilder
    private var actions: some View {
        switch screen {
        case .capture:
            BrandFixture.action("Review a reflection")
            BrandFixture.action("Save only my words", primary: false)
        case .reflection:
            BrandFixture.action("Save reflection")
            BrandFixture.action("Save only my words", primary: false)
        case .entry:
            BrandFixture.action("Practice from this entry")
            Text("Back to Journal").font(BrandDemoFont.font(14, .semibold))
                .foregroundStyle(BrandDemoColor.blue).frame(maxWidth: .infinity).frame(height: 34)
        case .practiceContext:
            BrandFixture.action(updatedSource ? "Review updated wording" : "Find some words")
            Text("Keep draft").font(BrandDemoFont.font(14, .semibold))
                .foregroundStyle(BrandDemoColor.blue).frame(maxWidth: .infinity).frame(height: 34)
        case .wording:
            BrandFixture.action("Save message")
            BrandFixture.action("Copy message", primary: false)
        case .practiceDetail:
            BrandFixture.action("Copy message")
            Text("Back to Practice").font(BrandDemoFont.font(14, .semibold))
                .foregroundStyle(BrandDemoColor.blue).frame(maxWidth: .infinity).frame(height: 34)
        }
    }

    private func block(_ label: String, text: String, edit: String? = nil, minimumHeight: CGFloat = 0) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label).font(BrandDemoFont.font(13, .semibold))
            Text(text).font(BrandDemoFont.font(15)).lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            if let edit {
                Text(edit).font(BrandDemoFont.font(12, .semibold)).foregroundStyle(BrandDemoColor.blue)
            }
        }
        .frame(maxWidth: .infinity, minHeight: minimumHeight, alignment: .topLeading)
        .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 20))
    }
}

public struct BrandJourneyGallery: View {
    public let screens: [BrandJourneyScreen]
    public let title: String

    public init(screens: [BrandJourneyScreen] = [.capture, .reflection, .entry],
                title: String = "From a moment to a reflection") {
        self.screens = screens
        self.title = title
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            BrandWordmark(size: 30)
            Text(title).font(BrandDemoFont.font(24, .semibold)).tracking(-0.6)
            HStack(alignment: .top, spacing: 24) {
                ForEach(screens) { screen in
                    VStack(alignment: .leading, spacing: 12) {
                        BrandFixture.eyebrow(screen.eyebrow)
                        BrandJourneyPreview(screen: screen)
                    }
                }
            }
            BrandFixture.detail("Brand demo 04 · Static fixtures · No typing, saving or navigation runs", size: 12)
        }
        .padding(32).foregroundStyle(BrandDemoColor.ink).background(.white)
        .environment(\.colorScheme, .light)
    }
}

#Preview("Capture · branded", traits: .sizeThatFitsLayout) { BrandJourneyPreview(screen: .capture) }
#Preview("Reflection · branded", traits: .sizeThatFitsLayout) { BrandJourneyPreview(screen: .reflection) }
#Preview("Saved entry · branded", traits: .sizeThatFitsLayout) { BrandJourneyPreview(screen: .entry) }
#Preview("Reflection journey · branded", traits: .sizeThatFitsLayout) { BrandJourneyGallery() }

public struct BrandLinkedContextGallery: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            BrandWordmark(size: 30)
            Text("The reflection you choose, and the version you review")
                .font(BrandDemoFont.font(21, .semibold)).tracking(-0.5)
            HStack(alignment: .top, spacing: 24) {
                BrandJourneyPreview(screen: .practiceContext, linkedContext: true)
                BrandJourneyPreview(screen: .practiceContext, linkedContext: true, updatedSource: true)
            }
            BrandFixture.detail("Original and changed-source fixtures · Static review only · Earlier wording is not silently reused", size: 12)
        }
        .padding(32).foregroundStyle(BrandDemoColor.ink).background(.white)
        .environment(\.colorScheme, .light)
    }
}

#Preview("Practice context · branded", traits: .sizeThatFitsLayout) { BrandJourneyPreview(screen: .practiceContext) }
#Preview("Wording · branded", traits: .sizeThatFitsLayout) { BrandJourneyPreview(screen: .wording) }
#Preview("Saved message · branded", traits: .sizeThatFitsLayout) { BrandJourneyPreview(screen: .practiceDetail) }
#Preview("Linked context comparison", traits: .sizeThatFitsLayout) { BrandLinkedContextGallery() }
