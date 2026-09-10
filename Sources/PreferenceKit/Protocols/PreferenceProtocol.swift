
import Foundation

internal import os.log

public protocol PreferenceProtocol: Sendable {

    associatedtype Value: Codable & Equatable & Sendable

    static var key: String { get }

    static var defaultValue: Value { get }

    @_documentation(visibility: internal)
    static func _read(inputs: borrowing _ReadInputs) throws(_ReadFailure) -> _ReadOutputs<Value>

    @discardableResult @_documentation(visibility: internal)
    static func _write(_ value: Value, inputs: borrowing _WriteInputs) throws(_WriteFailure) -> _WriteOutputs<Value>
}

extension PreferenceProtocol {

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

            inputs.userDefaults.set(data, forKey: Self.key)

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

extension PreferenceProtocol where Value: _UserDefaultsRepresentable {

    public static func _read(inputs: borrowing _ReadInputs) throws(_ReadFailure) -> _ReadOutputs<Value> {
        guard let object = inputs.userDefaults.object(forKey: Self.key) else {
            return _ReadOutputs()
        }

        let propertyListValue = Value._userDefaultsValue(from: object as AnyObject)

        if let value = propertyListValue.value {
            return _ReadOutputs(value: value)
        } else {
            throw _ReadFailure(underlyingError: DecodingError.typeMismatch(Value.self, DecodingError.Context(
                codingPath: [],
                debugDescription: "Expected to decode \(Value.self) but found \(type(of: object)) instead.",
            )))
        }
    }

    public static func _write(_ value: Value, inputs: borrowing _WriteInputs) throws(_WriteFailure) -> _WriteOutputs<Value> {
        inputs.userDefaults.set(value, forKey: Self.key)

        return _WriteOutputs()
    }
}
