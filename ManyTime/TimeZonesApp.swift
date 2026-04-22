import Combine
import SwiftUI

@main
struct TimeZonesApp: App {
  @State private var timeManager = TimeManager()
  @StateObject private var timeZoneManager = TimeZoneManager()

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

    Window("", id: "settings") {
      SettingsView()
        .environment(timeManager)
        .environmentObject(timeZoneManager)
    }
    .windowResizability(.contentSize)
    .windowIdealSize(.fitToContent)
    .defaultPosition(.center)
  }
}
