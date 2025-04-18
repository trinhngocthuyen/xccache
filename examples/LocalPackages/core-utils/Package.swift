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
  ],
  targets: [
    .target(
      name: "Swizzler",
      dependencies: [
        .product(name: "SwiftyBeaver", package: "SwiftyBeaver"),
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
  ]
)
