// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "CoreUtils",
  platforms: [.iOS(.v18)],
  products: [
    .library(name: "Swizzler", targets: ["Swizzler"]),
    .library(name: "ResourceKit", targets: ["ResourceKit"]),
    .library(name: "DebugKit", targets: ["DebugKit"]),
  ],
  targets: [
    .target(name: "Swizzler"),
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
