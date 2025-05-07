// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "CoreUtils",
  platforms: [.iOS(.v17)],
  products: [
    .library(name: "Swizzler", targets: ["Swizzler"]),
    .library(name: "ResourceKit", targets: ["ResourceKit"]),
    .library(name: "DebugKit", targets: ["DebugKit"]),
    .library(name: "TestKit", targets: ["TestKit"]),
  ],
  dependencies: [
    .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "2.1.1")),
    .package(url: "https://github.com/Moya/Moya", .upToNextMajor(from: "15.0.3")),
  ],
  targets: [
    .target(
      name: "Swizzler",
      dependencies: [
        "CoreUtils-Wrapper"
      ]
    ),
    .target(
      name: "ResourceKit",
      dependencies: ["CoreUtils-Wrapper"],
      resources: [.copy("greetings.txt")]
    ),
    .target(
      name: "DebugKit",
      dependencies: [
        "CoreUtils-Wrapper",
        "Swizzler",
        .product(name: "SwiftyBeaver", package: "SwiftyBeaver"),
        .product(name: "Moya", package: "Moya"),
      ],
      path: "Sources/DebugKitObjC",
      resources: [.copy("token.txt")],
      publicHeadersPath: "Headers",
      cSettings: [
        .headerSearchPath("PrivateHeaders"),
      ]
    ),
    .target(
      name: "CoreUtils-Wrapper",
      path: "Sources/Core"
    ),
    .target(name: "TestKit"),
  ]
)
