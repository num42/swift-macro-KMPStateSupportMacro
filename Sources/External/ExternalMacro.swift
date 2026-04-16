@freestanding(declaration, names: arbitrary)
public macro KMPStateSupport(_ properties: (AnyKeyPath, Any.Type)...) =
  #externalMacro(
    module: "KMPStateSupportMacroMacros",
    type: "KMPStateSupportMacro"
  )
