import SwiftUI

/// A native-rendered comparison, using the existing logo and system glyphs unchanged.
public struct IconDirectionPreview: View {
    private let icons: [(label: String, symbol: String)] = [
        ("Today", "sun.max"), ("Journal", "book.closed"),
        ("Practice", "bubble.left.and.bubble.right"), ("Calm", "leaf"),
        ("Tender", "heart"), ("Resilient", "water.waves"),
        ("Brave", "shield"), ("Proud", "star")
    ]

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            HStack(spacing: 20) {
                Image("ExistingAppIcon", bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 104, height: 104)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                VStack(alignment: .leading, spacing: 4) {
                    Text("CircleU")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                    Text("Rounded outlines · existing logo · native typography")
                        .font(.system(size: 17, design: .rounded))
                        .foregroundStyle(DraftColor.muted)
                    Text("DESIGN COMPARISON 02 · No production changes")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(DraftColor.accent)
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 18) {
                sectionTitle("Simple icons, familiar meanings")
                HStack(spacing: 12) {
                    ForEach(icons, id: \.label) { icon in
                        VStack(spacing: 14) {
                            Image(systemName: icon.symbol)
                                .font(.system(size: 32, weight: .regular))
                                .frame(width: 64, height: 52)
                                .foregroundStyle(DraftColor.text)
                            Text(icon.label)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                Divider()
                HStack(spacing: 16) {
                    Text("24 pt check")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                    ForEach(icons, id: \.label) { icon in
                        Image(systemName: icon.symbol)
                            .font(.system(size: 24, weight: .regular))
                            .frame(width: 36, height: 32)
                    }
                    Spacer()
                    Label("Selected", systemImage: "book.closed")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(DraftColor.accent)
                }
                .foregroundStyle(DraftColor.muted)
            }
            .padding(24)
            .background(.white, in: RoundedRectangle(cornerRadius: 24))

            VStack(alignment: .leading, spacing: 14) {
                sectionTitle("Typography next to the logo")
                HStack(alignment: .top, spacing: 20) {
                    typeSample(label: "A · Keep rounded throughout", bodyDesign: .rounded)
                    typeSample(label: "B · Rounded title, standard body", bodyDesign: .default)
                }
            }

            HStack(alignment: .top, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    sectionTitle("Keep the brand character")
                    Text("Original penguin mark + soft letterforms.\nPingu illustrations remain on welcome and empty states.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(DraftColor.muted)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 8) {
                    sectionTitle("Keep controls quiet")
                    Text("One icon weight, labels, blue selection.\nNo emoji, extra shading or decorative outlines.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundStyle(DraftColor.muted)
                }
            }
            Text("Actual SwiftUI fonts and SF Symbols · Existing PinguLight image reused unchanged · macOS design render")
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(DraftColor.muted)
        }
        .padding(32)
        .frame(width: 1040)
        .foregroundStyle(DraftColor.text)
        .background(DraftColor.background)
        .environment(\.colorScheme, .light)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title).font(.system(size: 19, weight: .semibold, design: .rounded))
    }

    private func typeSample(label: String, bodyDesign: Font.Design) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(DraftColor.accent)
            Text("Find words that fit you.")
                .font(.system(size: 27, weight: .semibold, design: .rounded))
            Text("I felt worried when our plans changed. I’d like to understand what happened and agree on a next step together.")
                .font(.system(size: 17, weight: .regular, design: bodyDesign))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
            Text("Save reflection")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(DraftColor.accent, in: RoundedRectangle(cornerRadius: 14))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(.white, in: RoundedRectangle(cornerRadius: 24))
    }
}

#Preview("Outline icons + logo + typography", traits: .sizeThatFitsLayout) {
    IconDirectionPreview()
}
