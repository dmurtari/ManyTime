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

        Window("Settings", id: "settings") {
            SettingsView()
                .frame(minWidth: 350, minHeight: 300)
                .padding([.vertical], 12)
                .environmentObject(timeManager)
                .environmentObject(timeZoneManager)
        }
        .windowResizability(.contentMinSize)
        .windowIdealSize(.fitToContent)
        .defaultPosition(.center)
    }
}
