
import PreferenceKit

enum TestDictionaryStringBoolPreference: PreferenceProtocol {

    static let key: String = "TestDictionaryStringBoolPreference"

    static let defaultValue: Dictionary<String, Bool> = [
        "Foo": true,
        "Bar": false,
    ]
}
