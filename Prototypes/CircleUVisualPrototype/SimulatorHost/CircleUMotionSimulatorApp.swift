import Foundation
import SwiftUI

/// Direct-compiler Simulator host; no main-app target, packages or signing account.
@main
struct CircleUMotionSimulatorApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Group {
                    if ProcessInfo.processInfo.arguments.contains("--recovery") {
                        recovery
                    } else if ProcessInfo.processInfo.arguments.contains("--onboarding") {
                        if ProcessInfo.processInfo.arguments.contains("--largest-text") {
                            BrandOnboardingPreview().environment(\.dynamicTypeSize, .accessibility5)
                        } else if ProcessInfo.processInfo.arguments.contains("--large-text") {
                            BrandOnboardingPreview().environment(\.dynamicTypeSize, .accessibility1)
                        } else {
                            BrandOnboardingPreview()
                        }
                    } else {
                        BrandMotionDemo()
                    }
                }
                .toolbar(.hidden, for: .navigationBar)
            }
        }
    }

    private var recovery: some View {
        let args = ProcessInfo.processInfo.arguments
        let initial = args.firstIndex(of: "--recovery-screen").flatMap { index in
            args.indices.contains(index + 1) ? BrandRecoveryScreen(rawValue: args[index + 1]) : nil
        } ?? .logIn
        let scenario = args.firstIndex(of: "--scenario").flatMap { index in
            args.indices.contains(index + 1) ? BrandRecoveryScenario(rawValue: args[index + 1]) : nil
        } ?? .available
        return BrandOnboardingPreview(initialScreen: .logIn, recoveryScreen: initial, recoveryScenario: scenario)
            .environment(\.dynamicTypeSize, args.contains("--largest-text") ? .accessibility5 : (args.contains("--large-text") ? .accessibility1 : .large))
    }

}

// The host copies the required original resources directly into its own bundle.
extension Bundle {
    static let module = Bundle.main
}
