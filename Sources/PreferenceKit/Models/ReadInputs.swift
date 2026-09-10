
import Foundation

public struct _ReadInputs: Sendable {

    // MARK: - Properties

    // TODO: document safety
    nonisolated(unsafe) internal let userDefaults: UserDefaults

    internal let decoder: JSONDecoder
}
