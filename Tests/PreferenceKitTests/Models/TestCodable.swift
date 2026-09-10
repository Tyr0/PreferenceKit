
struct TestCodable: Codable, Equatable, Sendable {

    typealias Identifier = UInt64

    // MARK: - Properties

    let id: Identifier

    // MARK: - Lifecycle Functions

    init(id: Identifier = .random(in: Identifier.min...Identifier.max)) {
        self.id = id
    }
}
