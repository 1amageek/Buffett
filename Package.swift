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
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.7.2"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.8.1"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "Buffett",
            dependencies: ["SBIStockAPI"]
        ),
        .testTarget(
            name: "BuffettTests",
            dependencies: ["Buffett"]
        ),
        .target(
            name: "SBIStockAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession")
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
            ]
        )
    ]
)
