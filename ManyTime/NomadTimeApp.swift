import SwiftUI

@main
struct TimeZoneApp: App {
    @StateObject private var timeZoneManager = TimeZoneManager()
    @StateObject private var timeManager = TimeManager()

    var body: some Scene {
        MenuBarExtra {
            TimeZoneMenu()
                .environment(timeManager)
                .environment(timeZoneManager)
        } label: {
            MenuBarView()
                .environment(timeManager)
                .environment(timeZoneManager)
        }
        .menuBarExtraStyle(.window)
        .environment(timeManager)
        .environment(timeZoneManager)

        Settings {
            SettingsView()
                .frame(minWidth: 350)
                .fixedSize(horizontal: false, vertical: true)
        }
        .environment(timeManager)
        .environment(timeZoneManager)
    }
}
