// swift-tools-version:4.1

import PackageDescription

let package = Package(
    name: "station13",
    products: [
        .executable(name: "site", targets: ["Site"])
    ],
    dependencies: [
        .package(url: "https://github.com/nmdias/FeedKit.git", from: "6.0.0"),
        .package(url: "https://github.com/kylef/Stencil.git", .upToNextMinor(from: "0.9.0")),
        .package(url: "https://github.com/JohnSundell/Files.git", .upToNextMinor(from: "1.9.0")),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", .upToNextMinor(from: "1.3.0"))
    ],
    targets: [
        .target(
            name: "Site",
            dependencies: ["FeedKit", "Stencil", "Files", "SwiftSoup"]
        )
    ]
)
