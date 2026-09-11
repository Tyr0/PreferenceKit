
import Foundation
import Observation
import Testing

@testable import PreferenceKit

@Suite
struct UserPreferencesTests {

    @Test
    func testEmptyReadOptional_WriteNil_ReadNil() async throws {
        func projection<Preference, Wrapped>(_ preference: Preference.Type) async throws where Preference: PreferenceProtocol, Preference.Value == Optional<Wrapped> {
            try await withUserPreferences { userPreferences in
                let userDefaults = userPreferences.userDefaults

                let existingValue = userDefaults.object(forKey: Preference.key)
                #expect(existingValue == nil)

                let defaultValue = try userPreferences.value(forPreference: Preference.self)
                #expect(defaultValue == Preference.defaultValue)

                try userPreferences.updateValue(nil, forPreference: Preference.self)

                defer { userPreferences.removeValue(forPreference: Preference.self) }

                let preferenceValue = try userPreferences.value(forPreference: Preference.self)
                #expect(preferenceValue == nil)
            }
        }

        try await projection(TestOptionalBoolPreference.self)
    }

    @Test(arguments: TestConstants.preferences)
    func testEmptyRead_ReturnsDefaultValue(_ preference: any PreferenceProtocol.Type) async throws {
        func projection<Preference>(_ preference: Preference.Type) async throws where Preference: PreferenceProtocol {
            try await withUserPreferences { userPreferences in
                let userDefaults = userPreferences.userDefaults

                let existingValue = userDefaults.object(forKey: Preference.key)
                #expect(existingValue == nil)

                let preferenceValue = try userPreferences.value(forPreference: Preference.self)
                #expect(preferenceValue == Preference.defaultValue)
            }
        }

        try await projection(preference)
    }

    @Test
    func testWrite_Read_Codable_ReturnsValue() async throws {
        let value = TestCodable()
        #expect(value != TestCodablePreference.defaultValue)

        try await withUserPreferences { userPreferences in
            try userPreferences.updateValue(value, forPreference: TestCodablePreference.self)

            defer {
                userPreferences.removeValue(forPreference: TestCodablePreference.self)
            }

            let existingValue = try userPreferences.value(forPreference: TestCodablePreference.self)
            #expect(existingValue == value)
        }
    }

    @Test(arguments: TestConstants.primitivePreferences)
    func testWrite_UserDefaultsValue(_ preference: any PreferenceProtocol.Type) async throws {
        func projection<Preference>(_ preference: Preference.Type) async throws where Preference: PreferenceProtocol {
            try await withUserPreferences { userPreferences in
                let userDefaults = userPreferences.userDefaults

                let existingValue = userDefaults.object(forKey: Preference.key)
                #expect(existingValue == nil)

                try userPreferences.updateValue(preference.defaultValue, forPreference: Preference.self)

                defer {
                    userPreferences.removeValue(forPreference: Preference.self)
                }

                let insertedValue = try #require(userDefaults.object(forKey: Preference.key) as? Preference.Value)
                #expect(insertedValue == Preference.defaultValue)
            }
        }

        try await projection(preference)
    }

    @Test(arguments: TestConstants.preferences)
    func testEmptyRead_Update_Delete(_ preference: any PreferenceProtocol.Type) async throws {
        func projection<Preference>(_ preference: Preference.Type) async throws where Preference: PreferenceProtocol {
            try await withUserPreferences { userPreferences in
                let userDefaults = userPreferences.userDefaults

                let existingValue = userDefaults.object(forKey: Preference.key)
                #expect(existingValue == nil)

                try userPreferences.updateValue(Preference.defaultValue, forPreference: Preference.self)

                let updatedValue = userDefaults.object(forKey: Preference.key)
                #expect(updatedValue != nil)

                userPreferences.removeValue(forPreference: Preference.self)

                let removedValue = userDefaults.object(forKey: Preference.key)
                #expect(removedValue == nil)
            }
        }

        try await projection(preference)
    }

    @Suite
    struct CodableTests {

        @Test(arguments: TestConstants.codablePreferences)
        func testRead_InvalidValue_ThrowsDecodingError(_ preference: any PreferenceProtocol.Type) async throws {
            func projection<Preference>(_ preference: Preference.Type) async throws where Preference: PreferenceProtocol {
                await withUserPreferences { userPreferences in
                    let userDefaults = userPreferences.userDefaults

                    let existingValue = userDefaults.object(forKey: Preference.key)
                    #expect(existingValue == nil)

                    userDefaults.set(TestConstants.somePrimitiveValue, forKey: Preference.key)

                    defer { userDefaults.removeObject(forKey: Preference.key) }

                    #expect(throws: DecodingError.self) {
                        try userPreferences.value(forPreference: Preference.self)
                    }

                    let subscriptValue = userPreferences[Preference.self]
                    #expect(subscriptValue == Preference.defaultValue)

                    let persistedValue = userDefaults.string(forKey: Preference.key)
                    #expect(persistedValue == TestConstants.somePrimitiveValue)
                }
            }

            try await projection(preference)
        }

        @Test(arguments: TestConstants.invalidCodablePreferences)
        func testWrite_InvalidValue_ThrowsEncodingError(_ preference: any PreferenceProtocol.Type) async throws {
            func projection<Preference>(_ preference: Preference.Type) async throws where Preference: PreferenceProtocol {
                await withUserPreferences { userPreferences in
                    let userDefaults = userPreferences.userDefaults

                    let existingValue = userDefaults.object(forKey: Preference.key)
                    #expect(existingValue == nil)

                    #expect(throws: EncodingError.self) {
                        try userPreferences.updateValue(Preference.defaultValue, forPreference: Preference.self)
                    }

                    let subscriptValue = userPreferences[Preference.self]
                    #expect(subscriptValue == Preference.defaultValue)

                    let persistedValue = userDefaults.object(forKey: Preference.key)
                    #expect(persistedValue == nil)
                }
            }

            try await projection(preference)
        }
    }

    @Suite
    struct ObservationTests {

        @Test(arguments: TestConstants.preferences)
        func testEmpty_Read_Delete_DoesNotObserve(_ preference: any PreferenceProtocol.Type) async throws {
            func projection<Preference>(_ preference: Preference.Type) async throws where Preference: PreferenceProtocol {
                await withUserPreferences { userPreferences in
                    let userDefaults = userPreferences.userDefaults

                    let existingValue = userDefaults.object(forKey: Preference.key)
                    #expect(existingValue == nil)

                    await confirmation(expectedCount: 0) { confirmation in
                        withObservationTracking({
                            #expect(throws: Never.self) {
                                try userPreferences.value(forPreference: Preference.self)
                            }
                        }, onChange: {
                            confirmation()
                        })

                        userPreferences.removeValue(forPreference: Preference.self)
                    }
                }
            }

            try await projection(preference)
        }

        @Test(arguments: TestConstants.preferences)
        func testEmpty_Delete_Delete_DoesNotObserve(_ preference: any PreferenceProtocol.Type) async throws {
            func projection<Preference>(_ preference: Preference.Type) async throws where Preference: PreferenceProtocol {
                await withUserPreferences { userPreferences in
                    let userDefaults = userPreferences.userDefaults

                    let existingValue = userDefaults.object(forKey: Preference.key)
                    #expect(existingValue == nil)

                    await confirmation(expectedCount: 0) { confirmation in
                        withObservationTracking({
                            userPreferences.removeValue(forPreference: Preference.self)
                        }, onChange: {
                            confirmation()
                        })

                        userPreferences.removeValue(forPreference: Preference.self)
                    }
                }
            }

            try await projection(preference)
        }

        @Test(arguments: TestConstants.preferences)
        func testEmpty_Update_Read_Delete_Observes(_ preference: any PreferenceProtocol.Type) async throws {
            func projection<Preference>(_ preference: Preference.Type) async throws where Preference: PreferenceProtocol {
                try await withUserPreferences { userPreferences in
                    let userDefaults = userPreferences.userDefaults

                    let existingValue = userDefaults.object(forKey: Preference.key)
                    #expect(existingValue == nil)

                    try userPreferences.updateValue(Preference.defaultValue, forPreference: Preference.self)

                    await confirmation { confirmation in
                        withObservationTracking({
                            #expect(throws: Never.self) {
                                try userPreferences.value(forPreference: Preference.self)
                            }
                        }, onChange: {
                            confirmation()
                        })

                        userPreferences.removeValue(forPreference: Preference.self)
                    }
                }
            }

            try await projection(preference)
        }

        @Test(arguments: TestConstants.preferences)
        func testEmpty_Update_Delete_DoesNotObserve(_ preference: any PreferenceProtocol.Type) async throws {
            func projection<Preference>(_ preference: Preference.Type) async throws where Preference: PreferenceProtocol {
                await withUserPreferences { userPreferences in
                    let userDefaults = userPreferences.userDefaults

                    let existingValue = userDefaults.object(forKey: Preference.key)
                    #expect(existingValue == nil)

                    await confirmation(expectedCount: 0) { confirmation in
                        withObservationTracking({
                            #expect(throws: Never.self) {
                                try userPreferences.updateValue(Preference.defaultValue, forPreference: Preference.self)
                            }
                        }, onChange: {
                            confirmation()
                        })

                        userPreferences.removeValue(forPreference: Preference.self)
                    }
                }
            }

            try await projection(preference)
        }

        @Test(arguments: TestConstants.preferences)
        func testEmpty_Read_Update_Observes(_ preference: any PreferenceProtocol.Type) async throws {
            func projection<Preference>(_ preference: Preference.Type) async throws where Preference: PreferenceProtocol {
                try await withUserPreferences { userPreferences in
                    let userDefaults = userPreferences.userDefaults

                    let existingValue = userDefaults.object(forKey: Preference.key)
                    #expect(existingValue == nil)

                    try await confirmation { confirmation in
                        withObservationTracking({
                            #expect(throws: Never.self) {
                                try userPreferences.value(forPreference: Preference.self)
                            }
                        }, onChange: {
                            confirmation()
                        })

                        try userPreferences.updateValue(Preference.defaultValue, forPreference: Preference.self)
                    }

                    userDefaults.removeObject(forKey: Preference.key)
                }
            }

            try await projection(preference)
        }

        @Test(arguments: TestConstants.preferences)
        func testEmpty_Read_UpdateViaUserDefaults_Observes(_ preference: any PreferenceProtocol.Type) async throws {
            func projection<Preference>(_ preference: Preference.Type) async throws where Preference: PreferenceProtocol {
                await withUserPreferences { userPreferences in
                    let userDefaults = userPreferences.userDefaults

                    let existingValue = userDefaults.object(forKey: Preference.key)
                    #expect(existingValue == nil)

                    await confirmation { confirmation in
                        withObservationTracking({
                            #expect(throws: Never.self) {
                                try userPreferences.value(forPreference: Preference.self)
                            }
                        }, onChange: {
                            confirmation()
                        })

                        userDefaults.set(TestConstants.somePrimitiveValue, forKey: Preference.key)
                    }

                    userDefaults.removeObject(forKey: Preference.key)
                }
            }

            try await projection(preference)
        }

        @Test(arguments: TestConstants.preferences)
        func testEmpty_Update_Read_UpdateSameValue_DoesNotObserve(_ preference: any PreferenceProtocol.Type) async throws {
            func projection<Preference>(_ preference: Preference.Type) async throws where Preference: PreferenceProtocol {
                try await withUserPreferences { userPreferences in
                    let userDefaults = userPreferences.userDefaults

                    let existingValue = userDefaults.object(forKey: Preference.key)
                    #expect(existingValue == nil)

                    try userPreferences.updateValue(Preference.defaultValue, forPreference: Preference.self)

                    try await confirmation(expectedCount: 0) { confirmation in
                        withObservationTracking({
                            #expect(throws: Never.self) {
                                try userPreferences.value(forPreference: Preference.self)
                            }
                        }, onChange: {
                            confirmation()
                        })

                        try userPreferences.updateValue(Preference.defaultValue, forPreference: Preference.self)
                    }

                    userDefaults.removeObject(forKey: Preference.key)
                }
            }

            try await projection(preference)
        }
    }
}

private func withUserPreferences<Failure, Result>(perform body: (_ userPreferences: consuming UserPreferences) async throws(Failure) -> Result) async throws(Failure) -> Result {
    let suiteName = "\(_typeName(UserPreferencesTests.self))-\(UUID().uuidString)"

    guard let userDefaults = UserDefaults(suiteName: suiteName) else {
        fatalError("Failed to create temporary UserDefaults suite.")
    }

    defer {
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    let userPreferences = UserPreferences(userDefaults: userDefaults)
    #expect(userPreferences.userDefaults == userDefaults)

    return try await body(userPreferences)
}
