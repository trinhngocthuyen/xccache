import Foundation

@objc public class ResourceKit: NSObject {
  public static let bundle = Bundle.module
  public static func greetings() -> String? {
    guard let url = Bundle.module.url(forResource: "greetings", withExtension: "txt"),
          let content = try? String(contentsOf: url, encoding: .utf8)
    else { return nil }
    return content.replacing(#/\s*$/#, with: "") // Strip trailing spaces
  }
}
