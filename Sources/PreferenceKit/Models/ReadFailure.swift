@_documentation(visibility: internal)
public struct _ReadFailure: Error { // swiftlint:disable:this type_name

    internal let underlyingError: DecodingError
}
