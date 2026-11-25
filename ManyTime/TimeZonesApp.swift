import Combine
import SwiftUI

@main
struct TimeZonesApp: App {
  @State private var timeManager = TimeManager()
  @StateObject private var timeZoneManager = TimeZoneManager(
    saveKey: ProcessInfo.processInfo.environment["MANYTIME_UI_TEST_SAVE_KEY"] ?? "SavedTimeZones"
  )

  var body: some Scene {
#if os(macOS)
    MenuBarExtra {
      TimeZoneMenu()
        .environment(timeManager)
        .environmentObject(timeZoneManager)
        .onAppear {
          timeManager.cancelMenuReset()
        }
        .onDisappear {
          let preferences = AppPreferences.shared
          let delay = preferences.menuResetEnabled
            ? TimeInterval(max(0, preferences.menuResetDelayMinutes)) * 60
            : nil
          timeManager.scheduleMenuReset(after: delay)
        }
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

    Window("", id: "about") {
      AboutView()
    }
    .windowResizability(.contentSize)
    .windowIdealSize(.fitToContent)
    .defaultPosition(.center)

#else
    WindowGroup {
      MainIOSView()
        .environment(timeManager)
        .environmentObject(timeZoneManager)
    }
#endif
  }
}
