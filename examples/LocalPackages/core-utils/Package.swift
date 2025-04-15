// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "CoreUtils",
  platforms: [.iOS(.v18)],
  products: [
    .library(name: "Swizzler", targets: ["Swizzler"]),
    .library(name: "ResourceKit", targets: ["ResourceKit"]),
  ],
  targets: [
    .target(name: "Swizzler"),
    .target(
      name: "ResourceKit",
      resources: [.copy("greetings.txt")]
    ),
  ]
)
