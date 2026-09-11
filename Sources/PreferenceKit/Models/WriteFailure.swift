
@_documentation(visibility: internal)
public struct _WriteFailure: Error {

    internal let underlyingError: EncodingError
}
