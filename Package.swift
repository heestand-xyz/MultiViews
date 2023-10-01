// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MultiViews",
    platforms: [
        .iOS(.v14),
        .tvOS(.v14),
        .macOS(.v11),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "MultiViews", targets: ["MultiViews"]),
    ],
    dependencies: [
        .package(url: "https://github.com/heestand-xyz/CoreGraphicsExtensions", from: "1.3.2")
    ],
    targets: [
        .target(name: "MultiViews", dependencies: ["CoreGraphicsExtensions"]),
    ]
)
