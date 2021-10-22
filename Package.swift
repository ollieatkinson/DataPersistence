// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "DataPersistence",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(name: "DataPersistence", targets: ["DataPersistence"]),
    ],
    targets: [
        .target(name: "DataPersistence"),
        .testTarget(name: "DataPersistenceTests", dependencies: ["DataPersistence"]),
    ]
)
