// swift-tools-version: 6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
  name: "Wizard",
  platforms: [.iOS(.v17), .macOS(.v13)],
  products: [
    .library(
      name: "Wizard",
      targets: ["Wizard"]
    ),
    .executable(
      name: "WizardPlayground",
      targets: ["WizardPlayground"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-syntax.git", from: "600.0.0"),
  ],
  targets: [
    .macro(
      name: "WizardImpl",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),
    .target(name: "Wizard", dependencies: ["WizardImpl"]),
    .executableTarget(name: "WizardPlayground", dependencies: ["Wizard"]),
  ]
)
