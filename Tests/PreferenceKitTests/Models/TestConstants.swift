import PreferenceKit

enum TestConstants {

    static let codablePreferences: Array<any PreferenceProtocol.Type> = [
        TestArrayCodablePreference.self,
        TestCodablePreference.self,
        TestOptionalBoolPreference.self,
    ]

    static let invalidCodablePreferences: Array<any PreferenceProtocol.Type> = [
        TestInvalidCodablePreference.self,
    ]

    static let primitivePreferences: Array<any PreferenceProtocol.Type> = [
        TestArrayBoolPreference.self,
        TestArrayStringPreference.self,
        TestBoolPreference.self,
        TestDictionaryStringArrayStringPreference.self,
        TestDictionaryStringBoolPreference.self,
        TestDoublePreference.self,
        TestFloatPreference.self,
        TestStringPreference.self,
    ]

    static let rawValuePreferences: Array<any PreferenceProtocol.Type> = [
        TestCodableRawRepresentablePreference.self,
        TestRawRepresentableArrayPreference.self,
        TestRawRepresentableDictionaryPreference.self,
    ]

    // does not include `invalidCodablePreferences` as those explicitly fail coding.
    static var preferences: Array<any PreferenceProtocol.Type> {
        var preferences: Array<any PreferenceProtocol.Type> = []
        preferences.append(contentsOf: Self.codablePreferences)
        preferences.append(contentsOf: Self.primitivePreferences)
        preferences.append(contentsOf: Self.rawValuePreferences)
        return preferences
    }

    static let rawValuePairs: Array<any PreferenceValuePairProtocol> = [
        PreferenceValuePair<TestCodableRawRepresentablePreference>(value: TestCodableRawRepresentable(rawValue: "SomeUpdatedValue")),
        PreferenceValuePair<TestRawRepresentableArrayPreference>(value: TestRawRepresentable(rawValue: ["SomeUpdatedValue"])),
        PreferenceValuePair<TestRawRepresentableDictionaryPreference>(value: TestRawRepresentable(rawValue: ["SomeUpdatedValue": 1])),
    ]

    static let somePrimitiveValue: String = "SomePrimitiveValue"
}
