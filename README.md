# PreferenceKit

A lightweight, observable interface to typed preferences on Apple platforms.
Define each preference's key, value type, and default once, then read and write
values through a shared store or a `UserDefaults` suite.

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
        var hasShownOnboardingView = preferences[HasShownOnboardingViewPreference.self]

        let hasShownOnboardingViewBinding = Binding<Bool>(get: {
            return hasShownOnboardingView
        }, set: { newValue in
            hasShownOnboardingView = newValue
        })

        ContentView()
            .sheet(isPresented: hasShownOnboardingViewBinding, onDismiss: {
                self.preferences[HasShownOnboardingViewPreference.self] = true
            }) {
                OnboardingView()
            }
    }
}
```

## API

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

    @_documentation(visibility: internal)
    static func _read(inputs: borrowing _ReadInputs) throws(_ReadFailure) -> _ReadOutputs<Value>

    @discardableResult @_documentation(visibility: internal)
    static func _write(_ value: Value, inputs: borrowing _WriteInputs) throws(_WriteFailure) -> _WriteOutputs<Value>
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
    public subscript<Preference>(preference: Preference.Type) -> Preference.Value where Preference: PreferenceProtocol
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
    public static let `default` = UserPreferences(userDefaults: .standard)

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
