// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "MultiViews",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(name: "MultiViews", targets: ["MultiViews"]),
    ],
    targets: [
        .target(name: "MultiViews", dependencies: []),
    ]
)
