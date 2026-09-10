
import PreferenceKit

enum TestArrayCodablePreference: PreferenceProtocol {

    static let key: String = "TestArrayCodablePreference"

    static let defaultValue: Array<TestCodable> = [TestCodable(), TestCodable(), TestCodable()]
}
