import PreferenceKit

enum TestDictionaryStringArrayStringPreference: PreferenceProtocol { // swiftlint:disable:this type_name

    static let key: String = "TestDictionaryStringArrayStringPreference"

    static let defaultValue: Dictionary<String, Array<String>> = [
        "Alice": ["Bob"],
        "Foo": ["Bar"],
    ]
}
