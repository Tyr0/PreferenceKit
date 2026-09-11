
internal import os.log

/// A property wrapper type that reflects a preference from a ``PreferencesProtocol``.
///
/// Accesses use the store's non-throwing subscript and preserve its observation behavior.
@propertyWrapper
public struct Preference<Preferences, Preference>: Sendable where Preferences: PreferencesProtocol, Preference: PreferenceProtocol {

    /// The value represented by the preference definition.
    public typealias Value = Preference.Value

    // MARK: - Properties

    /// The store used to read and write the preference.
    public let preferences: Preferences

    /// The stored value, or the preference's default when reading fails or no value exists.
    ///
    /// Writes update the store immediately. Failed writes are logged without
    /// propagating an error; use the store's named methods to handle errors.
    public var wrappedValue: Value {
        // Functionally equivalent to the convenience subscript on `PreferencesProtocol`
        // except that it uses a unique `Logger` instance for identifying the caller.
        get {
            do {
                return try self.preferences.value(forPreference: Preference.self)
            } catch {
                Logger.preference.error("Attempted to read \(_typeName(Preference.self)) but received error instead: \(error)")

                return Preference.defaultValue
            }
        }
        nonmutating set {
            do {
                try self.preferences.updateValue(newValue, forPreference: Preference.self)
            } catch {
                Logger.preference.error("Attempted to update \(_typeName(Preference.self)) but received error instead: \(error)")
            }
        }
    }

    // MARK: - Lifecycle Functions

    /// Creates a property for interfacing with a preference in the given preferences.
    ///
    /// - Parameters:
    ///   - preference: The preference definition. May be inferred from the wrapper's type.
    ///   - preferences: The store used for reads and writes.
    public init(_ preference: Preference.Type = Preference.self, preferences: Preferences) {
        self.preferences = preferences
    }
}

extension Preference where Preferences == UserPreferences {

    /// Creates a property for interfacing with a preference in ``UserPreferences``.
    ///
    /// - Parameters:
    ///   - preference: The preference definition. May be inferred from the wrapper's type.
    ///   - preferences: The store used for reads and writes.
    public init(_ preference: Preference.Type = Preference.self, preferences: Preferences = .default) {
        self.preferences = preferences
    }
}
