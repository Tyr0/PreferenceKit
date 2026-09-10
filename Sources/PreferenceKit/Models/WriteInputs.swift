
import Foundation

public struct _WriteInputs: Sendable {

    // MARK: - Properties

    // TODO: document safety
    nonisolated(unsafe) internal let userDefaults: UserDefaults

    internal let encoder: JSONEncoder
}
