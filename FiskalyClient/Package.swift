// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let client = "com.fiskaly.client-ios-all-v2.0.0"
let package = Package(
    name: client,
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: client,
            targets: [client]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .binaryTarget(
                 name: client,
                 url: "https://storage.googleapis.com/fiskaly-cdn/clients/\(client).zip",
                 checksum: "6daaf6c72987f0437f3f16a1430746edb4ca44e9d886920a5726cfa08b27dbaf"
             )
    ]
)
