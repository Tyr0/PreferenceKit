
import PreferenceKit

enum TestCodablePreference: PreferenceProtocol {

    static let key = "TestCodablePreference"

    static let defaultValue: TestCodable = TestCodable()
}
