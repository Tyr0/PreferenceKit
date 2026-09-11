# PreferenceKit

A lightweight, observable interface to typed preferences on Apple platforms.
Define each preference's key, value type, and default once, then read and write
values through a shared store or a `UserDefaults` suite.

![License](https://img.shields.io/badge/License-MIT-green.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20visionOS%20%7C%20watchOS-blue.svg)
![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)

## Overview

`UserPreferences` is an `Observable` interface to the user's defaults database built around reusable and type-safe design patterns.

## Requirements

- Swift 6+
- iOS 17+ / macOS 14+ / Mac Catalyst 17+ / tvOS 17+ / visionOS 1+ / watchOS 10+

## Usage

Add the `PreferenceKit` library product to your target and import it. Define a
preference by conforming a type to `PreferenceProtocol`:

```swift
import PreferenceKit

enum ShowDebugMenuPreference: PreferenceProtocol {

	static let key = "showDebugMenu"

	static let defaultValue = false
}

let preferences = UserPreferences()

// `false` when absent
let showDebugMenu = preferences[ShowDebugMenuPreference.self]

// update the value to `true`
preferences[ShowDebugMenuPreference.self] = true

// remove the value to restore default state
preferences.removeValue(forPreference: ShowWelcome.self)
```

Use a stable, unique key for each preference; changing a key does not migrate
an existing value.

Reading a missing preference returns its default without writing it to storage.
Removing a value lets subsequent reads fall back to the default.

Keep stored representations compatible when changing a preference's value type
or coding implementation.

### Property Wrapper

Use `@Preference` to read and write a preference as a property. By default,
the wrapper uses `UserPreferences.default`:

```swift
struct Settings {

    @Preference(ShowDebugMenuPreference.self)
    var showDebugMenu: Bool
}

let settings = Settings()
settings.showDebugMenu = true
```

Supply a store to use a separate defaults suite or another `PreferencesProtocol`
implementation. Initialize the backing wrapper when the store is provided at runtime:

```swift
struct Settings<Preferences> where Preferences: PreferencesProtocol {

    @Preference<Preferences, ShowDebugMenuPreference>
    var showDebugMenu: Bool

    init(preferences: Preferences) {
        self._showDebugMenu = Preference(preferences: preferences)
    }
}
```

Reads and writes proviede a non-throwing interface to the stores persistence layer. A failed
read returns the default, and a failed write is logged. Use the store's named
methods when you need to handle errors.

### SwiftUI Bindings

Add the `PreferenceKit_SwiftUI` library product to your target and import it.
It also re-exports `PreferenceKit` and `SwiftUI`.

```swift
import PreferenceKit_SwiftUI

struct SettingsView: View {

    @Preference(ShowDebugMenuPreference.self)
    private var showDebugMenu: Bool

    var body: some View {
        Toggle("Show Debug Menu", isOn: self._showDebugMenu.binding)
    }
}
```

The binding reads and writes the same store as the wrapped property; reads participate in Swift Observation.

> [!NOTE]
> Use `_showDebugMenu.binding`, or `_showDebugMenu.projectedValue`, to obtain the
binding. The SwiftUI extension does not provide a `$showDebugMenu` accessor [due missing support at the Swift compiler level](https://forums.swift.org/t/property-wrapper-projectedvalue-cannot-be-in-a-extension/70269).

### Codable Values

Preferences can also store custom `Codable` values:

```swift
enum Appearance: Codable, Equatable, Sendable {

    case dark

    case light

    case system
}

enum AppearancePreference: PreferenceProtocol {

    static let key = "appearance"

    static let defaultValue = Appearance.system
}

preferences[AppearancePreference.self] = .dark
```

### Handling Errors

The subscript logs errors. A failed read returns the preference's default; a
failed write does not propagate an error to the caller. Use the named methods
when you need to handle failures:

```swift
do {
    let appearance = try preferences.value(forPreference: AppearancePreference.self)
    try preferences.updateValue(appearance, forPreference: AppearancePreference.self)
} catch {
    // Handle an incompatible stored value or an encoding failure.
}
```

`UserPreferences` reads throw `DecodingError` and writes throw `EncodingError`.
A failed decode leaves the stored value unchanged, and an encoding failure does
not replace it. Removing a value does not throw.

### Observation

`UserPreferences` participates in Swift `Observation`. Reading a preference
inside a SwiftUI view's body tracks access to that key:

```swift
import SwiftUI

struct RootView: View {

    let preferences: UserPreferences

    var body: some View {
        var shouldShowOnboardingView = preferences[ShouldShowOnboardingViewPreference.self]

        // a binding over the `shouldShowOnboardingView` copy;
        // does not mutate the underlying preference value.
        let shouldShowOnboardingViewBinding = Binding<Bool>(get: {
            return shouldShowOnboardingView
        }, set: { newValue in
            shouldShowOnboardingView = newValue
        })

        ContentView()
            .sheet(isPresented: shouldShowOnboardingViewBinding, onDismiss: {
                self.preferences[ShouldShowOnboardingViewPreference.self] = false
            }) {
                OnboardingView()
            }
    }
}
```

## API

#### @Preference

A property wrapper type that reflects a preference from a `PreferencesProtocol`.

```swift
@propertyWrapper
public struct Preference<Preferences, Preference>: Sendable where Preferences: PreferencesProtocol, Preference: PreferenceProtocol {

    /// The value represented by the preference definition.
    public typealias Value = Preference.Value

    /// The store used to read and write the preference.
    public let preferences: Preferences

    /// The stored value, or the preference's default when reading fails or no value exists.
    ///
    /// Writes update the store immediately. Failed writes are logged without
    /// propagating an error; use the store's named methods to handle errors.
    public var wrappedValue: Value { get nonmutating set }

    /// Creates a property for interfacing with a preference in the given preferences.
    ///
    /// - Parameters:
    ///   - preference: The preference definition. May be inferred from the wrapper's type.
    ///   - preferences: The store used for reads and writes.
    public init(_ preference: Preference.Type = Preference.self, preferences: Preferences)
}
```

```swift
extension Preference where Preferences == UserPreferences {

    /// Creates a property for interfacing with a preference in ``UserPreferences``.
    ///
    /// - Parameters:
    ///   - preference: The preference definition. May be inferred from the wrapper's type.
    ///   - preferences: The store used for reads and writes.
    public init(_ preference: Preference.Type = Preference.self, preferences: Preferences = .default)
}
```

```swift
extension Preference {

    /// A binding that reads and writes the preference through its store.
    ///
    /// - Note: The Swift compiler [does not synthesize the `$` shorthand for `-projectedValue`
    /// when implemented in an external module](https://forums.swift.org/t/property-wrapper-projectedvalue-cannot-be-in-a-extension/70269).
    public var projectedValue: Binding<Value> { get }

    /// A convenience alias for `projectedValue`.
    ///
    /// This property is available in order to clarify intent but is intended to be removed at a later date.
    @inline(__always)
    public var binding: Binding<Value> { get }
}
```

#### PreferenceProtocol

A typed preference definition for interfacing with a corresponding `PreferencesProtocol`.

```swift
public protocol PreferenceProtocol: Sendable {

    /// The value stored for this preference.
    associatedtype Value: Codable & Equatable & Sendable

    /// The key identifying this preference in the store.
    ///
    /// - Note: Use a stable, unique key for each preference. Changing the key
    /// does not migrate values stored under the previous key.
    static var key: String { get }

    /// The fallback returned when no stored value exists.
    ///
    /// Reading the fallback does not persist it.
    static var defaultValue: Value { get }
}
```

#### PreferencesProtocol

An observable store of typed preferences.

```swift
public protocol PreferencesProtocol: Observable, Sendable {

    /// The error raised when a persisted value cannot be queried.
    associatedtype ReadFailure: Error

    /// The error raised when a value cannot be persisted.
    associatedtype WriteFailure: Error

    /// The error raised when a value cannot be removed.
    associatedtype RemoveFailure: Error

    /// Returns the preference's value, or its default when no persisted value exists.
    ///
    /// - Returns: The persisted value for the corersponding preference, or its default value when no persisted value exists.
    /// - Throws: A ``ReadFailure`` when the stored value cannot be queried.
    func value<Preference>(forPreference preference: Preference.Type) throws(ReadFailure) -> Preference.Value where Preference: PreferenceProtocol

    /// Inserts or replaces the value for the given preference.
    ///
    /// - Throws: A ``WriteFailure`` when the value cannot be persisted.
    func updateValue<Preference>(_ value: Preference.Value, forPreference preference: Preference.Type) throws(WriteFailure) where Preference: PreferenceProtocol

    /// Removes the persisted value for the given preference.
    ///
    /// - Throws: A ``RemoveFailure`` when the value cannot be removed.
    func removeValue<Preference>(forPreference preference: Preference.Type) throws(RemoveFailure) where Preference: PreferenceProtocol
}
```

```swift
extension PreferencesProtocol {

    /// Returns the preference's value, or its default when no persisted value exists.
    ///
    /// Reading returns the default when no stored value exists or the read
    /// fails. A failed write is logged without propagating the error. Use
    /// ``value(forPreference:)`` and ``updateValue(_:forPreference:)`` when
    /// callers need to handle failures.
    public subscript<Preference>(preference: Preference.Type) -> Preference.Value where Preference: PreferenceProtocol { get nonmutating set }
}
```

#### UserPreferences

A `PreferencesProtocol` implementation backed by `UserDefaults`.

```swift
public final class UserPreferences: PreferencesProtocol {

    /// The error raised when a persisted value cannot be queried.
    public typealias ReadFailure = DecodingError

    /// The error raised when a value cannot be persisted.
    public typealias WriteFailure = EncodingError

    /// The error raised when a value cannot be removed.
    public typealias RemoveFailure = Never

    /// The shared preference store backed by `UserDefaults.standard`.
    public static let `default`: UserPreferences

    /// The defaults database backing this store.
    public nonisolated(unsafe) let userDefaults: UserDefaults

    /// Creates a `UserPreferences` backed by the provided `UserDefaults` instance.
    ///
    /// - Parameter userDefaults: The database to read and write. Defaults to `UserDefaults.standard`.
    public init(userDefaults: UserDefaults = .standard)

    /// Returns the preference's value, or its default when no persisted value exists.
    ///
    /// - Returns: The persisted value for the corersponding preference, or its default value when no persisted value exists.
    /// - Throws: A `ReadFailure` if the stored value has an incompatible type or cannot be decoded. The stored value is left unchanged.
    public func value<Preference>(forPreference preference: Preference.Type) throws(ReadFailure) -> Preference.Value where Preference: PreferenceProtocol

    /// Inserts or replaces the value for the given preference.
    ///
    /// - Throws: A `WriteFailure` if the value cannot be encoded. An encoding failure leaves the stored value unchanged.
    public func updateValue<Preference>(_ value: Preference.Value, forPreference preference: Preference.Type) throws(WriteFailure) where Preference: PreferenceProtocol

    /// Removes the persisted value for the given preference.
    ///
    /// - Throws: A `RemoveFailure` if the value cannot be encoded. An encoding failure leaves the stored value unchanged.
    public func removeValue<Preference>(forPreference preference: Preference.Type) throws(RemoveFailure) where Preference: PreferenceProtocol
}
```

Underscored types and requirements support persistence internally. Clients do
not need to implement them when defining preferences.

## Implementation Details

#### UserPreferences

`UserPreferences.default` uses `UserDefaults.standard`. Supply a defaults
instance to target a separate suite:

```swift
import Foundation

if let userDefaults = UserDefaults(suiteName: "com.example.MyApplicationContainer") {
    let preferences = UserPreferences(userDefaults: userDefaults)

    preferences[ShowDebugMenuPreference.self] = true
}
```

Supported property-list values are stored directly in `UserDefaults`; other
values are serialized and persisted as `Data`.
