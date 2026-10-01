import PreferenceKit
import PreferenceKit_SwiftUI
import SwiftUI

struct TestView<Preferences>: View where Preferences: PreferencesProtocol {

    // MARK: - Properties

    @Preference<Preferences, TestPreference>
    private var preference: Bool

    // MARK: - Lifecycle Functions

    init(preferences: Preferences) {
        self._preference = Preference(preferences: preferences)
    }

    // MARK: - View Conformance

    var body: some View {
        EmptyView()
            .sheet(isPresented: self._preference.projectedValue, onDismiss: {
                self.preference = false
            }) {
                EmptyView()
            }
    }
}
