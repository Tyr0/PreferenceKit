
import Observation

internal import os.log

/// An observable store of typed preferences.
///
/// ``UserPreferences`` provides an implementation backed by `UserDefaults`.
///
/// - Note: Use the named methods to handle errors, or the subscript for non-throwing accessors.
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

extension PreferencesProtocol {

    /// Returns the preference's value, or its default when no persisted value exists.
    ///
    /// Reading returns the default when no stored value exists or the read
    /// fails. A failed write is logged without propagating the error. Use
    /// ``value(forPreference:)`` and ``updateValue(_:forPreference:)`` when
    /// callers need to handle failures.
    public subscript<Preference>(preference: Preference.Type) -> Preference.Value where Preference: PreferenceProtocol {
        get {
            do {
                return try self.value(forPreference: preference)
            } catch {
                Logger.preferences.error("Attempted to read \(_typeName(Preference.self)) but received error instead: \(error)")

                return Preference.defaultValue
            }
        }
        nonmutating set {
            do {
                try self.updateValue(newValue, forPreference: preference)
            } catch {
                Logger.preferences.error("Attempted to update \(_typeName(Preference.self)) but received error instead: \(error)")
            }
        }
    }
}
