// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "apple-docs-cli",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "ad", targets: ["ad"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "AppleDocsLib",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .executableTarget(
            name: "ad",
            dependencies: ["AppleDocsLib"]
        ),
        .testTarget(
            name: "AppleDocsLibTests",
            dependencies: ["AppleDocsLib"],
            resources: [.copy("Fixtures")]
        ),
    ]
)
