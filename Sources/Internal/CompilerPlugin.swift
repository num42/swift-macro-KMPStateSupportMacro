internal import SwiftCompilerPlugin
internal import SwiftSyntaxMacros

@main
struct KMPStateSupportMacroPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    KMPStateSupportMacro.self
  ]
}
