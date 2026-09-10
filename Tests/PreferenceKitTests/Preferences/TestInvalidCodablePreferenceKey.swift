
import PreferenceKit

enum TestInvalidCodablePreference: PreferenceProtocol {

    static let key: String = "TestInvalidCodablePreference"

    static let defaultValue: TestInvalidCodable = TestInvalidCodable()
}
