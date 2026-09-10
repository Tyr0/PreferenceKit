
import PreferenceKit

enum TestArrayBoolPreference: PreferenceProtocol {

    static let key: String = "TestArrayBoolPreference"

    static let defaultValue: Array<Bool> = [false, true]
}
