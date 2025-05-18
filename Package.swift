// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "Buffett",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Buffett",
            targets: ["Buffett"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Buffett",
            dependencies: []
        ),
        .testTarget(
            name: "BuffettTests",
            dependencies: ["Buffett"]
        ),
        .testTarget(
            name: "RakutenStockAPITests",
            dependencies: ["Buffett"],
            resources: [
                .copy("Fixtures")
            ]
        )
    ]
)
