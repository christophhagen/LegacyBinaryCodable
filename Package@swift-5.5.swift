// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "BinaryCodable",
    products: [
        .library(
            name: "LegacyBinaryCodable",
            targets: ["LegacyBinaryCodable"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.19.0"),
    ],
    targets: [
        .target(
            name: "LegacyBinaryCodable",
            dependencies: []),
        .testTarget(
            name: "BinaryCodableTests",
            dependencies: ["LegacyBinaryCodable", .product(name: "SwiftProtobuf", package: "swift-protobuf")],
            exclude: ["Proto/TestTypes.proto"]),
    ],
    swiftLanguageVersions: [.v5]
)
