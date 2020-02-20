// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Animation",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(name: "Animation", targets: ["Animation"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Animation",
            path: "Animation"
        )
    ],
    swiftLanguageVersions: [.v5]
)
