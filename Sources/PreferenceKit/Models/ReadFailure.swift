
@_documentation(visibility: internal)
public struct _ReadFailure: Error {

    internal let underlyingError: DecodingError
}
