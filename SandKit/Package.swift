// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SandKit",
    platforms: [.iOS(.v14), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SandKit",
            targets: ["SandKit"]),
    ],
    dependencies: [
        /*.package(url: "https://github.com/shaps80/swift-markdown", branch: "main"),
        .package(url: "https://github.com/shaps80/SwiftUIBackports", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/raspu/Highlightr.git", from: "2.1.2")*/
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        
        .target(
            name: "SandKit",
            dependencies: [
                /*.product(name: "Markdown", package: "swift-markdown"),
                .product(
                    name: "Highlightr",
                    package: "Highlightr",
                    condition: .when(platforms: [.iOS, .macOS])
                ),
                "SwiftUIBackports"*/
            ],
            resources: [
                .copy("Resources/web.bundle")
            ]),
        .testTarget(
            name: "SandKitTests",
            dependencies: ["SandKit"]),
    ]
)
