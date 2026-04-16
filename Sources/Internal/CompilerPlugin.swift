internal import SwiftCompilerPlugin
internal import SwiftSyntaxMacros

@main
struct KMPGenerateKMPStateSupportMacroPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    GenerateKMPStateSupportMacro.self
  ]
}
