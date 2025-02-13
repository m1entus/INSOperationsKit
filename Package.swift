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
                "Classes/iOS/Operations/INSLocationAccessOperation.h",
                "Classes/iOS/Operations/INSLocationAccessOperation.m",
                "Classes/iOS/Operations/INSPhotosLibraryAccessOperation.h",
                "Classes/iOS/Operations/INSPhotosLibraryAccessOperation.m",
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
                "Headers/INSLocationAccessCondition.h",
                "Classes/iOS/Operations/INSLocationAccessOperation.h",
                "Classes/iOS/Operations/INSLocationAccessOperation.m",
                "Classes/iOS/Operations/INSPhotosLibraryAccessOperation.h",
                "Classes/iOS/Operations/INSPhotosLibraryAccessOperation.m",
            ],
            publicHeadersPath: "Headers"),
    ]
)
