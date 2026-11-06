import CoreText
import SwiftUI
import UIKit

/// The owner-approved preview brand (Plus Jakarta Sans and the blue/ice/ink palette), scoped to
/// the new guest journal screens only; the existing app keeps its own design. Every text style
/// scales with Dynamic Type.
enum GuestBrand {
    // Warm palette from Podo the otter (6 November 2026); the names are kept so every screen
    // moves together. Contrast is measured on `ice` (now oat).
    /// Text: cocoa ink, 13:1.
    static let ink = GuestWarm.ink
    /// The accent (was blue): cocoa, 7.8:1; white text on it 8.9:1.
    static let blue = GuestWarm.cocoa
    /// The page colour (was ice): oat.
    static let ice = GuestWarm.oat
    /// A soft sage wash behind art or a selected choice. Decorative only, never behind small text.
    static let wash = GuestWarm.sageWash
    /// Secondary text; 5.6:1 on oat.
    static let muted = GuestWarm.muted
    /// Delete actions; 5.9:1 on oat, so it stays readable at footnote size.
    static let danger = Color(red: 176 / 255, green: 32 / 255, blue: 32 / 255)

    /// Plus Jakarta Sans (SIL Open Font License, bundled with its licence), registered for this
    /// process the first time it's needed. Falls back to the system font if it can't load.
    private static let fontName: String? = {
        guard let url = Bundle.main.url(forResource: "PlusJakartaSans", withExtension: "ttf"),
              let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor],
              let descriptor = descriptors.first else { return nil }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil) // Already-registered is fine.
        let name = CTFontCopyPostScriptName(CTFontCreateWithFontDescriptor(descriptor, 17, nil)) as String
        // Only use the name if it now resolves to the bundled family, not a fallback font.
        let resolved = CTFontCreateWithName(name as CFString, 17, nil)
        return CTFontCopyFamilyName(resolved) as String == "Plus Jakarta Sans" ? name : nil
    }()

    /// Whether the bundled brand font loaded (tests; the UI falls back to the system font).
    static var isBrandFontAvailable: Bool { fontName != nil }

    /// A brand font that scales with Dynamic Type like `style`.
    static func font(_ style: Font.TextStyle, _ weight: Font.Weight = .regular) -> Font {
        guard let fontName else { return .system(style).weight(weight) }
        return .custom(fontName, size: baseSize(for: style), relativeTo: style).weight(weight)
    }

    static func font(size: CGFloat, relativeTo style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        guard let fontName else { return .system(style).weight(weight) }
        return .custom(fontName, size: size, relativeTo: style).weight(weight)
    }

    /// Navigation titles in the brand font, scaled with Dynamic Type. Only called from the
    /// guest journal, which is the whole interface whenever it runs.
    static func applyNavigationBarFonts() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        if let large = roundedFont(size: 34, weight: .bold) {
            appearance.largeTitleTextAttributes = [.font: UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: large),
                                                   .foregroundColor: UIColor(ink)]
        }
        if let inline = roundedFont(size: 17, weight: .semibold) {
            appearance.titleTextAttributes = [.font: UIFontMetrics(forTextStyle: .headline).scaledFont(for: inline),
                                              .foregroundColor: UIColor(ink)]
        }
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    /// The rounded system font used for titles (matches `GuestWarm.heading`).
    private static func roundedFont(size: CGFloat, weight: UIFont.Weight) -> UIFont? {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        return base.fontDescriptor.withDesign(.rounded).map { UIFont(descriptor: $0, size: size) } ?? base
    }

    /// A UIKit brand font at a weight on the variable font's `wght` axis (200–800). Without an
    /// explicit value, the instance this descriptor selects renders ExtraLight.
    private static func uiFont(size: CGFloat, weight: Int) -> UIFont? {
        guard let fontName else { return nil }
        let wghtAxis = 0x7767_6874 // 'wght'
        let descriptor = UIFontDescriptor(fontAttributes: [
            .name: fontName,
            UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): [wghtAxis: weight],
        ])
        return UIFont(descriptor: descriptor, size: size)
    }

    private static func baseSize(for style: Font.TextStyle) -> CGFloat {
        switch style {
        case .largeTitle: 34
        case .title: 28
        case .title2: 22
        case .title3: 20
        case .headline, .body: 17
        case .callout: 16
        case .subheadline: 15
        case .footnote: 13
        case .caption: 12
        case .caption2: 11
        @unknown default: 17
        }
    }
}

/// A small outlined question chip (Today's starters). At least 44 points tall.
struct GuestChipButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(GuestBrand.font(.subheadline, .semibold))
            .foregroundStyle(GuestBrand.blue)
            .padding(.horizontal, 14)
            .frame(minHeight: 44)
            .guestPill(in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .contentShape(Capsule())
    }
}

/// Lays chips out in rows, wrapping to the next row when one doesn't fit (larger text too).
struct GuestChipFlow: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(width: proposal.width ?? .infinity, subviews: subviews)
        let height = rows.map(\.height).reduce(0, +) + spacing * CGFloat(max(rows.count - 1, 0))
        let width = rows.map(\.width).max() ?? 0
        return CGSize(width: proposal.width ?? width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in arrange(width: bounds.width, subviews: subviews) {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(ProposedViewSize(width: bounds.width, height: nil))
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: min(size.width, bounds.width), height: size.height))
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row { var indices: [Int] = []; var width: CGFloat = 0; var height: CGFloat = 0 }

    private func arrange(width: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = [Row()]
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(ProposedViewSize(width: width, height: nil))
            let needed = rows[rows.count - 1].indices.isEmpty ? size.width : rows[rows.count - 1].width + spacing + size.width
            if needed > width, !rows[rows.count - 1].indices.isEmpty {
                rows.append(Row())
            }
            var row = rows[rows.count - 1]
            row.width = row.indices.isEmpty ? size.width : row.width + spacing + size.width
            row.height = max(row.height, size.height)
            row.indices.append(index)
            rows[rows.count - 1] = row
        }
        return rows.filter { !$0.indices.isEmpty }
    }
}

/// Full-width brand button: filled cocoa (primary) or glass (secondary), 54 pt tall.
struct GuestBrandButtonStyle: ButtonStyle {
    var filled = true

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        if filled {
            GuestCocoaButtonStyle().makeBody(configuration: configuration)
        } else {
            GuestGlassButtonStyle().makeBody(configuration: configuration)
        }
    }
}
