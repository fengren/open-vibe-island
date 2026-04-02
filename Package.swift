// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "VibeIsland",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "VibeIslandCore",
            targets: ["VibeIslandCore"]
        ),
        .executable(
            name: "VibeIslandApp",
            targets: ["VibeIslandApp"]
        ),
    ],
    targets: [
        .target(
            name: "VibeIslandCore"
        ),
        .executableTarget(
            name: "VibeIslandApp",
            dependencies: ["VibeIslandCore"]
        ),
        .testTarget(
            name: "VibeIslandCoreTests",
            dependencies: ["VibeIslandCore"]
        ),
    ]
)
