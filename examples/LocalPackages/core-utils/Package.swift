// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "CoreUtils",
  products: [
    .library(name: "Swizzler", targets: ["Swizzler"]),
  ],
  targets: [
    .target(name: "Swizzler"),
  ]
)
