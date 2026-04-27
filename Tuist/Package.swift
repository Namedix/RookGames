// swift-tools-version: 6.0
import PackageDescription

#if TUIST
import struct ProjectDescription.PackageSettings

let packageSettings = PackageSettings(
    productTypes: [
        "CasePaths": .framework,
        "Dependencies": .framework,
        "DependenciesMacros": .framework,
        "IdentifiedCollections": .framework,
        "IssueReporting": .framework,
        "Perception": .framework,
        "Sharing": .framework,
        "SwiftNavigation": .framework,
        "SwiftUINavigation": .framework,
        "Tagged": .framework,
    ]
)
#endif

let package = Package(
    name: "Rook",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "1.6.1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.7.0"),
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.1.1"),
        .package(url: "https://github.com/pointfreeco/swift-navigation", from: "2.2.3"),
        .package(url: "https://github.com/pointfreeco/swift-sharing", from: "2.2.0"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.5.1"),
    ]
)
