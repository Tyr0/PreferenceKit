@_documentation(visibility: internal)
public protocol _OptionalProtocol {

    associatedtype Wrapped

    var _optionalValue: Optional<Wrapped> { get }

    init(_ value: consuming Wrapped)
}

extension Optional: _OptionalProtocol {

    public var _optionalValue: Optional<Wrapped> {
        return self
    }
}
