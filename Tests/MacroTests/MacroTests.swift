internal import MacroTester
internal import SwiftSyntaxMacros
internal import SwiftSyntaxMacrosTestSupport
internal import Testing

#if canImport(KMPStateSupportMacroMacros)
  import KMPStateSupportMacroMacros

  let testMacros: [String: Macro.Type] = [
    "KMPStateSupport": KMPStateSupportMacro.self
  ]

  @Suite
  struct KMPStateSupportMacroTests {
    @Test func generateApply() {
      MacroTester.testMacro(macros: testMacros)
    }

    @Test func generateApplyWithClosure() {
      MacroTester.testMacro(macros: testMacros)
    }

    @Test func generateApplyWithKotlinBridgedType() {
      MacroTester.testMacro(macros: testMacros)
    }

    @Test func generateApplyWithNonOptionalKotlinBridgedType() {
      MacroTester.testMacro(macros: testMacros)
    }
  }
#endif
