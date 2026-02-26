// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "sad-cli",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "sad", targets: ["sad"]),
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
            name: "sad",
            dependencies: ["AppleDocsLib"]
        ),
        .testTarget(
            name: "AppleDocsLibTests",
            dependencies: ["AppleDocsLib"],
            resources: [.copy("Fixtures")]
        ),
    ]
)
