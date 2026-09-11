
import os.lock
import PreferenceKit

final class MockPreferences: PreferencesProtocol {

    typealias ReadFailure = Never

    typealias WriteFailure = Never

    typealias RemoveFailure = Never

    private struct State {

        var storage: Dictionary<String, Any>
    }

    // MARK: - Properties

    private let state: OSAllocatedUnfairLock<State>

    // MARK: - Lifecycle Functions

    init(_ storage: Dictionary<String, Any> = [:]) {
        self.state = OSAllocatedUnfairLock(uncheckedState: State(storage: storage))
    }

    // MARK: - PreferencesProtocol Conformance

    func value<Preference>(forPreference preference: Preference.Type) throws(ReadFailure) -> Preference.Value where Preference: PreferenceProtocol {
        if let value = self.state.withLock({ state in
            return state.storage[Preference.key] as? Preference.Value
        }) {
            return value
        } else {
            return Preference.defaultValue
        }
    }

    func updateValue<Preference>(_ value: Preference.Value, forPreference preference: Preference.Type) throws(WriteFailure) where Preference: PreferenceProtocol {
        self.state.withLock { state in
            state.storage[Preference.key] = value
        }
    }

    func removeValue<Preference>(forPreference preference: Preference.Type) throws(RemoveFailure) where Preference: PreferenceProtocol {
        self.state.withLock { state in
            _ = state.storage.removeValue(forKey: Preference.key)
        }
    }
}
