import SwiftUI

/// Draft-only color resources, matching the Figma research variables.
enum DraftColor {
    static let background = Color("DraftBackground", bundle: .module)
    static let surface = Color("DraftSurface", bundle: .module)
    static let text = Color("DraftText", bundle: .module)
    static let muted = Color("DraftMuted", bundle: .module)
    static let accent = Color("DraftAccent", bundle: .module)
    static let border = Color("DraftBorder", bundle: .module)
    static let selected = Color("DraftSelected", bundle: .module)
}

/// A static design board, not an application screen with working data actions.
public struct PrototypeScreenView: View {
    public let screen: PrototypeScreen

    public init(screen: PrototypeScreen) { self.screen = screen }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CircleU")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(DraftColor.muted)
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 17)

            Text(screen.eyebrow)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(DraftColor.accent)
                .frame(height: 17)

            Text(screen.title)
                .font(.system(size: 29, weight: .bold, design: .rounded))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            // Static boards use SwiftUI layout directly so ImageRenderer includes all content.
            Group {
                VStack(alignment: .leading, spacing: 12) {
                    Text(screen.introduction)
                        .font(.system(size: 16, design: .rounded))
                        .lineSpacing(4)
                        .foregroundStyle(DraftColor.muted)
                        .fixedSize(horizontal: false, vertical: true)

                    DraftContentCard(title: screen.cardTitle, text: screen.cardBody)

                    if screen == .journal {
                        Text("Sample history. Open an entry to review its content and available actions.")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .lineSpacing(3)
                            .foregroundStyle(DraftColor.muted)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxHeight: .infinity, alignment: .top)

            VStack(spacing: 8) {
                ForEach(screen.actions) { action in DraftActionLabel(action: action) }
            }

            // These are static Figma tab representations. Real navigation stays in Figma.
            HStack(spacing: 12) {
                ForEach(PrototypeScreen.allCases) { tab in
                    Text(tab.rawValue)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(tab == screen ? DraftColor.accent : DraftColor.muted)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(tab == screen ? DraftColor.selected : DraftColor.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }

            Text("DRAFT 02 · Sample content and simulated actions")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(DraftColor.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .foregroundStyle(DraftColor.text)
        .background(DraftColor.background)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .environment(\.colorScheme, .light)
        .accessibilityLabel("\(screen.rawValue), static design preview")
    }
}

struct DraftContentCard: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 19, weight: .bold, design: .rounded))
            Text(text)
                .font(.system(size: 16, design: .rounded))
                .lineSpacing(4)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(DraftColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(DraftColor.border, lineWidth: 1))
    }
}

struct DraftActionLabel: View {
    let action: PrototypeAction

    var body: some View {
        Text(action.label)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var foreground: Color {
        switch action.style {
        case .primary: .white
        case .secondary: DraftColor.accent
        case .quiet: DraftColor.muted
        }
    }

    private var background: Color {
        switch action.style {
        case .primary: DraftColor.accent
        case .secondary: DraftColor.surface
        case .quiet: DraftColor.background
        }
    }
}
