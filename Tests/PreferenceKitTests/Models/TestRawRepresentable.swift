struct TestRawRepresentable<RawValue>: RawRepresentable {

    // MARK: - Properties

    var rawValue: RawValue

    // MARK: - Lifecycle Functions

    init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
}

extension TestRawRepresentable: Equatable where RawValue: Equatable {

}

extension TestRawRepresentable: Sendable where RawValue: Sendable {

}
