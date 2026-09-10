
struct TestInvalidCodable: Codable, Equatable, Sendable {

    typealias Identifier = UInt64

    // MARK: - Properties

    let id: Identifier

    // MARK: - Lifecycle Functions

    init(id: Identifier = .random(in: Identifier.min...Identifier.max)) {
        self.id = id
    }

    // MARK: - Codable Conformance

    init(from decoder: any Decoder) throws {
        throw DecodingError.dataCorrupted(DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "Explicit decoding failure of \(Self.self)."
        ))
    }

    func encode(to encoder: any Encoder) throws {
        throw EncodingError.invalidValue(self, EncodingError.Context(
            codingPath: encoder.codingPath,
            debugDescription: "Explicit encoding failure of \(Self.self)."
        ))
    }
}
