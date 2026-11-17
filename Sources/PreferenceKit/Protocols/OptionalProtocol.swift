@_documentation(visibility: internal)
public protocol _OptionalProtocol {

    associatedtype Wrapped

    var _optionalValue: _OptionalValue<Wrapped> { get }

    init(_ value: consuming Wrapped)
}

extension Optional: _OptionalProtocol {

    public var _optionalValue: _OptionalValue<Wrapped> {
        return _OptionalValue(value: self)
    }
}
