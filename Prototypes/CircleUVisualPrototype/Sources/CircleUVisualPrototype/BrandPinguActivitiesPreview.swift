import SwiftUI

/// Static activity artwork; these poses are not a frame sequence or new app features.
public struct BrandPinguActivitiesPreview: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            BrandWordmark(size: 30)
            Text("Pingu, in everyday moments.")
                .font(BrandDemoFont.font(28, .bold)).tracking(-0.8)
            HStack(alignment: .top, spacing: 20) {
                card("BrandAvatar", title: "Our familiar Pingu", detail: "Existing reference")
                card("PinguWritingV1", title: "Writing", detail: "A moment for your words")
                card("PinguReadingV1", title: "Reading", detail: "Revisit a saved moment")
            }
            HStack(alignment: .top, spacing: 20) {
                card("PinguPractisingV1", title: "Practising", detail: "Finding words to say")
                card("PinguStretchingV1", title: "Stretching", detail: "A gentle pause")
                card("PinguQuietBreathV1", title: "Quiet breath", detail: "A little room to settle")
            }
            Text("Activity set 01 · Transparent originals · Same scarf, face and softly shaded style")
                .font(BrandDemoFont.font(12)).foregroundStyle(BrandDemoColor.muted)
            Text("Static artwork candidates · No new breathing, exercise or animation behavior")
                .font(BrandDemoFont.font(12)).foregroundStyle(BrandDemoColor.muted)
        }
        .padding(32).foregroundStyle(BrandDemoColor.ink).background(.white)
        .environment(\.colorScheme, .light)
    }

    private func card(_ name: String, title: String, detail: String) -> some View {
        VStack(spacing: 10) {
            BrandArtwork(name: name).frame(width: 220, height: 220)
                .padding(12).background(BrandDemoColor.ice, in: RoundedRectangle(cornerRadius: 24))
            Text(title).font(BrandDemoFont.font(17, .semibold))
            Text(detail).font(BrandDemoFont.font(12)).foregroundStyle(BrandDemoColor.muted)
        }
    }
}

#Preview("Pingu activities", traits: .sizeThatFitsLayout) {
    BrandPinguActivitiesPreview()
}
