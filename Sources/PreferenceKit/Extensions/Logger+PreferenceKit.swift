
internal import os.log

extension Logger {

    private enum Constants {

        static let subsystem = "com.calderone.PreferenceKit"
    }

    internal static let preference = Logger(subsystem: Constants.subsystem, category: "Preference")

    internal static let preferences = Logger(subsystem: Constants.subsystem, category: "Preferences")
}
