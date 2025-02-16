import SwiftUI

@main
struct TimeZoneApp: App {
    @StateObject private var timeZoneManager = TimeZoneManager()

    var body: some Scene {
        MenuBarExtra {
            TimeZoneMenu(timeZoneManager: timeZoneManager)
        } label: {
            MenuBarView(timeZoneManager: timeZoneManager)
        }
        .menuBarExtraStyle(.window)

        TimeZonePickerWindow(onSave: { timeZone, displayName in
            timeZoneManager.addTimeZone(timeZone, displayName: displayName)
        })

        EditTimeZonesWindow(timeZoneManager: timeZoneManager)

        Settings {
            PreferencesView()
        }
    }
}
