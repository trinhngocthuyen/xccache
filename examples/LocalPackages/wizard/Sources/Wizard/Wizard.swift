#if canImport(UIKit)
import UIKit
public typealias XColor = UIColor

#elseif canImport(AppKit)
import AppKit
public typealias XColor = NSColor

#else
#error("Only usable with UIKit or AppKit")
#endif

@freestanding(expression)
public macro hexColor(_ intLiteral: IntegerLiteralType ) -> XColor = #externalMacro(module: "WizardImpl", type: "HexColorMacro")
