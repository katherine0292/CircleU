// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CircleUVisualPrototype",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "CircleUVisualPrototype", targets: ["CircleUVisualPrototype"]),
        .executable(name: "render-previews", targets: ["RenderPreviews"]),
        .executable(name: "motion-demo", targets: ["MotionDemo"])
    ],
    targets: [
        .target(name: "CircleUVisualPrototype", resources: [.process("Resources")]),
        .executableTarget(name: "RenderPreviews", dependencies: ["CircleUVisualPrototype"]),
        .executableTarget(name: "MotionDemo", dependencies: ["CircleUVisualPrototype"])
    ]
)
