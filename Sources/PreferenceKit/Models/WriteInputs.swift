import Foundation

@_documentation(visibility: internal)
public struct _WriteInputs {

    // MARK: - Properties

    internal let userDefaults: UserDefaults

    internal let encoder: JSONEncoder
}

extension _WriteInputs {

    // MARK: - Internal Functions

    internal func writeObject<Value>(_ object: Value, forKey key: String) where Value: _UserDefaultsRepresentable {
        self.userDefaults.set(object, forKey: key)
    }

    internal func removeObject(forKey key: String) {
        self.userDefaults.removeObject(forKey: key)
    }
}
