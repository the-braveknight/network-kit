// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "network-kit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "NetworkKit",
            targets: ["NetworkKit"]
        ),
        .library(
            name: "NetworkKitFoundation",
            targets: ["NetworkKitFoundation"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "NetworkKit",
            dependencies: [
                .product(name: "HTTPTypes", package: "swift-http-types"),
            ],
            path: "Sources/NetworkKit"
        ),
        .target(
            name: "NetworkKitFoundation",
            dependencies: [
                "NetworkKit",
                .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
            ],
            path: "Sources/NetworkKitFoundation"
        ),
        .testTarget(
            name: "NetworkKitTests",
            dependencies: ["NetworkKit"],
            path: "Tests/NetworkKitTests"
        ),
        .testTarget(
            name: "NetworkKitFoundationTests",
            dependencies: ["NetworkKit", "NetworkKitFoundation"],
            path: "Tests/NetworkKitFoundationTests"
        )
    ]
)
