// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FZQuicklook",
    platforms: [.macOS("10.15.1")],
    products: [
        .library(
            name: "FZQuicklook",
            targets: ["FZQuicklook"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/MxIris-Library-Forks/FZSwiftUtils.git", branch: "stable"),
    ],
    targets: [
        .target(
            name: "FZQuicklook",
            dependencies: ["FZSwiftUtils"]
        ),
    ]
)
