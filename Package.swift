// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PreferenceKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .macCatalyst(.v17),
        .tvOS(.v17),
        .visionOS(.v1),
        .watchOS(.v10),
    ],
    products: [
        .library(
            name: "PreferenceKit",
            targets: ["PreferenceKit"]
        ),
    ],
    targets: [
        .target(
            name: "PreferenceKit"
        ),
        .testTarget(
            name: "PreferenceKitTests",
            dependencies: ["PreferenceKit"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
