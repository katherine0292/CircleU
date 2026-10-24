import SwiftUI

public struct PreviewGallery: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CircleU · Draft 02")
                .font(.system(size: 26, weight: .bold, design: .rounded))
            Text("SwiftUI design previews · sample content · actions are static")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(.secondary)
            HStack(alignment: .top, spacing: 24) {
                ForEach(PrototypeScreen.allCases) { screen in
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(screen.rawValue) · Figma \(screen.nodeID)")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                        PrototypeScreenView(screen: screen)
                            .frame(width: 390, height: 844)
                    }
                }
            }
            Text("Native rounded typography; draft colors and copy. macOS SwiftUI renders—not Simulator or app screenshots.")
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .background(.white)
        .environment(\.colorScheme, .light)
    }
}

#Preview("Today", traits: .fixedLayout(width: 390, height: 844)) {
    PrototypeScreenView(screen: .today)
}

#Preview("Journal", traits: .fixedLayout(width: 390, height: 844)) {
    PrototypeScreenView(screen: .journal)
}

#Preview("Practice", traits: .fixedLayout(width: 390, height: 844)) {
    PrototypeScreenView(screen: .practice)
}

#Preview("Compare all three", traits: .sizeThatFitsLayout) {
    PreviewGallery()
}

#Preview("Today · compact width", traits: .fixedLayout(width: 320, height: 844)) {
    PrototypeScreenView(screen: .today)
}
