// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "site",
    dependencies: [
        .Package(url: "https://github.com/nmdias/FeedKit.git", majorVersion: 6)
    ]
)
