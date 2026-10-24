import Foundation
import SwiftUI

/// Direct-compiler Simulator host; no main-app target, packages or signing account.
@main
struct CircleUMotionSimulatorApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Group {
                    if ProcessInfo.processInfo.arguments.contains("--onboarding") {
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
}

// The host copies the required original resources directly into its own bundle.
extension Bundle {
    static let module = Bundle.main
}
