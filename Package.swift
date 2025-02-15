// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MultiViews",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16),
        .macOS(.v13),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "MultiViews", targets: ["MultiViews"]),
    ],
    dependencies: [
        .package(url: "https://github.com/heestand-xyz/CoreGraphicsExtensions", from: "2.0.1")
    ],
    targets: [
        .target(name: "MultiViews", dependencies: ["CoreGraphicsExtensions"]),
    ]
)
