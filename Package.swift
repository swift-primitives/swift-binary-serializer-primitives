// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-binary-serializer-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "Binary Serializer Primitives Core",
            targets: ["Binary Serializer Primitives Core"]
        ),
        .library(
            name: "Binary Integer Serializer Primitives",
            targets: ["Binary Integer Serializer Primitives"]
        ),
        .library(
            name: "Binary Serializer Primitives",
            targets: ["Binary Serializer Primitives"]
        ),
        .library(
            name: "Binary Serializer Primitives Test Support",
            targets: ["Binary Serializer Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-binary-primitives"),
        .package(path: "../swift-serializer-primitives"),
        .package(path: "../swift-byte-primitives"),
        .package(path: "../swift-witness-primitives"),
    ],
    targets: [
        // MARK: - Core
        .target(
            name: "Binary Serializer Primitives Core",
            dependencies: [
                .product(name: "Binary Primitives Core", package: "swift-binary-primitives"),
                .product(name: "Serializer Primitives", package: "swift-serializer-primitives"),
                .product(name: "Witness Primitives", package: "swift-witness-primitives"),
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
            ]
        ),

        // MARK: - Integer Serializers
        .target(
            name: "Binary Integer Serializer Primitives",
            dependencies: [
                "Binary Serializer Primitives Core",
            ]
        ),

        // MARK: - Umbrella
        .target(
            name: "Binary Serializer Primitives",
            dependencies: [
                "Binary Serializer Primitives Core",
                "Binary Integer Serializer Primitives",
            ]
        ),

        // MARK: - Test Support
        .target(
            name: "Binary Serializer Primitives Test Support",
            dependencies: [
                "Binary Serializer Primitives",
                .product(name: "Binary Primitives Test Support", package: "swift-binary-primitives"),
            ],
            path: "Tests/Support"
        ),

        // MARK: - Tests
        .testTarget(
            name: "Binary Serializer Primitives Tests",
            dependencies: [
                "Binary Serializer Primitives",
                "Binary Serializer Primitives Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
