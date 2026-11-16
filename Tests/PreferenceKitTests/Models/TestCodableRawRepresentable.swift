struct TestCodableRawRepresentable<RawValue>: RawRepresentable {

    // MARK: - Properties

    var rawValue: RawValue

    // MARK: - Lifecycle Functions

    init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension TestCodableRawRepresentable: Codable where RawValue: Codable {

}

extension TestCodableRawRepresentable: Equatable where RawValue: Equatable {

}

extension TestCodableRawRepresentable: Sendable where RawValue: Sendable {

}
