import PreferenceKit

protocol PreferenceValuePairProtocol: Sendable {

    associatedtype Preference: PreferenceProtocol

    typealias Value = Preference.Value

    var value: Value { get }
}

struct PreferenceValuePair<Preference>: PreferenceValuePairProtocol where Preference: PreferenceProtocol {

    // MARK: - Properties

    var value: Value

    // MARK: - Lifecycle Functions

    init(_ item: Value.Type = Value.self, value: Value) {
        self.value = value
    }
}
