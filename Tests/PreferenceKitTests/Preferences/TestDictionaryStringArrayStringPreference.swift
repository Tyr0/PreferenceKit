
import PreferenceKit

enum TestDictionaryStringArrayStringPreference: PreferenceProtocol {

    static let key: String = "TestDictionaryStringArrayStringPreference"

    static let defaultValue: Dictionary<String, Array<String>> = [
        "Alice": ["Bob"],
        "Foo": ["Bar"],
    ]
}
