
import SwiftUI
import Testing

@testable import PreferenceKit
@testable import PreferenceKit_SwiftUI

@MainActor @Suite
struct PreferenceTests {

    @Test
    func testBindingCompilation() async throws {
        let preferences = UserPreferences.default

        let view = TestView(preferences: preferences)

        _ = view.body
    }
}
