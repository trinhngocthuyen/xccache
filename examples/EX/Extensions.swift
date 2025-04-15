import Foundation

extension Bundle {
  var relativePath: String {
    return bundlePath
      .replacing(Bundle.main.bundlePath, with: "")
      .replacing(#/^\//#, with: "")
  }
}
