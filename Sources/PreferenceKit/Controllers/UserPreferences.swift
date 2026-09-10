
import Foundation
import Observation

internal import os.lock

private nonisolated(unsafe) var ObservationContext: UInt8 = 0

public final class UserPreferences: PreferencesProtocol {

    public typealias ReadFailure = DecodingError

    public typealias WriteFailure = EncodingError

    public typealias RemoveFailure = Never

    private struct State {

        var registeredKeyPaths: Set<String> = []
    }

    // MARK: - Properties

    // TODO: document thread safety and why this `nonisolated(unsafe)` is safe
    public nonisolated(unsafe) let userDefaults: UserDefaults

    private let decoder: JSONDecoder

    private let encoder: JSONEncoder

    private let observer: Observer

    private let state: OSAllocatedUnfairLock<State>

    // MARK: - Lifecycle Functions

    // TODO: place in better location
    public static let `default` = UserPreferences(userDefaults: .standard)

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults

        self.decoder = JSONDecoder()

        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = .sortedKeys

        self.observer = Observer()

        self.state = OSAllocatedUnfairLock(initialState: State())
    }

    deinit {
        self.state.withLock { state in
            for keyPath in state.registeredKeyPaths {
                self.removeObservation(forKeyPath: keyPath)
            }
        }
    }

    // MARK: - PreferencesProtocol Conformance

    public func value<Preference>(forPreference preference: Preference.Type) throws(ReadFailure) -> Preference.Value where Preference: PreferenceProtocol {
        self.state.withLock { state in
            self.addObservationIfNeeded(forKeyPath: Preference.key, registeredKeyPaths: &state.registeredKeyPaths)
        }

        self.observer.access(Preference.key)

        let inputs = _ReadInputs(userDefaults: self.userDefaults, decoder: self.decoder)

        do {
            let outputs = try Preference._read(inputs: inputs)

            if let value = outputs.value {
                return value
            } else {
                return Preference.defaultValue
            }
        } catch {
            throw error.underlyingError
        }
    }

    public func updateValue<Preference>(_ value: Preference.Value, forPreference preference: Preference.Type) throws(WriteFailure) where Preference: PreferenceProtocol {
        let inputs = _WriteInputs(userDefaults: self.userDefaults, encoder: self.encoder)

        do {
            try Preference._write(value, inputs: inputs)
        } catch {
            throw error.underlyingError
        }
    }

    public func removeValue<Preference>(forPreference preference: Preference.Type) throws(RemoveFailure) where Preference: PreferenceProtocol {
        self.userDefaults.removeObject(forKey: Preference.key)
    }

    // MARK: - Private Functions

    private func addObservationIfNeeded(forKeyPath keyPath: String, registeredKeyPaths: inout Set<String>) {
        if registeredKeyPaths.contains(keyPath) {
            return
        }

        registeredKeyPaths.insert(keyPath)

        self.addObservation(forKeyPath: keyPath)
    }

    private func addObservation(forKeyPath keyPath: String) {
        self.userDefaults.addObserver(self.observer, forKeyPath: keyPath, options: [.prior], context: &ObservationContext)
    }

    private func removeObservation(forKeyPath keyPath: String) {
        self.userDefaults.removeObserver(self.observer, forKeyPath: keyPath, context: &ObservationContext)
    }

    private final class Observer: NSObject, Observable, Sendable {

        // MARK: - Properties

        let observationRegistrar: ObservationRegistrar = ObservationRegistrar()

        // MARK: - Functions

        func access(_ keyPath: String) {
            self.observationRegistrar.access(self, keyPath: self.observationKeyPath(forKeyPath: keyPath))
        }

        // MARK: - Private Functions

        private subscript(observationKeyPath _: String) -> Void {
            fatalError()
        }

        private func observationKeyPath(forKeyPath keyPath: String) -> KeyPath<Observer, Void> {
            return \.[observationKeyPath: keyPath]
        }

        // MARK: - NSObject (NSKeyValueObserving) Functions

        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: Dictionary<NSKeyValueChangeKey, Any>?, context: UnsafeMutableRawPointer?) {
            guard context == &ObservationContext else {
                return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }

            guard let keyPath = keyPath, let change = change else {
                return
            }

            if let isPrior = change[.notificationIsPriorKey],
               let isPrior = isPrior as? Bool,
               isPrior {
                self.observationRegistrar.willSet(self, keyPath: self.observationKeyPath(forKeyPath: keyPath))
            } else {
                self.observationRegistrar.didSet(self, keyPath: self.observationKeyPath(forKeyPath: keyPath))
            }
        }
    }
}
