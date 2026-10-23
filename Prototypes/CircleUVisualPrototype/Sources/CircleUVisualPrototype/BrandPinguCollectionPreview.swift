import SwiftUI

/// Review sheets only. Activity props do not add features, rewards or a profile picker.
public struct BrandPinguCollectionPreview: View {
    public let additionsOnly: Bool
    public init(additionsOnly: Bool = false) { self.additionsOnly = additionsOnly }

    private struct Avatar {
        let name: String
        let label: String
    }

    private let familiar: [Avatar] = [
        .init(name: "BrandAvatar", label: "Journal friend"),
        .init(name: "PinguWelcomeV1", label: "Welcome"),
        .init(name: "PinguThoughtfulV1", label: "Thoughtful"),
        .init(name: "PinguListeningV1", label: "Listening"),
        .init(name: "PinguWritingV1", label: "Writing"),
        .init(name: "PinguReadingV1", label: "Reading"),
        .init(name: "PinguPractisingV1", label: "Practising"),
        .init(name: "PinguStretchingV1", label: "Stretching"),
        .init(name: "PinguQuietBreathV1", label: "Quiet breath")
    ]
    private let additions: [Avatar] = [
        .init(name: "PinguHeartV1", label: "Heart"),
        .init(name: "PinguIceCreamV1", label: "Ice cream"),
        .init(name: "PinguBackpackV1", label: "Backpack"),
        .init(name: "PinguThumbsUpV1", label: "You’ve got this"),
        .init(name: "PinguExplorerV1", label: "Exploring"),
        .init(name: "PinguRunningV1", label: "On the move"),
        .init(name: "PinguMusicV1", label: "Music"),
        .init(name: "PinguLaptopV1", label: "Laptop"),
        .init(name: "PinguGardeningV1", label: "Growing"),
        .init(name: "PinguWarmDrinkV1", label: "Warm drink"),
        .init(name: "PinguSleepingV1", label: "Sleeping"),
        .init(name: "PinguPillowHugV1", label: "Pillow hug")
    ]

    public var body: some View {
        let items = additionsOnly ? additions : familiar + additions
        let columns = additionsOnly ? 4 : 7
        let artSize: CGFloat = additionsOnly ? 180 : 128
        VStack(alignment: .leading, spacing: 24) {
            BrandWordmark(size: 28)
            Text(additionsOnly ? "Twelve more sides of Pingu." : "One Pingu. Twenty-one little moments.")
                .font(BrandDemoFont.font(28, .bold)).tracking(-0.8)
            VStack(spacing: 18) {
                ForEach(0..<(items.count / columns), id: \.self) { row in
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(0..<columns, id: \.self) { column in
                            let avatar = items[row * columns + column]
                            VStack(spacing: 9) {
                                BrandArtwork(name: avatar.name).frame(width: artSize, height: artSize)
                                    .padding(8)
                                    .background(BrandDemoColor.ice, in: RoundedRectangle(cornerRadius: 18))
                                Text(avatar.label).font(BrandDemoFont.font(12, .semibold))
                                    .frame(width: artSize + 16, height: 20)
                            }
                        }
                    }
                }
            }
            Text(additionsOnly ? "Collection 01 · 12 new transparent originals" : "21 separate full-body avatars · Existing originals preserved")
                .font(BrandDemoFont.font(12)).foregroundStyle(BrandDemoColor.muted)
            Text("Artwork candidates · Static poses · No animation or new app behavior")
                .font(BrandDemoFont.font(12)).foregroundStyle(BrandDemoColor.muted)
        }
        .padding(32).foregroundStyle(BrandDemoColor.ink).background(.white)
        .environment(\.colorScheme, .light)
    }
}

#Preview("Pingu collection · all 21", traits: .sizeThatFitsLayout) {
    BrandPinguCollectionPreview()
}
#Preview("Pingu collection · new 12", traits: .sizeThatFitsLayout) {
    BrandPinguCollectionPreview(additionsOnly: true)
}
