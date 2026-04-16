internal import MacroTester
internal import SwiftSyntaxMacros
internal import SwiftSyntaxMacrosTestSupport
internal import Testing

#if canImport(KMPGenerateKMPStateSupportMacroMacros)
  import KMPGenerateKMPStateSupportMacroMacros

  let testMacros: [String: Macro.Type] = [
    "GenerateKMPStateSupport": GenerateKMPStateSupportMacro.self
  ]

  @Suite
  struct GenerateKMPStateSupportMacroTests {
    @Test func generateApply() {
      MacroTester.testMacro(macros: testMacros)
    }

    @Test func generateApplyWithClosure() {
      MacroTester.testMacro(macros: testMacros)
    }
  }
#endif
