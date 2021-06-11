// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "DataPersistence",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(name: "DataPersistence", targets: ["DataPersistence"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ollieatkinson/Eumorphic.git", .branch("trunk"))
    ],
    targets: [
        .target(name: "DataPersistence", dependencies: ["Eumorphic"]),
        .testTarget(name: "DataPersistenceTests", dependencies: ["DataPersistence"]),
    ]
)
