// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Stitcher",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Stitcher",
            targets: ["Stitcher"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-collections.git",
            .upToNextMinor(from: "1.1.0")
        ),
        .package(
            url: "https://github.com/OpenCombine/OpenCombine.git",
            exact: "0.14.0"
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Stitcher",
            dependencies: [
                .product(
                    name: "Collections",
                    package: "swift-collections"
                ),
                .product(
                    name: "OpenCombine",
                    package: "OpenCombine"
                ),
                .product(
                    name: "OpenCombineDispatch",
                    package: "OpenCombine"
                )
            ]
        ),
        .testTarget(
            name: "StitcherTests",
            dependencies: [
                "Stitcher"
            ]
        )
    ]
)
