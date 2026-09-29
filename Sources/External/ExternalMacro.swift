@freestanding(declaration, names: named(withChanges), named(apply))
public macro KMPStateSupport(
  _ type: Any.Type, _ properties: (String, Any.Type)..., internalAccessor: Bool = false
) =
  #externalMacro(
    module: "KMPStateSupportMacroMacros",
    type: "KMPStateSupportMacro"
  )
