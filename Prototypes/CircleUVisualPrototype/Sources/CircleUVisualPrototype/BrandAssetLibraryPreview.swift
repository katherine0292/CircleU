import SwiftUI

/// A static catalog of versioned artwork candidates, separate from app screens.
public struct BrandAssetLibraryPreview: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            BrandWordmark(size: 30)
            Text("More Pingu. One familiar style.")
                .font(BrandDemoFont.font(28, .bold)).tracking(-0.8)
            Text("AVATAR POSES").font(BrandDemoFont.font(12, .bold))
                .tracking(1.6).foregroundStyle(BrandDemoColor.blue)
            HStack(spacing: 20) {
                avatar("PinguWelcomeV1", label: "Welcome", use: "A gentle hello")
                avatar("PinguThoughtfulV1", label: "Thoughtful", use: "Room to reflect")
                avatar("PinguListeningV1", label: "Listening", use: "A quiet companion")
            }
            Text("ILLUSTRATED BRAND ICONS").font(BrandDemoFont.font(12, .bold))
                .tracking(1.6).foregroundStyle(BrandDemoColor.blue)
            HStack(alignment: .top, spacing: 16) {
                icon("BrandReflectionV1", label: "Reflection")
                icon("BrandFeelingsV1", label: "Feelings")
                icon("BrandNextStepV1", label: "Next step")
                icon("BrandPrivacyV1", label: "Privacy")
            }
            Text("32 / 48 pt specimens · Light and dark surfaces · Same transparent artwork")
                .font(BrandDemoFont.font(12)).foregroundStyle(BrandDemoColor.muted)
            Text("Asset expansion 01 · Review candidates · Native symbols remain for functional controls")
                .font(BrandDemoFont.font(12)).foregroundStyle(BrandDemoColor.muted)
        }
        .padding(32).foregroundStyle(BrandDemoColor.ink).background(.white)
        .environment(\.colorScheme, .light)
    }

    private func avatar(_ name: String, label: String, use: String) -> some View {
        VStack(spacing: 10) {
            BrandArtwork(name: name).frame(width: 220, height: 220)
                .padding(12).background(BrandDemoColor.ice, in: RoundedRectangle(cornerRadius: 24))
            Text(label).font(BrandDemoFont.font(17, .semibold))
            Text(use).font(BrandDemoFont.font(13)).foregroundStyle(BrandDemoColor.muted)
        }
    }

    private func icon(_ name: String, label: String) -> some View {
        VStack(spacing: 12) {
            BrandArtwork(name: name).frame(width: 148, height: 148)
                .padding(16).background(BrandDemoColor.ice, in: RoundedRectangle(cornerRadius: 22))
            Text(label).font(BrandDemoFont.font(16, .semibold))
            HStack(spacing: 12) {
                BrandArtwork(name: name).frame(width: 32, height: 32)
                BrandArtwork(name: name).frame(width: 48, height: 48)
            }
            .frame(width: 180, height: 64).background(BrandDemoColor.ice, in: RoundedRectangle(cornerRadius: 14))
            HStack(spacing: 12) {
                BrandArtwork(name: name).frame(width: 32, height: 32)
                BrandArtwork(name: name).frame(width: 48, height: 48)
            }
            .frame(width: 180, height: 64).background(BrandDemoColor.ink, in: RoundedRectangle(cornerRadius: 14))
        }
    }
}

#Preview("Pingu and illustrated icon library", traits: .sizeThatFitsLayout) {
    BrandAssetLibraryPreview()
}
