// A struct type that is publicly-defined but only internally initializable;
// this prevents arbitrary conformances to the _OptionalProtocol protocol as
// external packages cannot initialize their own `_OptionalValue<Wrapped>`
// instances.
@_documentation(visibility: internal)
public struct _OptionalValue<Value> {

    // MARK: - Properties

    internal var value: Optional<Value>

    // MARK: - Lifecycle Functions

    internal init(value: Optional<Value>) {
        self.value = value
    }
}
