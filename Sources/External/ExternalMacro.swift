@freestanding(declaration, names: arbitrary)
public macro KMPStateSupport(_ state: Any.Type, _ properties: (AnyKeyPath, Any.Type)...) =
  #externalMacro(
    module: "KMPStateSupportMacroMacros",
    type: "KMPStateSupportMacro"
  )
