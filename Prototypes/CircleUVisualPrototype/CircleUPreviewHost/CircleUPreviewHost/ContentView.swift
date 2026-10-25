import SwiftUI
import CircleUVisualPrototype

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Group {
                if let board = launchArgument("--board") {
                    boardView(board)
                } else {
                    BrandOnboardingPreview(initialScreen: launchValue("--screen", default: .logIn),
                                           recoveryScreen: launchValue("--recovery-screen", default: .logIn),
                                           recoveryScenario: launchValue("--scenario", default: .available))
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    /// Static Today/Journal/Practice boards for review and audits, e.g. `--board wording`
    /// or `--board edit-reflection`.
    /// They are fixed-size 390 × 844 specimens; nothing on them is interactive.
    @ViewBuilder private func boardView(_ name: String) -> some View {
        Group {
            if let hub = PrototypeScreen.allCases.first(where: { $0.rawValue.lowercased() == name }) {
                BrandHubPreview(screen: hub)
            } else if let journey = BrandJourneyScreen(rawValue: name) {
                BrandJourneyPreview(screen: journey)
            } else if name.hasPrefix("edit-"), let kind = EditorPreviewKind(rawValue: String(name.dropFirst(5))) {
                BrandEditorPreview(kind: kind)
            } else {
                Text("Unknown board: \(name)")
            }
        }
        .frame(width: 390, height: 844)
    }

    /// Review-only fixture selection, e.g. `--recovery-screen newPassword`, so UI tests and
    /// audits can open any fixture without editing this file. Normal launches start at Log in.
    private func launchValue<Value: RawRepresentable>(_ flag: String, default fallback: Value) -> Value
    where Value.RawValue == String {
        launchArgument(flag).flatMap(Value.init(rawValue:)) ?? fallback
    }

    private func launchArgument(_ flag: String) -> String? {
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: flag), args.indices.contains(index + 1) else { return nil }
        return args[index + 1]
    }
}

#Preview {
    ContentView()
}
