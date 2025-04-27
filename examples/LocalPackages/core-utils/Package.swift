// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "CoreUtils",
  platforms: [.iOS(.v17)],
  products: [
    .library(name: "Swizzler", targets: ["Swizzler"]),
    .library(name: "ResourceKit", targets: ["ResourceKit"]),
    .library(name: "DebugKit", targets: ["DebugKit"]),
  ],
  dependencies: [
    .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "2.1.1")),
    .package(url: "https://github.com/Moya/Moya", .upToNextMajor(from: "15.0.3")),
  ],
  targets: [
    .target(
      name: "Swizzler",
      dependencies: [
        "CoreUtils-Wrapper",
        .product(name: "SwiftyBeaver", package: "SwiftyBeaver"),
        .product(name: "Moya", package: "Moya"),
      ]
    ),
    .target(
      name: "ResourceKit",
      resources: [.copy("greetings.txt")]
    ),
    .target(
      name: "DebugKit",
      path: "Sources/DebugKitObjc",
      resources: [.copy("token.txt")]
    ),
    .target(
      name: "CoreUtils-Wrapper",
      path: "Sources/Core"
    )
  ]
)
