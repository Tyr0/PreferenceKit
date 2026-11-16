import PreferenceKit

enum TestRawRepresentableArrayPreference: PreferenceProtocol {

    static let key = "TestRawRepresentableArrayPreference"

    static let defaultValue: TestRawRepresentable<Array<String>> = TestRawRepresentable(rawValue: ["One", "Two"])
}
