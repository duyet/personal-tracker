// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PersonalTracker",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "PersonalTrackerShared",
            targets: ["PersonalTrackerShared"]
        )
    ],
    dependencies: [
        // Add SwiftLint as a dependency for development
    ],
    targets: [
        .target(
            name: "PersonalTrackerShared",
            dependencies: [],
            path: "PersonalTracker/PersonalTrackerShared"
        ),
        .testTarget(
            name: "PersonalTrackerTests",
            dependencies: ["PersonalTrackerShared"],
            path: "PersonalTracker/PersonalTrackerTests"
        )
    ]
)
