
public struct _ReadOutputs<Value>: Sendable where Value: Sendable {

    // MARK: - Properties

    internal let value: Optional<Value>

    // MARK: - Lifecycle Functions

    internal init(value: Optional<Value> = nil) {
        self.value = value
    }
}
