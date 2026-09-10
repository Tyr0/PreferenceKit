
import Observation

internal import os.log

public protocol PreferencesProtocol: Observable, Sendable {

    associatedtype RemoveFailure: Error

    associatedtype ReadFailure: Error

    associatedtype WriteFailure: Error

    func value<Preference>(forPreference preference: Preference.Type) throws(ReadFailure) -> Preference.Value where Preference: PreferenceProtocol

    func updateValue<Preference>(_ value: Preference.Value, forPreference preference: Preference.Type) throws(WriteFailure) where Preference: PreferenceProtocol

    func removeValue<Preference>(forPreference preference: Preference.Type) throws(RemoveFailure) where Preference: PreferenceProtocol
}

extension PreferencesProtocol {

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
