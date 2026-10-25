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
    public let iconLed: Bool
    private let originalWords = "My groupmate missed our deadline. I’m worried we won’t finish in time."
    private let acceptedReflection = "I feel frustrated and worried. I need a clear update and a shared plan."
    private let message = "Could you send me an update by 3 pm today? If you need more time, let’s agree on a plan together."

    public init(screen: BrandJourneyScreen, linkedContext: Bool = false, updatedSource: Bool = false,
                iconLed: Bool = false) {
        self.screen = screen
        self.linkedContext = linkedContext
        self.updatedSource = updatedSource
        self.iconLed = iconLed
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

            if iconLed {
                HStack(spacing: 12) {
                    symbol(screenSymbol, size: 21)
                        .frame(width: 46, height: 46).background(.white, in: RoundedRectangle(cornerRadius: 16))
                    Text(compactTitle).font(BrandDemoFont.font(27, .bold)).tracking(-0.8)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.bottom, 8)
            } else {
                // Review labels (screen.eyebrow) are captions outside the phone frame, so the
                // screen itself reads like the app; the Sample chip and footer still mark it.
                BrandFixture.title(screen.title).padding(.top, 8)
            }
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
            BrandFixture.detail("What happened?")
            block("Your words", text: originalWords, minimumHeight: 185)
            if iconLed {
                HStack(spacing: 10) {
                    chip("Write", symbol: "pencil")
                    chip("Voice", symbol: "mic")
                    Spacer()
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "mic").font(.system(size: 14))
                    Text("Record").font(BrandDemoFont.font(12, .medium))
                }
                .foregroundStyle(BrandDemoColor.blue).padding(.vertical, 4)
            }
        case .reflection:
            if !iconLed { BrandFixture.detail("A suggestion to consider. Change anything that doesn’t fit.") }
            block("My words", text: originalWords, edit: "Edit my words")
            block("Suggested reflection", text: "You might feel frustrated and worried. A clear update and a shared plan may help.", edit: "Edit reflection")
        case .entry:
            if iconLed { chip("Saved · 24 Oct · 10:30 am", symbol: "checkmark.circle") }
            else { BrandFixture.detail("24 October 2026 · 10:30 am", size: 12) }
            block("My original words", text: originalWords)
            block("My reflection", text: acceptedReflection, edit: "Edit reflection")
            if iconLed {
                HStack(spacing: 9) {
                    symbol("plus.circle")
                    Text("Add a next step").font(BrandDemoFont.font(14, .semibold))
                    Spacer()
                    Text("Optional").font(BrandDemoFont.font(11)).foregroundStyle(BrandDemoColor.muted)
                }
                .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 18))
            } else {
                Text("Add a next step").font(BrandDemoFont.font(14, .semibold)).foregroundStyle(BrandDemoColor.blue)
                    .padding(14).frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(BrandDemoColor.blue.opacity(0.13)))
            }
        case .practiceContext:
            if iconLed {
                chip(linkedContext ? (updatedSource ? "Source updated" : "From your reflection") : "No journal entry needed",
                     symbol: linkedContext ? "link" : "bubble.left")
            } else {
                BrandFixture.detail(linkedContext
                    ? "Only this reflection is carried over."
                    : "What would you like to say?")
            }
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
                if iconLed { note("Draft kept. Review earlier wording.", symbol: "exclamationmark.circle") }
                else { BrandFixture.detail("Draft kept. The reflection changed, so review the wording.", size: 13) }
            }
        case .wording:
            if iconLed { chip(linkedContext ? "From The group deadline" : "Standalone", symbol: linkedContext ? "link" : "bubble.left") }
            else { BrandFixture.detail(linkedContext ? "Linked to The group deadline" : "Standalone practice · No journal entry", size: 12) }
            block("My aim", text: "Ask for an update and agree on a realistic plan.")
            block("Suggested message", text: message, edit: "Edit message", minimumHeight: 135)
            if iconLed { note("Copy won’t save or send.", symbol: "doc.on.doc") }
            else {
                BrandFixture.detail("Copying won’t save or send it.", size: 13)
            }
        case .practiceDetail:
            if iconLed { chip(linkedContext ? "From The group deadline" : "24 Oct · Standalone", symbol: linkedContext ? "link" : "clock") }
            else { BrandFixture.detail(linkedContext ? "Source · The group deadline" : "Standalone message · 24 October 2026", size: 12) }
            block("My message", text: message, edit: "Edit message", minimumHeight: 135)
            if iconLed { note("Saved · Not sent", symbol: "checkmark.circle") }
            else { BrandFixture.detail("Saved · not sent", size: 13) }
        }
    }

    @ViewBuilder
    private var actions: some View {
        switch screen {
        case .capture:
            action(iconLed ? "Review reflection" : "Review a reflection", symbol: "sparkles")
            action("Save only my words", symbol: "square.and.arrow.down", primary: false)
        case .reflection:
            action("Save reflection", symbol: "checkmark")
            action("Save only my words", symbol: "square.and.arrow.down", primary: false)
        case .entry:
            action("Practice from this entry", symbol: "bubble.left.and.bubble.right")
        case .practiceContext:
            action(updatedSource ? "Review updated wording" : "Find some words", symbol: updatedSource ? "arrow.clockwise" : "text.bubble")
            Text("Keep draft").font(BrandDemoFont.font(14, .semibold))
                .foregroundStyle(BrandDemoColor.blue).frame(maxWidth: .infinity).frame(height: 34)
        case .wording:
            action("Save message", symbol: "checkmark")
            action("Copy message", symbol: "doc.on.doc", primary: false)
        case .practiceDetail:
            action("Copy message", symbol: "doc.on.doc")
        }
    }

    private func block(_ label: String, text: String, edit: String? = nil, minimumHeight: CGFloat = 0) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if iconLed {
                HStack(spacing: 8) {
                    symbol(blockSymbol(label))
                    Text(label).font(BrandDemoFont.font(13, .semibold))
                    Spacer(minLength: 0)
                    if let edit {
                        Image(systemName: "pencil").font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(BrandDemoColor.blue).frame(width: 32, height: 32)
                            .background(BrandDemoColor.ice, in: Circle()).accessibilityLabel(edit)
                    }
                }
            } else { Text(label).font(BrandDemoFont.font(13, .semibold)) }
            Text(text).font(BrandDemoFont.font(15)).lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
            if let edit, !iconLed {
                Text(edit).font(BrandDemoFont.font(12, .semibold)).foregroundStyle(BrandDemoColor.blue)
            }
        }
        .frame(maxWidth: .infinity, minHeight: minimumHeight, alignment: .topLeading)
        .padding(16).background(.white, in: RoundedRectangle(cornerRadius: 20))
    }

    private var compactTitle: String {
        switch screen {
        case .capture: "Your moment"
        case .reflection: "Your reflection"
        case .entry: "The group\ndeadline"
        case .practiceContext: "Find your words"
        case .wording: "Try this wording"
        case .practiceDetail: "A deadline\nupdate"
        }
    }

    private var screenSymbol: String {
        switch screen {
        case .capture: "square.and.pencil"
        case .reflection: "sparkles"
        case .entry: "book.closed"
        case .practiceContext: "bubble.left.and.bubble.right"
        case .wording: "text.bubble"
        case .practiceDetail: "bubble.left"
        }
    }

    private func blockSymbol(_ label: String) -> String {
        if label.contains("aim") { return "target" }
        if label.contains("draft") { return "pencil" }
        if label.contains("message") { return "bubble.left" }
        if label.contains("reflection") || label.hasPrefix("From") { return "sparkles" }
        return "quote.opening"
    }

    private func symbol(_ name: String, size: CGFloat = 15) -> some View {
        Image(systemName: name).font(.system(size: size, weight: .medium, design: .rounded))
            .foregroundStyle(BrandDemoColor.blue).accessibilityHidden(true)
    }

    private func chip(_ title: String, symbol name: String) -> some View {
        HStack(spacing: 6) {
            symbol(name, size: 12)
            Text(title).font(BrandDemoFont.font(11, .medium))
        }
        .foregroundStyle(BrandDemoColor.muted).padding(.horizontal, 11).padding(.vertical, 8)
        .background(.white, in: Capsule())
    }

    private func note(_ title: String, symbol name: String) -> some View {
        HStack(spacing: 7) {
            symbol(name, size: 13)
            Text(title).font(BrandDemoFont.font(12)).foregroundStyle(BrandDemoColor.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private func action(_ title: String, symbol name: String, primary: Bool = true) -> some View {
        if iconLed {
            HStack(spacing: 9) {
                Image(systemName: name).font(.system(size: 16, weight: .medium, design: .rounded)).accessibilityHidden(true)
                Text(title).font(BrandDemoFont.font(16, .semibold))
            }
            .frame(maxWidth: .infinity).frame(height: 54)
            .foregroundStyle(primary ? .white : BrandDemoColor.blue)
            .background(primary ? BrandDemoColor.blue : .white, in: RoundedRectangle(cornerRadius: 17))
        } else { BrandFixture.action(title, primary: primary) }
    }
}

public struct BrandJourneyGallery: View {
    public let screens: [BrandJourneyScreen]
    public let title: String
    public let iconLed: Bool

    public init(screens: [BrandJourneyScreen] = [.capture, .reflection, .entry],
                title: String = "From a moment to a reflection", iconLed: Bool = false) {
        self.screens = screens
        self.title = title
        self.iconLed = iconLed
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            BrandWordmark(size: 30)
            Text(title).font(BrandDemoFont.font(24, .semibold)).tracking(-0.6)
            HStack(alignment: .top, spacing: 24) {
                ForEach(screens) { screen in
                    VStack(alignment: .leading, spacing: 12) {
                        BrandFixture.eyebrow(screen.eyebrow)
                        BrandJourneyPreview(screen: screen, iconLed: iconLed)
                    }
                }
            }
            BrandFixture.detail("Brand demo \(iconLed ? "05" : "04") · Static fixtures · No typing, saving or navigation runs", size: 12)
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
    public let iconLed: Bool
    public init(iconLed: Bool = false) { self.iconLed = iconLed }

    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            BrandWordmark(size: 30)
            Text("The reflection you choose, and the version you review")
                .font(BrandDemoFont.font(21, .semibold)).tracking(-0.5)
            HStack(alignment: .top, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    BrandFixture.eyebrow("PRACTICE FROM AN ENTRY")
                    BrandJourneyPreview(screen: .practiceContext, linkedContext: true, iconLed: iconLed)
                }
                VStack(alignment: .leading, spacing: 12) {
                    BrandFixture.eyebrow("UPDATED LINKED CONTEXT")
                    BrandJourneyPreview(screen: .practiceContext, linkedContext: true, updatedSource: true, iconLed: iconLed)
                }
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
#Preview("Reflection · rounded icons", traits: .sizeThatFitsLayout) { BrandJourneyGallery(iconLed: true) }
#Preview("Practice · rounded icons", traits: .sizeThatFitsLayout) {
    BrandJourneyGallery(screens: [.practiceContext, .wording, .practiceDetail], title: "Find your words", iconLed: true)
}
