// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "P3DrumMachine",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "P3DrumMachine",
            targets: ["P3DrumMachine"]
        )
    ],
    dependencies: [
        // Phosphor Icons for SwiftUI
        .package(url: "https://github.com/phosphor-icons/swift", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "P3DrumMachine",
            dependencies: [
                .product(name: "Phosphor", package: "swift")
            ],
            path: "P3DrumMachine/Shared"
        )
    ]
)
