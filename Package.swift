// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Airmey",
    platforms: [.iOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Airmey",
            targets: ["Airmey"]),
        .library(
            name: "AMCrypto",
            targets: ["AMCrypto"]),
        .library(
            name: "AMPhotoKit",
            targets: ["AMPhotoKit"]),
        .library(
            name: "AMKeyboard",
            targets: ["AMKeyboard"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.4.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Airmey",
            dependencies: ["Alamofire"],
            exclude: ["Info.plist"],
            linkerSettings:[
                .linkedFramework("UIKit", .when(platforms: [.iOS])),
                .linkedFramework("Photos", .when(platforms: [.iOS])),
                .linkedFramework("CoreData", .when(platforms: [.iOS]))
            ]
        ),
        .target(
            name: "AMCrypto",
            dependencies: [],
            exclude: ["Info.plist"],
            publicHeadersPath: "."
        ),
        .target(
            name: "AMPhotoKit",
            dependencies: ["Airmey"],
            exclude: ["Info.plist"]
        ),
        .target(
            name: "AMKeyboard",
            dependencies: ["Airmey"],
            exclude: ["Info.plist"]
        )
    ]
)
