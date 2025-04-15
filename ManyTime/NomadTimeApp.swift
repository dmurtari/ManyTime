import SwiftUI

@main
struct TimeZoneApp: App {
    @StateObject private var timeZoneManager = TimeZoneManager()
    @StateObject private var timeManager = TimeManager()

    var body: some Scene {
        MenuBarExtra {
            TimeZoneMenu()
                .environment(timeManager)
                .environmentObject(timeZoneManager)
        } label: {
            MenuBarView()
                .environment(timeManager)
                .environmentObject(timeZoneManager)
        }
        .menuBarExtraStyle(.window)
        .environment(timeManager)
        .environmentObject(timeZoneManager)

        Settings {
            SettingsView()
                .frame(minWidth: 350)
                .fixedSize(horizontal: false, vertical: true)
        }
        .environment(timeManager)
        .environmentObject(timeZoneManager)
    }
}
