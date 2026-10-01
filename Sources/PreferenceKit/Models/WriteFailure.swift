@_documentation(visibility: internal)
public struct _WriteFailure: Error { // swiftlint:disable:this type_name

    internal let underlyingError: EncodingError
}
