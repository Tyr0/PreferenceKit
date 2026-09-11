
import Testing

@testable import PreferenceKit

@Suite
struct PreferenceTests {

    @Test(arguments: TestConstants.primitivePreferences)
    func testEmpty_Read_DefaultValue(_ preference: any PreferenceProtocol.Type) async throws {
        func projection<Preference>(_ preference: Preference.Type) async throws where Preference: PreferenceProtocol {
            let preferences = MockPreferences()

            let preference = PreferenceKit.Preference(Preference.self, preferences: preferences)

            let preferenceValue = preference.wrappedValue
            #expect(preferenceValue == Preference.defaultValue)
        }

        try await projection(preference)
    }

    @Test
    func testEmpty_Read_Write_Read_CustomValue() async throws {
        let preferences = MockPreferences()

        let preference = Preference(TestStringPreference.self, preferences: preferences)

        let preferenceValue = preference.wrappedValue
        #expect(preferenceValue == TestStringPreference.defaultValue)

        preference.wrappedValue = "ValidValue"

        let remainingValue = preference.wrappedValue
        #expect(remainingValue == "ValidValue")
    }

    @Test
    func testInitialValue_Read_CustomValue() async throws {
        let preferences = MockPreferences([
            TestStringPreference.key: "ValidValue",
        ])

        let preference = Preference(TestStringPreference.self, preferences: preferences)

        let preferenceValue = preference.wrappedValue
        #expect(preferenceValue == "ValidValue")
    }

    @Test
    func testInitialValue_Read_Delete_DefaultValue() async throws {
        let preferences = MockPreferences([
            TestStringPreference.key: "ValidValue",
        ])

        let preference = Preference(TestStringPreference.self, preferences: preferences)

        let preferenceValue = preference.wrappedValue
        #expect(preferenceValue == "ValidValue")

        preferences.removeValue(forPreference: TestStringPreference.self)

        let remainingValue = preference.wrappedValue
        #expect(remainingValue == TestStringPreference.defaultValue)
    }
}
