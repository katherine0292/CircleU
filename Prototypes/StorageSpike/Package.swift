// swift-tools-version: 5.9
// Isolated storage spike for the first slice. Not linked into the Circleu app.
import PackageDescription

let package = Package(
    name: "StorageSpike",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "StorageSpike", targets: ["StorageSpike"])],
    targets: [
        .target(name: "StorageSpike"),
        .testTarget(name: "StorageSpikeTests", dependencies: ["StorageSpike"]),
    ]
)
