// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MultiViews",
    platforms: [
        .iOS(.v17),
        .tvOS(.v17),
        .macOS(.v14),
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
