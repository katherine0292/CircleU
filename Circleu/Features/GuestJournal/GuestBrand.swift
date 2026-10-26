import CoreText
import SwiftUI
import UIKit

/// The owner-approved preview brand (Plus Jakarta Sans and the blue/ice/ink palette), scoped to
/// the new guest journal screens only; the existing app keeps its own design. Every text style
/// scales with Dynamic Type.
enum GuestBrand {
    static let ink = Color(red: 13 / 255, green: 20 / 255, blue: 33 / 255)
    static let blue = Color(red: 5 / 255, green: 79 / 255, blue: 201 / 255)
    static let ice = Color(red: 245 / 255, green: 250 / 255, blue: 255 / 255)
    /// Secondary text; 6.1:1 on `ice`, 6.4:1 on white.
    static let muted = Color(red: 79 / 255, green: 96 / 255, blue: 119 / 255)
    /// Delete actions; 6.5:1 on `ice`, so it stays readable at footnote size.
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

    /// Navigation titles in the brand font, scaled with Dynamic Type. Only called from the
    /// guest journal, which is the whole interface whenever it runs.
    static func applyNavigationBarFonts() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        if let large = uiFont(size: 34, weight: 700) {
            appearance.largeTitleTextAttributes = [.font: UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: large),
                                                   .foregroundColor: UIColor(ink)]
        }
        if let inline = uiFont(size: 17, weight: 600) {
            appearance.titleTextAttributes = [.font: UIFontMetrics(forTextStyle: .headline).scaledFont(for: inline),
                                              .foregroundColor: UIColor(ink)]
        }
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
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

/// Full-width brand button: filled (primary) or white (secondary), 54 pt tall.
/// A small outlined question chip (Today's starters). At least 44 points tall.
struct GuestChipButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(GuestBrand.font(.subheadline, .semibold))
            .foregroundStyle(GuestBrand.blue)
            .padding(.horizontal, 14)
            .frame(minHeight: 44)
            .background(.white, in: Capsule())
            .overlay(Capsule().stroke(GuestBrand.blue.opacity(0.3), lineWidth: 1))
            .opacity(configuration.isPressed ? 0.75 : 1)
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

struct GuestBrandButtonStyle: ButtonStyle {
    var filled = true
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(GuestBrand.font(.headline, .semibold))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 54)
            .padding(.horizontal, 16)
            .foregroundStyle(filled ? Color.white : GuestBrand.blue)
            .background(filled ? GuestBrand.blue : Color.white, in: RoundedRectangle(cornerRadius: 18))
            .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.45)
            .contentShape(RoundedRectangle(cornerRadius: 18))
    }
}
