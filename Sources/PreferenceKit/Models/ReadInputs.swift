import Foundation

@_documentation(visibility: internal)
public struct _ReadInputs {

    // MARK: - Properties

    internal let userDefaults: UserDefaults

    internal let decoder: JSONDecoder
}

extension _ReadInputs {

    // MARK: - Internal Functions

    internal func readObject<Value>(_: Value.Type = Value.self, forKey key: String) throws(_ReadFailure) -> Optional<Value> where Value: _UserDefaultsRepresentable {
        guard let object = self.userDefaults.object(forKey: key) else {
            return nil
        }

        guard let value = Value._userDefaultsValue(from: object as AnyObject).value else {
            throw _ReadFailure(underlyingError: DecodingError.typeMismatch(Value.self, DecodingError.Context(
                codingPath: [],
                debugDescription: "Expected to decode \(Value.self) but found \(type(of: object)) instead.",
            )))
        }

        return value
    }

    internal func readRawValue<Value>(_: Value.Type = Value.self, forKey key: String) throws(_ReadFailure) -> Optional<Value> where Value: RawRepresentable, Value.RawValue: _UserDefaultsRepresentable {
        guard let rawValue = try self.readObject(Value.RawValue.self, forKey: key) else {
            return nil
        }

        guard let value = Value(rawValue: rawValue) else {
            throw _ReadFailure(underlyingError: DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: [],
                debugDescription: "Failed to initialize \(Value.self) with rawValue \(rawValue).",
            )))
        }

        return value
    }
}
