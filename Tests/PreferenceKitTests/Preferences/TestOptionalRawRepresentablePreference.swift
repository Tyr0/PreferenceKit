import PreferenceKit

enum TestOptionalRawRepresentablePreference: PreferenceProtocol {

    static let key: String = "TestOptionalRawRepresentablePreference"

    static let defaultValue: Optional<TestRawRepresentable<String>> = TestRawRepresentable(rawValue: "Hello")
}
