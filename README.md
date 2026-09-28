# KMPStateSupportMacro

`#KMPStateSupport` is a Swift macro that generates `withChanges(...)` and `apply(path:value:)` functions for a Kotlin Multiplatform (KMP) state type, routing `AnyKeyPath`-based property updates through `KTStateWrapper` key paths.

## Requirements

- Swift 6.3 toolchain or later (tested with Xcode 27)
- Platforms: macOS 14, iOS 13, tvOS 13, watchOS 6, macCatalyst 13

## Installation

Add this package to your SwiftPM dependencies and import `KMPStateSupportMacro` in the files where you use the macro.

## Usage

Use `#KMPStateSupport` inside an extension on your KMP state type. Pass the state type first, followed by one `("propertyName", Type.self)` tuple per property:

```swift
import KMPStateSupportMacro

extension ProfileState {
  #KMPStateSupport(
    ProfileState.self,
    ("name", String.self),
    ("count", Int.self)
  )
}
```

Generated:

```swift
public func withChanges(name: String? = nil, count: Int? = nil) -> Self {
  Self(name: name ?? self.name, count: count ?? self.count)
}

public func apply(path: AnyKeyPath, value: Any) -> Self {
  typealias State = ProfileState

  return switch path {
  case \KTStateWrapper<State>.kt.name:
    withChanges(name: value as? String)
  case \KTStateWrapper<State>.kt.count:
    withChanges(count: value as? Int)
  default:
    fatalError("Unknown key path \(path)")
  }
}
```

## Optional Properties

Optional properties (for example `("trigger", Trigger?.self)`) become closure parameters of type `(() -> T?)? = nil`, so a value can be explicitly reset to `nil`.

## Kotlin Bridged Types

Kotlin boxed types such as `KotlinDouble`, `KotlinInt`, or `KotlinBoolean` are exposed with their Swift equivalents (`Double`, `Int32`, `Bool`, ...) in `withChanges(...)` and `apply(path:value:)`, and converted back to the Kotlin type when building the new state.

## Access Level

The generated functions are `public` by default. Pass `internalAccessor: true` as the last argument to generate them with internal access:

```swift
#KMPStateSupport(ProfileState.self, ("name", String.self), internalAccessor: true)
```
