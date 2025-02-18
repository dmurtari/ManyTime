import SwiftUI

@main
struct TimeZoneApp: App {
    @StateObject private var timeZoneManager = TimeZoneManager()
    @StateObject private var timeManager = TimeManager()

    var body: some Scene {
        MenuBarExtra {
            TimeZoneMenu(timeZoneManager: timeZoneManager)
                .environment(timeManager)
        } label: {
            MenuBarView(timeZoneManager: timeZoneManager)
                .environment(timeManager)
        }
        .menuBarExtraStyle(.window)
        .environment(timeManager)


        TimeZonePickerWindow(onSave: { timeZone, displayName in
            timeZoneManager.addTimeZone(timeZone, displayName: displayName)
        })

        EditTimeZonesWindow(timeZoneManager: timeZoneManager)
            .environment(timeManager)

        Settings {
            PreferencesView()
        }
    }
}
