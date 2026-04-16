@freestanding(declaration, names: arbitrary)
public macro GenerateKMPStateSupport(_ state: Any.Type, _ properties: (AnyKeyPath, Any.Type)...) =
  #externalMacro(
    module: "KMPGenerateKMPStateSupportMacroMacros",
    type: "GenerateKMPStateSupportMacro"
  )
