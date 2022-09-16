// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "INSOperationsKit",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "INSOperationsKit",
            targets: ["INSOperationsKit"]),
    ],
    targets: [
        .target(
            name: "INSOperationsKit",
            path: "INSOperationsKit",
            exclude: [
                "INSOperationsKit/Info.plist",
                "INSOperationsKit/INSOperationsKit.h",
                "INSOperationsKit/Supporting Files"
            ],
            publicHeadersPath: "Headers"),
    ]
)
