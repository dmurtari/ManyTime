import SwiftUI
import Combine

@main
struct TimeZonesApp: App {
    @StateObject private var timeManager = TimeManager()
    @StateObject private var timeZoneManager = TimeZoneManager()

    var body: some Scene {
        MenuBarExtra {
            TimeZoneMenu()
                .environmentObject(timeManager)
                .environmentObject(timeZoneManager)
        } label: {
            MenuBarView()
                .environmentObject(timeManager)
                .environmentObject(timeZoneManager)
        }
        .menuBarExtraStyle(.window)

        Window("", id: "settings") {
            SettingsView()
                .environmentObject(timeManager)
                .environmentObject(timeZoneManager)
        }
        .windowResizability(.contentSize)
        .windowIdealSize(.fitToContent)
        .defaultPosition(.center)
    }
}
