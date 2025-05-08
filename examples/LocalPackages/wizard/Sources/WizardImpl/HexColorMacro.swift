import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum HexColorMacroError: Error {
  case notFoundHex
}

public struct HexColorMacro: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> ExprSyntax {
    guard let arg = node.arguments.first,
          let expr = arg.expression.as(IntegerLiteralExprSyntax.self)
    else {
      throw HexColorMacroError.notFoundHex
    }
    let hex = expr.literal.text
    return """
    XColor(
      red: .init((\(raw: hex) >> 16) & 0xff) / 255,
      green: .init((\(raw: hex) >> 8) & 0xff) / 255,
      blue: .init((\(raw: hex) >> 0) & 0xff) / 255,
      alpha: 1.0
    )
    """
  }
}
