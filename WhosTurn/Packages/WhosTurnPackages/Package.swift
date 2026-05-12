// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "WhosTurnPackages",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "WTDesignSystem", targets: ["WTDesignSystem"]),
        .library(name: "WTRouter", targets: ["WTRouter"]),
        .library(name: "WTTools", targets: ["WTTools"]),
        .library(name: "WTPicker", targets: ["WTPicker"]),
        .library(name: "WTTeamSetup", targets: ["WTTeamSetup"]),
    ],
    targets: [
        .target(name: "WTDesignSystem"),
        .target(name: "WTRouter"),
        .target(name: "WTTools"),
        .target(name: "WTPicker", dependencies: ["WTDesignSystem", "WTRouter", "WTTools"]),
        .target(name: "WTTeamSetup", dependencies: ["WTDesignSystem", "WTRouter", "WTTools"]),
    ]
)
