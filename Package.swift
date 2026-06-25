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
            name: "Binary Serializer Witness Primitives",
            targets: ["Binary Serializer Witness Primitives"]
        ),
        .library(
            name: "Binary Serializable Primitives",
            targets: ["Binary Serializable Primitives"]
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
        .package(url: "https://github.com/swift-primitives/swift-binary-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-serializer-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-byte-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-witness-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-tagged-primitives.git", branch: "main"),
    ],
    targets: [
        // MARK: - Witness sub-namespace
        // Hosts the `Binary.Serializer` witness type, its `Serializer.Protocol`
        // conformance, and the RawRepresentable `serializer` defaults that return
        // `Binary.Serializer<Self>` (mutual collaborators per [MOD-026] → one sub-ns).
        .target(
            name: "Binary Serializer Witness Primitives",
            dependencies: [
                .product(name: "Binary Primitives", package: "swift-binary-primitives"),
                .product(name: "Serializer Primitives", package: "swift-serializer-primitives"),
                .product(name: "Witness Primitives", package: "swift-witness-primitives"),
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
            ]
        ),

        // MARK: - Sibling Protocol (relocated from swift-binary-primitives)
        .target(
            name: "Binary Serializable Primitives",
            dependencies: [
                .product(name: "Binary Primitives", package: "swift-binary-primitives"),
                .product(name: "Byte Primitives", package: "swift-byte-primitives"),
                .product(name: "Byte Primitives Standard Library Integration", package: "swift-byte-primitives"),
                .product(name: "Tagged Primitives", package: "swift-tagged-primitives"),
            ]
        ),

        // MARK: - Integer Serializers
        .target(
            name: "Binary Integer Serializer Primitives",
            dependencies: [
                "Binary Serializer Witness Primitives",
            ]
        ),

        // MARK: - Umbrella
        .target(
            name: "Binary Serializer Primitives",
            dependencies: [
                "Binary Serializer Witness Primitives",
                "Binary Serializable Primitives",
                "Binary Integer Serializer Primitives",
            ]
        ),

        // MARK: - Test Support
        .target(
            name: "Binary Serializer Primitives Test Support",
            dependencies: [
                "Binary Serializer Primitives",
                "Binary Serializable Primitives",
                .product(name: "Binary Primitives Test Support", package: "swift-binary-primitives"),
            ],
            path: "Tests/Support"
        ),

        // MARK: - Tests
        .testTarget(
            name: "Binary Serializer Primitives Tests",
            dependencies: [
                "Binary Serializer Primitives",
                "Binary Serializable Primitives",
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
