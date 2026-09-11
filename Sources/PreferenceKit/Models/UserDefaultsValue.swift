
// A struct type that is publicly-defined but only internally initializable;
// this prevents arbitrary conformances to the _UserDefaultsRepresentable
// protocol as external packages cannot initialize their own
// `_UserDefaultsValue<CustomType>` instances.
@_documentation(visibility: internal)
public struct _UserDefaultsValue<Value> {

    internal let value: Optional<Value>

    internal init(value: Optional<Value> = nil) {
        self.value = value
    }
}
