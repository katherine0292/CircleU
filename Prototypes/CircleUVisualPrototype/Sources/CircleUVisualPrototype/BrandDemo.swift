import CoreText
import ImageIO
import SwiftUI

/// Process-scoped registration keeps the demo font out of the app and system font library.
public enum BrandDemoFont {
    public static let postScriptName: String = {
        guard let url = Bundle.module.url(forResource: "PlusJakartaSans", withExtension: "ttf"),
              let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor],
              let descriptor = descriptors.first else {
            preconditionFailure("The brand demo requires its bundled Plus Jakarta Sans font.")
        }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        let name = CTFontCopyPostScriptName(CTFontCreateWithFontDescriptor(descriptor, 17, nil)) as String
        let resolved = CTFontCreateWithName(name as CFString, 17, nil)
        precondition(CTFontCopyFamilyName(resolved) as String == "Plus Jakarta Sans", "Unexpected font fallback")
        return name
    }()

    static func font(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .custom(postScriptName, fixedSize: size).weight(weight)
    }
}

/// These exact source colors are scoped to a proposal, not new production tokens.
enum BrandDemoColor {
    static let ink = Color(red: 13/255, green: 20/255, blue: 33/255)
    static let blue = Color(red: 5/255, green: 79/255, blue: 201/255)
    static let ice = Color(red: 245/255, green: 250/255, blue: 255/255)
    static let sky = Color(red: 71/255, green: 199/255, blue: 255/255)
    static let orange = Color(red: 1, green: 133/255, blue: 56/255)
    static let muted = Color(red: 79/255, green: 96/255, blue: 119/255)
}

struct BrandArtwork: View {
    let name: String

    var body: some View {
        if let url = Bundle.module.url(forResource: name, withExtension: "png"),
           let source = CGImageSourceCreateWithURL(url as CFURL, nil),
           let image = CGImageSourceCreateImageAtIndex(source, 0, nil) {
            Image(decorative: image, scale: 1).resizable().scaledToFit()
        } else {
            Text("Missing artwork: \(name)").foregroundStyle(.red)
        }
    }
}

struct BrandWordmark: View {
    var size: CGFloat = 30

    var body: some View {
        HStack(spacing: 6) {
            BrandArtwork(name: "BrandLogo").frame(width: size * 1.55, height: size * 1.55)
            Text("CircleU").font(BrandDemoFont.font(size, .bold)).tracking(-size * 0.04)
        }
        .foregroundStyle(BrandDemoColor.ink)
    }
}

/// A fixed-size visual proposal. Every action and entry is an inert, invented fixture.
public struct BrandTodayPreview: View {
    let practiceArtwork: String

    public init(practiceArtwork: String = "BrandPractice") {
        self.practiceArtwork = practiceArtwork
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                BrandWordmark(size: 23)
                Spacer()
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 20, weight: .medium))
                    .accessibilityLabel("Settings, static preview")
            }
            .padding(.top, 12)

            Text("TODAY").font(BrandDemoFont.font(11, .bold)).tracking(2)
                .foregroundStyle(BrandDemoColor.blue).padding(.top, 30)
            Text("What’s on\nyour mind?")
                .font(BrandDemoFont.font(33, .bold)).tracking(-1.2)
                .lineSpacing(0).padding(.top, 8)
                .fixedSize(horizontal: false, vertical: true)
            Text("Make sense of a moment.\nFind words that feel like you.")
                .font(BrandDemoFont.font(16)).lineSpacing(5)
                .foregroundStyle(BrandDemoColor.muted).padding(.top, 12)
                .fixedSize(horizontal: false, vertical: true)

            BrandArtwork(name: "BrandAvatar")
                .frame(width: 195, height: 195)
                .frame(maxWidth: .infinity).padding(.vertical, 9)

            HStack(spacing: 12) {
                Text("Work through a moment").font(BrandDemoFont.font(16, .semibold))
                Spacer(minLength: 0)
                Image(systemName: "arrow.right").font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(.white).padding(.horizontal, 20).frame(height: 56)
            .background(BrandDemoColor.blue, in: RoundedRectangle(cornerRadius: 18))

            HStack(spacing: 12) {
                BrandArtwork(name: "BrandJournal").frame(width: 45, height: 45)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Continue your draft").font(BrandDemoFont.font(15, .semibold))
                    Text("The group deadline").font(BrandDemoFont.font(13))
                        .foregroundStyle(BrandDemoColor.muted)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .semibold))
            }
            .padding(14).background(.white, in: RoundedRectangle(cornerRadius: 18)).padding(.top, 12)

            Text("Or find your words in Practice.")
                .font(BrandDemoFont.font(13)).foregroundStyle(BrandDemoColor.muted)
                .frame(maxWidth: .infinity).padding(.top, 18)
            Spacer(minLength: 12)

            HStack(spacing: 8) {
                tab("Today", asset: "BrandToday", selected: true)
                tab("Journal", asset: "BrandJournal", selected: false)
                tab("Practice", asset: practiceArtwork, selected: false)
            }
            .padding(8).background(.white, in: RoundedRectangle(cornerRadius: 24))
            Text("BRAND DEMO · STATIC SAMPLE")
                .font(BrandDemoFont.font(9, .medium)).tracking(1)
                .foregroundStyle(BrandDemoColor.muted)
                .frame(maxWidth: .infinity).padding(.top, 13)
        }
        .padding(.horizontal, 24).padding(.bottom, 22)
        .frame(width: 390, height: 844)
        .foregroundStyle(BrandDemoColor.ink).background(BrandDemoColor.ice)
        .clipShape(RoundedRectangle(cornerRadius: 36))
        .environment(\.colorScheme, .light)
    }

    private func tab(_ title: String, asset: String, selected: Bool) -> some View {
        VStack(spacing: 3) {
            BrandArtwork(name: asset).frame(width: 32, height: 32)
            Text(title).font(BrandDemoFont.font(11, selected ? .bold : .medium))
        }
        .frame(maxWidth: .infinity).padding(.vertical, 5)
        .foregroundStyle(selected ? BrandDemoColor.blue : BrandDemoColor.muted)
        .background(selected ? BrandDemoColor.ice : .clear, in: RoundedRectangle(cornerRadius: 17))
    }
}

public struct BrandDemoBoard: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            HStack(alignment: .center) {
                BrandWordmark(size: 36)
                Spacer()
                VStack(alignment: .trailing, spacing: 7) {
                    Text("A LITTLE SPACE. A CLEARER MIND.").font(BrandDemoFont.font(11, .bold)).tracking(2)
                    Text("Brand exploration 01 / October 2026").font(BrandDemoFont.font(12))
                        .foregroundStyle(BrandDemoColor.muted)
                }
            }
            HStack(alignment: .top, spacing: 32) {
                VStack(alignment: .leading, spacing: 22) {
                    hero
                    icons
                    typography
                    palette
                }
                .frame(width: 650)
                VStack(alignment: .leading, spacing: 12) {
                    label("04 / IN CONTEXT")
                    BrandTodayPreview()
                }
            }
            HStack {
                Text("Pingu, reimagined. Smooth shapes. Gentle depth. Familiar blue.")
                Spacer()
                Text("PROPOSED IDENTITY · SAMPLE CONTENT")
            }
            .font(BrandDemoFont.font(10, .medium)).foregroundStyle(BrandDemoColor.muted)
        }
        .padding(40).foregroundStyle(BrandDemoColor.ink)
        .background(Color.white).environment(\.colorScheme, .light)
    }

    private var hero: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 16) {
                label("01 / OUR COMPANION")
                Text("A familiar face.\nA fresh start.")
                    .font(BrandDemoFont.font(37, .bold)).tracking(-1.4)
                Text("Same scarf. Same blue journal.\nA calmer, cleaner Pingu.")
                    .font(BrandDemoFont.font(15)).lineSpacing(5)
                    .foregroundStyle(BrandDemoColor.muted)
            }
            BrandArtwork(name: "BrandAvatar").frame(width: 260, height: 290)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24).background(BrandDemoColor.ice, in: RoundedRectangle(cornerRadius: 28))
    }

    private var icons: some View {
        VStack(alignment: .leading, spacing: 8) {
            label("02 / ONE ILLUSTRATION FAMILY")
            HStack(spacing: 16) {
                icon("Today", "BrandToday", "A new perspective")
                icon("Journal", "BrandJournal", "Your words, revisited")
                icon("Practice", "BrandPractice", "Room to find the words")
            }
        }
    }

    private func icon(_ title: String, _ asset: String, _ caption: String) -> some View {
        VStack(spacing: 5) {
            BrandArtwork(name: asset).frame(width: 90, height: 80)
            Text(title).font(BrandDemoFont.font(15, .semibold))
            Text(caption).font(BrandDemoFont.font(10)).foregroundStyle(BrandDemoColor.muted)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 12)
        .background(BrandDemoColor.ice, in: RoundedRectangle(cornerRadius: 20))
    }

    private var typography: some View {
        VStack(alignment: .leading, spacing: 11) {
            label("03 / PLUS JAKARTA SANS")
            HStack(alignment: .firstTextBaseline) {
                Text("Words with warmth.").font(BrandDemoFont.font(30, .semibold)).tracking(-0.8)
                Spacer()
                Text("Aa").font(BrandDemoFont.font(38, .bold))
            }
            Text("“I felt unheard. I’d like us to agree on a plan.”")
                .font(BrandDemoFont.font(17)).lineSpacing(4)
            Text("Regular 400 / Semibold 600 / Bold 700    ·    Aa–Zz 0123456789")
                .font(BrandDemoFont.font(11)).foregroundStyle(BrandDemoColor.muted)
        }
        .padding(22).overlay(RoundedRectangle(cornerRadius: 22).stroke(BrandDemoColor.ink.opacity(0.1)))
    }

    private var palette: some View {
        HStack(spacing: 10) {
            swatch("Action", "#054FC9", BrandDemoColor.blue)
            swatch("Ink", "#0D1421", BrandDemoColor.ink)
            swatch("Ice", "#F5FAFF", BrandDemoColor.ice)
            swatch("Sky", "#47C7FF", BrandDemoColor.sky)
            swatch("Warmth", "#FF8538", BrandDemoColor.orange)
        }
    }

    private func swatch(_ name: String, _ hex: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            RoundedRectangle(cornerRadius: 10).fill(color).frame(height: 36)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(BrandDemoColor.ink.opacity(0.07)))
            Text(name).font(BrandDemoFont.font(11, .semibold))
            Text(hex).font(BrandDemoFont.font(10)).foregroundStyle(BrandDemoColor.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func label(_ text: String) -> some View {
        Text(text).font(BrandDemoFont.font(10, .bold)).tracking(1.6).foregroundStyle(BrandDemoColor.blue)
    }
}

#Preview("Brand demo 01", traits: .sizeThatFitsLayout) { BrandDemoBoard() }
#Preview("Brand Today", traits: .sizeThatFitsLayout) { BrandTodayPreview() }
