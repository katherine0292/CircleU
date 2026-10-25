import SwiftUI
import CircleUVisualPrototype

struct ContentView: View {
    var body: some View {
        NavigationStack {
            BrandOnboardingPreview(initialScreen: launchValue("--screen", default: .logIn),
                                   recoveryScreen: launchValue("--recovery-screen", default: .logIn),
                                   recoveryScenario: launchValue("--scenario", default: .available))
                .toolbar(.hidden, for: .navigationBar)
        }
    }

    /// Review-only fixture selection, e.g. `--recovery-screen newPassword`, so UI tests and
    /// audits can open any fixture without editing this file. Normal launches start at Log in.
    private func launchValue<Value: RawRepresentable>(_ flag: String, default fallback: Value) -> Value
    where Value.RawValue == String {
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: flag), args.indices.contains(index + 1) else { return fallback }
        return Value(rawValue: args[index + 1]) ?? fallback
    }
}

#Preview {
    ContentView()
}
