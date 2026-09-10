
import Foundation

@_documentation(visibility: internal)
public protocol _UserDefaultsRepresentable: Equatable, Sendable {

    static func _userDefaultsValue(from object: AnyObject) -> _UserDefaultsValue<Self>
}

// Unfortunately, to ensure that arbitrary `_UserDefaultsValue<CustomType>` instances are not
// initialized by external packages, we cannot add a default conformance extension for
// `_UserDefaultsRepresentable`. If we did, anybody could simply conform their custom type to
// `_UserDefaultsRepresentable` and would receive a fully validated conformance for a type that
// is unlikely to be represented in a property list.
//
// Explicit conformances below.

extension Array: _UserDefaultsRepresentable where Element: _UserDefaultsRepresentable {

    public static func _userDefaultsValue(from object: AnyObject) -> _UserDefaultsValue<Self> {
        return _UserDefaultsValue(value: object as? Self)
    }
}

extension Bool: _UserDefaultsRepresentable {

    public static func _userDefaultsValue(from object: AnyObject) -> _UserDefaultsValue<Self> {
        return _UserDefaultsValue(value: object as? Self)
    }
}

extension Data: _UserDefaultsRepresentable {

    public static func _userDefaultsValue(from object: AnyObject) -> _UserDefaultsValue<Self> {
        return _UserDefaultsValue(value: object as? Self)
    }
}

extension Date: _UserDefaultsRepresentable {

    public static func _userDefaultsValue(from object: AnyObject) -> _UserDefaultsValue<Self> {
        return _UserDefaultsValue(value: object as? Self)
    }
}

extension Dictionary: _UserDefaultsRepresentable where Key == String, Value: _UserDefaultsRepresentable {

    public static func _userDefaultsValue(from object: AnyObject) -> _UserDefaultsValue<Self> {
        return _UserDefaultsValue(value: object as? Self)
    }
}

extension Double: _UserDefaultsRepresentable {

    public static func _userDefaultsValue(from object: AnyObject) -> _UserDefaultsValue<Self> {
        return _UserDefaultsValue(value: object as? Self)
    }
}

extension Float: _UserDefaultsRepresentable {

    public static func _userDefaultsValue(from object: AnyObject) -> _UserDefaultsValue<Self> {
        return _UserDefaultsValue(value: object as? Self)
    }
}

extension Int: _UserDefaultsRepresentable {

    public static func _userDefaultsValue(from object: AnyObject) -> _UserDefaultsValue<Self> {
        return _UserDefaultsValue(value: object as? Self)
    }
}

extension Int8: _UserDefaultsRepresentable {

    public static func _userDefaultsValue(from object: AnyObject) -> _UserDefaultsValue<Self> {
        return _UserDefaultsValue(value: object as? Self)
    }
}

extension Int16: _UserDefaultsRepresentable {

    public static func _userDefaultsValue(from object: AnyObject) -> _UserDefaultsValue<Self> {
        return _UserDefaultsValue(value: object as? Self)
    }
}

extension Int32: _UserDefaultsRepresentable {

    public static func _userDefaultsValue(from object: AnyObject) -> _UserDefaultsValue<Self> {
        return _UserDefaultsValue(value: object as? Self)
    }
}

extension Int64: _UserDefaultsRepresentable {

    public static func _userDefaultsValue(from object: AnyObject) -> _UserDefaultsValue<Self> {
        return _UserDefaultsValue(value: object as? Self)
    }
}

extension String: _UserDefaultsRepresentable {

    public static func _userDefaultsValue(from object: AnyObject) -> _UserDefaultsValue<Self> {
        return _UserDefaultsValue(value: object as? Self)
    }
}

extension UInt: _UserDefaultsRepresentable {

    public static func _userDefaultsValue(from object: AnyObject) -> _UserDefaultsValue<Self> {
        return _UserDefaultsValue(value: object as? Self)
    }
}

extension UInt8: _UserDefaultsRepresentable {

    public static func _userDefaultsValue(from object: AnyObject) -> _UserDefaultsValue<Self> {
        return _UserDefaultsValue(value: object as? Self)
    }
}

extension UInt16: _UserDefaultsRepresentable {

    public static func _userDefaultsValue(from object: AnyObject) -> _UserDefaultsValue<Self> {
        return _UserDefaultsValue(value: object as? Self)
    }
}

extension UInt32: _UserDefaultsRepresentable {

    public static func _userDefaultsValue(from object: AnyObject) -> _UserDefaultsValue<Self> {
        return _UserDefaultsValue(value: object as? Self)
    }
}

extension UInt64: _UserDefaultsRepresentable {

    public static func _userDefaultsValue(from object: AnyObject) -> _UserDefaultsValue<Self> {
        return _UserDefaultsValue(value: object as? Self)
    }
}
