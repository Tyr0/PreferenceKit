
import PreferenceKit

enum TestArrayStringPreference: PreferenceProtocol {

    static let key: String = "TestArrayStringPreference"

    static let defaultValue: Array<String> = ["Foo", "Bar"]
}
