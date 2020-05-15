// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "cd2sql",
    products: [
        .executable(
            name: "cd2sql", targets: ["cd2sql"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/phimage/MomXML" , .upToNextMajor(from: "1.1.0")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.6"),
        .package(url: "https://github.com/nvzqz/FileKit.git", from: "6.0.0")
    ],
    targets: [
        .target(
            name: "cd2sql",
            dependencies: ["MomXML", "ArgumentParser", "FileKit"],
            path: "Sources"
        )
    ]
)
