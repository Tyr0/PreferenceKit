//
//  TestConstants.swift
//  PreferenceKit
//
//  Created by Tyler Calderone on 9/10/26.
//

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

    // does not include `invalidCodablePreferences` as those explicitly fail coding.
    static var preferences: Array<any PreferenceProtocol.Type> {
        var preferences: Array<any PreferenceProtocol.Type> = []
        preferences.append(contentsOf: Self.codablePreferences)
        preferences.append(contentsOf: Self.primitivePreferences)
        return preferences
    }

    static let somePrimitiveValue: String = "SomePrimitiveValue"
}
