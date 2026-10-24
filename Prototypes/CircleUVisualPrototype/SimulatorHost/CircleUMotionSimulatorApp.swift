import Foundation
import SwiftUI

/// Direct-compiler Simulator host; no main-app target, packages or signing account.
@main
struct CircleUMotionSimulatorApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                BrandMotionDemo()
                    .toolbar(.hidden, for: .navigationBar)
            }
        }
    }
}

// The host copies the required original resources directly into its own bundle.
extension Bundle {
    static let module = Bundle.main
}
