// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "clicktok",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "clicktok",
            targets: ["clicktok"]),
    ],
    dependencies: [
        .package(url: "https://github.com/appwrite/sdk-for-apple", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "clicktok",
            dependencies: [
                .product(name: "Appwrite", package: "sdk-for-apple")
            ]),
        .testTarget(
            name: "clicktokTests",
            dependencies: ["clicktok"]),
    ]
) 