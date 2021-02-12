// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Frontbase",
    products: [
        .library (name: "Frontbase", targets: ["Frontbase"]),
    ],
    dependencies: [
        // 🇩🇰 Objective-C framework for accessing database.
        .package (url: "https://github.com/Oops-AB/CFrontbaseSupport.git", from: "1.0.0"),

        // 🌎 Utility package containing tools for byte manipulation, Codable, OS APIs, and debugging.
        .package (url: "https://github.com/vapor/core.git", from: "3.0.0"),

        // 🗄 Core services for creating database integrations.
        .package (url: "https://github.com/vapor/database-kit.git", from: "1.2.0"),
        
        // *️⃣ Build SQL queries in Swift. Extensible, protocol-based design that supports DQL, DML, and DDL.
        .package (url: "https://github.com/vapor/sql.git", from: "2.0.2"),
    ],
    targets: [
        .target (name: "Frontbase", dependencies: ["CFrontbaseSupport", "Async", "Bits", "Core", "DatabaseKit", "Debugging", "SQL"]),
        .target (name: "MemoryTools", dependencies: []),
        .testTarget (name: "FrontbaseTests", dependencies: ["Frontbase", "SQLBenchmark", "MemoryTools"]),
    ]
)
