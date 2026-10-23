import AppKit
import SwiftUI
import CircleUVisualPrototype

/// Standalone macOS review window; never imports or launches the Circleu app.
@main
struct CircleUMotionDemoApp: App {
    var body: some Scene {
        WindowGroup("CircleU Motion Demo") {
            BrandMotionDemo()
                .frame(minWidth: 840, minHeight: 720)
        }
        .defaultSize(width: 900, height: 920)
    }
}
