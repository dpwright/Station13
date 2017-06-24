// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "site",
    dependencies: [
        .Package(url: "https://github.com/nmdias/FeedKit.git", majorVersion: 6),
        .Package(url: "https://github.com/kylef/Stencil.git", majorVersion: 0, minor: 9),
        .Package(url: "https://github.com/JohnSundell/Files.git", majorVersion: 1, minor: 9),
        .Package(url: "https://github.com/scinfu/SwiftSoup.git", majorVersion: 1, minor: 3)
    ]
)
