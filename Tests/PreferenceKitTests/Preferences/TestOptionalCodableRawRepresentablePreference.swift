import PreferenceKit

enum TestOptionalCodableRawRepresentablePreference: PreferenceProtocol {

    static let key: String = "TestOptionalCodableRawRepresentablePreference"

    static let defaultValue: Optional<TestCodableRawRepresentable<String>> = TestCodableRawRepresentable(rawValue: "Hello")
}
