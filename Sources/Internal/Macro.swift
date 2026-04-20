public import SwiftSyntax
internal import SwiftSyntaxBuilder
public import SwiftSyntaxMacros

public struct KMPStateSupportMacro: DeclarationMacro {
  enum Error: Swift.Error, CustomStringConvertible {
    case noProperties
    case invalidType(String)
    case invalidProperty(String)

    var description: String {
      switch self {
      case .noProperties:
        "#KMPStateSupport requires a type and at least one property"
      case .invalidType(let str):
        "Invalid type format '\(str)'. Expected Type.self."
      case .invalidProperty(let str):
        "Invalid property format '\(str)'. Expected (\"propertyName\", Type.self)."
      }
    }
  }

  struct Property {
    let name: String
    let type: String
    let isOptional: Bool
    let rootType: String

    var baseType: String {
      isOptional ? String(type.dropLast()) : type
    }

    private static let kotlinToSwiftTypeMap: [String: String] = [
      "KotlinDouble": "Double",
      "KotlinFloat": "Float",
      "KotlinInt": "Int32",
      "KotlinLong": "Int64",
      "KotlinBoolean": "Bool",
      "KotlinShort": "Int16",
      "KotlinByte": "Int8",
      "KotlinUByte": "UInt8",
      "KotlinUShort": "UInt16",
      "KotlinUInt": "UInt32",
      "KotlinULong": "UInt64",
    ]

    /// The Swift equivalent type for Kotlin bridged types (e.g. KotlinDouble → Double).
    var swiftType: String? {
      Self.kotlinToSwiftTypeMap[baseType]
    }

    var isKotlinBridgedType: Bool {
      swiftType != nil
    }
  }

  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    let arguments = Array(node.arguments)

    guard !arguments.isEmpty else {
      throw Error.noProperties
    }

    // First argument is the type: MyState.self
    guard
      let memberAccess = arguments[0].expression.as(MemberAccessExprSyntax.self),
      memberAccess.declName.baseName.text == "self",
      let base = memberAccess.base
    else {
      throw Error.invalidType(arguments[0].expression.trimmedDescription)
    }

    let typeName = base.trimmedDescription

    // Remaining arguments are property tuples: ("name", String.self)
    let propertyArgs = arguments.dropFirst()
    guard !propertyArgs.isEmpty else {
      throw Error.noProperties
    }

    let properties = try parseProperties(from: propertyArgs, rootType: typeName)

    let withFunc = generateWithFunction(properties: properties)
    let applyFunc = generateApplyFunction(typeName: typeName, properties: properties)

    return [DeclSyntax(stringLiteral: withFunc), DeclSyntax(stringLiteral: applyFunc)]
  }

  private static func parseProperties(
    from arguments: some Sequence<LabeledExprSyntax>,
    rootType: String
  ) throws -> [Property] {
    try arguments.map { arg in
      guard
        let tuple = arg.expression.as(TupleExprSyntax.self),
        tuple.elements.count == 2
      else {
        throw Error.invalidProperty(arg.expression.trimmedDescription)
      }

      let elements = Array(tuple.elements)

      // First element: string literal for property name
      guard
        let stringLiteral = elements[0].expression.as(StringLiteralExprSyntax.self),
        let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self)
      else {
        throw Error.invalidProperty(arg.expression.trimmedDescription)
      }

      let name = segment.content.text

      // Second element: Type.self for property type
      guard
        let memberAccess = elements[1].expression.as(MemberAccessExprSyntax.self),
        memberAccess.declName.baseName.text == "self",
        let base = memberAccess.base
      else {
        throw Error.invalidProperty(arg.expression.trimmedDescription)
      }

      let type = base.trimmedDescription
      let isOptional = type.hasSuffix("?")

      return Property(name: name, type: type, isOptional: isOptional, rootType: rootType)
    }
  }

  private static func generateWithFunction(properties: [Property]) -> String {
    let params = properties.map { prop in
      let paramType = prop.swiftType ?? prop.baseType
      return if prop.isOptional {
        "\(prop.name): (() -> \(paramType)?)? = nil"
      } else {
        "\(prop.name): \(paramType)? = nil"
      }
    }.joined(separator: ", ")

    let localVars = properties.compactMap { prop -> String? in
      guard prop.isKotlinBridgedType, prop.isOptional else { return nil }
      let cap = capitalizeFirst(prop.name)
      return "let new\(cap) = if \(prop.name) != nil { \(prop.name)?().flatMap(\(prop.baseType).init) } else { self.\(prop.name) }"
    }

    let bodyArgs = properties.map { prop in
      if prop.isKotlinBridgedType {
        if prop.isOptional {
          let cap = capitalizeFirst(prop.name)
          return "\(prop.name): new\(cap)"
        } else {
          return "\(prop.name): \(prop.name) ?? self.\(prop.name)"
        }
      } else if prop.isOptional {
        return "\(prop.name): \(prop.name) != nil ? \(prop.name)!() : self.\(prop.name)"
      } else {
        return "\(prop.name): \(prop.name) ?? self.\(prop.name)"
      }
    }.joined(separator: ", ")

    if localVars.isEmpty {
      return """
        func withChanges(\(params)) -> Self {
          Self(\(bodyArgs))
        }
        """
    } else {
      let localVarsStr = localVars.joined(separator: "\n  ")
      return """
        func withChanges(\(params)) -> Self {
          \(localVarsStr)
          return Self(\(bodyArgs))
        }
        """
    }
  }

  private static func capitalizeFirst(_ s: String) -> String {
    s.prefix(1).uppercased() + s.dropFirst()
  }

  private static func generateApplyFunction(typeName: String, properties: [Property]) -> String {
    var caseLines: [String] = []

    for prop in properties {
      caseLines.append("    case \\KTStateWrapper<State>.kt.\(prop.name):")
      let castType = prop.swiftType ?? prop.baseType
      if prop.isOptional {
        caseLines.append("      withChanges(\(prop.name): { value as? \(castType) })")
      } else {
        caseLines.append("      withChanges(\(prop.name): value as? \(castType))")
      }
    }

    let casesStr = caseLines.joined(separator: "\n")
    let fatalLine = #"fatalError("Unknown key path \(path)")"#

    return """
      func apply(path: AnyKeyPath, value: Any) -> Self {
        typealias State = \(typeName)

        return switch path {
      \(casesStr)
        default:
          \(fatalLine)
        }
      }
      """
  }
}
