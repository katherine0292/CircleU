import AppKit
import SwiftUI
import CircleUVisualPrototype

/// Standalone macOS review window; never imports or launches the Circleu app.
@main
struct CircleUMotionDemoApp: App {
    var body: some Scene {
        WindowGroup("CircleU Motion Demo") {
            BrandMotionDemo()
                .frame(minWidth: 320, minHeight: 640)
        }
        .defaultSize(width: 900, height: 920)
        .commands {
            CommandMenu("Preview") {
                Button("iPhone width") {
                    NSApplication.shared.keyWindow?.setContentSize(NSSize(width: 390, height: 844))
                }
                Button("Desktop comparison") {
                    NSApplication.shared.keyWindow?.setContentSize(NSSize(width: 900, height: 920))
                }
            }
        }
    }
}
