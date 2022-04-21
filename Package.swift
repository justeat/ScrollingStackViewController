// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "ScrollingStackViewController",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "ScrollingStackViewController",
            targets: ["ScrollingStackViewController"]),
    ],
    targets: [
        .target(
            name: "ScrollingStackViewController",
            path: "ScrollingStackViewController/"
        )
    ]
)
