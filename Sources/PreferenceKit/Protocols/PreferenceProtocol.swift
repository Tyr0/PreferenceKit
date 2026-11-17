import Foundation

internal import os.log

/// A typed preference definition for interfacing with a corresponding ``PreferencesProtocol``.
///
/// Conform a type for each preference, then provide it to a ``PreferencesProtocol`` instance:
///
/// ```swift
/// enum ShowDebugMenuPreference: PreferenceProtocol {
///     static let key = "showDebugMenu"
///     static let defaultValue = false
/// }
///
/// let preferences = UserPreferences()
/// let showDebugMenu = preferences[ShowDebugMenuPreference.self]
/// ```
public protocol PreferenceProtocol: Sendable {

    /// The value stored for this preference.
    associatedtype Value: Equatable & Sendable

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

extension PreferenceProtocol where Value: _UserDefaultsRepresentable {

    public static func _read(inputs: borrowing _ReadInputs) throws(_ReadFailure) -> _ReadOutputs<Value> {
        return _ReadOutputs(value: try inputs.readObject(Value.self, forKey: Self.key))
    }

    public static func _write(_ value: Value, inputs: borrowing _WriteInputs) throws(_WriteFailure) -> _WriteOutputs<Value> {
        inputs.writeObject(value, forKey: Self.key)

        return _WriteOutputs()
    }
}

extension PreferenceProtocol where Value: Codable {

    public static func _read(inputs: borrowing _ReadInputs) throws(_ReadFailure) -> _ReadOutputs<Value> {
        guard let object = inputs.userDefaults.object(forKey: Self.key) else {
            return _ReadOutputs()
        }

        guard let data = object as? Data else {
            throw _ReadFailure(underlyingError: DecodingError.typeMismatch(Data.self, DecodingError.Context(
                codingPath: [],
                debugDescription: "Expected to decode \(Data.self) but found \(type(of: object)) instead.",
            )))
        }

        do {
            let value = try inputs.decoder.decode(Value.self, from: data)

            return _ReadOutputs(value: value)
        } catch let error as DecodingError {
            throw _ReadFailure(underlyingError: error)
        } catch {
            throw _ReadFailure(underlyingError: DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: [],
                debugDescription: "Received \(type(of: error)) during decoding of \(Value.self).",
                underlyingError: error
            )))
        }
    }

    public static func _write(_ value: Value, inputs: borrowing _WriteInputs) throws(_WriteFailure) -> _WriteOutputs<Value> {
        do {
            let data = try inputs.encoder.encode(value)

            inputs.writeObject(data, forKey: Self.key)

            return _WriteOutputs()
        } catch let error as EncodingError {
            throw _WriteFailure(underlyingError: error)
        } catch {
            throw _WriteFailure(underlyingError: EncodingError.invalidValue(value, EncodingError.Context(
                codingPath: [],
                debugDescription: "Received \(type(of: error)) during encoding of \(Value.self).",
                underlyingError: error
            )))
        }
    }
}

extension PreferenceProtocol where Value: RawRepresentable, Value.RawValue: _UserDefaultsRepresentable {

    public static func _read(inputs: borrowing _ReadInputs) throws(_ReadFailure) -> _ReadOutputs<Value> {
        return _ReadOutputs(value: try inputs.readRawValue(Value.self, forKey: Self.key))
    }

    public static func _write(_ value: Value, inputs: borrowing _WriteInputs) throws(_WriteFailure) -> _WriteOutputs<Value> {
        inputs.writeObject(value.rawValue, forKey: Self.key)

        return _WriteOutputs()
    }
}

extension PreferenceProtocol where Value: Codable & RawRepresentable, Value.RawValue: _UserDefaultsRepresentable {

    public static func _read(inputs: borrowing _ReadInputs) throws(_ReadFailure) -> _ReadOutputs<Value> {
        return _ReadOutputs(value: try inputs.readRawValue(Value.self, forKey: Self.key))
    }

    public static func _write(_ value: Value, inputs: borrowing _WriteInputs) throws(_WriteFailure) -> _WriteOutputs<Value> {
        inputs.writeObject(value.rawValue, forKey: Self.key)

        return _WriteOutputs()
    }
}

extension PreferenceProtocol where Value: Codable & _OptionalProtocol, Value.Wrapped: _UserDefaultsRepresentable {

    public static func _read(inputs: borrowing _ReadInputs) throws(_ReadFailure) -> _ReadOutputs<Value> {
        if let wrappedValue = try inputs.readObject(Value.Wrapped.self, forKey: Self.key) {
            return _ReadOutputs(value: Value(wrappedValue))
        } else {
            return _ReadOutputs()
        }
    }

    public static func _write(_ value: Value, inputs: borrowing _WriteInputs) throws(_WriteFailure) -> _WriteOutputs<Value> {
        if let optionalValue = value._optionalValue {
            inputs.writeObject(optionalValue, forKey: Self.key)
        } else {
            inputs.removeObject(forKey: Self.key)
        }

        return _WriteOutputs()
    }
}

extension PreferenceProtocol where Value: _OptionalProtocol, Value.Wrapped: RawRepresentable, Value.Wrapped.RawValue: _UserDefaultsRepresentable {

    public static func _read(inputs: borrowing _ReadInputs) throws(_ReadFailure) -> _ReadOutputs<Value> {
        if let wrappedValue = try inputs.readRawValue(Value.Wrapped.self, forKey: Self.key) {
            return _ReadOutputs(value: Value(wrappedValue))
        } else {
            return _ReadOutputs()
        }
    }

    public static func _write(_ value: Value, inputs: borrowing _WriteInputs) throws(_WriteFailure) -> _WriteOutputs<Value> {
        if let optionalValue = value._optionalValue {
            inputs.writeObject(optionalValue.rawValue, forKey: Self.key)
        } else {
            inputs.removeObject(forKey: Self.key)
        }

        return _WriteOutputs()
    }
}

extension PreferenceProtocol where Value: Codable & _OptionalProtocol, Value.Wrapped: Codable & RawRepresentable, Value.Wrapped.RawValue: _UserDefaultsRepresentable {

    public static func _read(inputs: borrowing _ReadInputs) throws(_ReadFailure) -> _ReadOutputs<Value> {
        if let wrappedValue = try inputs.readRawValue(Value.Wrapped.self, forKey: Self.key) {
            return _ReadOutputs(value: Value(wrappedValue))
        } else {
            return _ReadOutputs()
        }
    }

    public static func _write(_ value: Value, inputs: borrowing _WriteInputs) throws(_WriteFailure) -> _WriteOutputs<Value> {
        if let optionalValue = value._optionalValue {
            inputs.writeObject(optionalValue.rawValue, forKey: Self.key)
        } else {
            inputs.removeObject(forKey: Self.key)
        }

        return _WriteOutputs()
    }
}
