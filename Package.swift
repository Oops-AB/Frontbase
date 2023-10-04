// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Frontbase",
    platforms: [
        .macOS (.v10_15)
    ],
    products: [
        .library (name: "Frontbase", targets: ["Frontbase"]),
    ],
    dependencies: [
        // 🇩🇰 A Swift module for accessing Frontbase databases.
        .package(url: "https://github.com/Oops-AB/FrontbaseNIO.git", from: "1.2.2"),

        // 🗄 Core services for creating database integrations.
        .package(url: "https://github.com/vapor/sql-kit.git", from: "3.0.0"),

        // 🌎 Utility package containing tools for asynchronous operations.
        .package(url: "https://github.com/vapor/async-kit.git", from: "1.0.0"),
    ],
    targets: [
        .target (name: "Frontbase", dependencies: [
            .product (name: "AsyncKit", package: "async-kit"),
            .product (name: "SQLKit", package: "sql-kit"),
            .product (name: "FrontbaseNIO", package: "FrontbaseNIO")]),
        .testTarget (name: "FrontbaseTests", dependencies: [
            .target (name: "Frontbase"),
            .product (name: "SQLKitBenchmark", package: "sql-kit")])
    ]
)
