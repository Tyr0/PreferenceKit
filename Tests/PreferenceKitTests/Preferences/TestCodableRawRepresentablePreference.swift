import PreferenceKit

enum TestCodableRawRepresentablePreference: PreferenceProtocol {

    static let key = "TestCodableRawRepresentablePreference"

    static let defaultValue: TestCodableRawRepresentable<String> = TestCodableRawRepresentable(rawValue: "Hello")
}
