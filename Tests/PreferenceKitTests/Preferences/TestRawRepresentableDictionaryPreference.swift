import PreferenceKit

enum TestRawRepresentableDictionaryPreference: PreferenceProtocol {

    static let key = "TestRawRepresentableDictionaryPreference"

    static let defaultValue: TestRawRepresentable<Dictionary<String, Int>> = TestRawRepresentable(rawValue: ["One": 1, "Two": 2])
}
