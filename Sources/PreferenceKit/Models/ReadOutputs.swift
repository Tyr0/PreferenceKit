@_documentation(visibility: internal)
public struct _ReadOutputs<Value> { // swiftlint:disable:this type_name

    // MARK: - Properties

    internal let value: Optional<Value>

    // MARK: - Lifecycle Functions

    internal init(value: Optional<Value> = nil) {
        self.value = value
    }
}
