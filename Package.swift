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
        .library(
            name: "BuffettUI",
            targets: ["BuffettUI"]),
        .library(
            name: "RakutenStockAPI",
            targets: ["RakutenStockAPI"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "RakutenStockAPI",
            dependencies: []
        ),
        .target(
            name: "Buffett",
            dependencies: ["RakutenStockAPI"]
        ),
        .target(
            name: "BuffettUI",
            dependencies: ["Buffett", "RakutenStockAPI"]
        ),
        .testTarget(
            name: "BuffettTests",
            dependencies: ["Buffett", "RakutenStockAPI", "BuffettUI"]
        )
    ]
)
