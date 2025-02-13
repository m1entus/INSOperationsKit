// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "INSOperationsKit",
    platforms: [.iOS(.v12)],
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
                "Classes/iOS/Conditions",
                "Headers/INSPhotosLibraryAccessCondition.h",
                "Headers/INSLocationAccessCondition.h",
                "Info.plist",
                "INSOperationsKit.h",
                "Supporting Files"
            ],
            publicHeadersPath: "Headers"),
        .target(
            name: "INSOperationsKitConditions",
            dependencies: ["INSOperationsKit"],
            path: "INSOperationsKit",
            sources: [
                "Classes/iOS/Conditions",
                "Headers/INSPhotosLibraryAccessCondition.h",
                "Headers/INSLocationAccessCondition.h"
            ],
            publicHeadersPath: "Headers"),
    ]
)
