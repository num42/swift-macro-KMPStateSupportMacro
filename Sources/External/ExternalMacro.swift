@freestanding(declaration, names: arbitrary)
public macro KMPStateSupport(_ type: Any.Type, _ properties: (String, Any.Type)..., internalAccessor: Bool = false) =
  #externalMacro(
    module: "KMPStateSupportMacroMacros",
    type: "KMPStateSupportMacro"
  )
