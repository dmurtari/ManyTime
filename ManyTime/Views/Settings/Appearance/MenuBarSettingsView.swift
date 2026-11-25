//
//  MenuBarSettingsView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2026/05/16.
//

import SwiftUI

struct MenuBarSettingsView: View {
  @StateObject private var preferences = AppPreferences.shared
  @Environment(TimeManager.self) private var timeManager

  @State private var selectedPresetFormat: String = ""

  private let presetFormats: [String] = [
    "hh:mm a",
    "HH:mm",
    "MM/dd hh:mm a",
    "MM/dd HH:mm",
    "{name}: hh:mm a",
    "{name}: HH:mm",
    "{name}: MM/dd hh:mm a",
    "{name}: MM/dd HH:mm"
  ]

  var body: some View {
    VStack(spacing: 16) {
      VStack(alignment: .leading) {
        Text("Menu Bar")
          .font(.system(size: 14, weight: .bold))
        Divider()

        VStack(alignment: .leading, spacing: 8) {
          HStack {
            Picker("Format", selection: $selectedPresetFormat) {
              Text("1:23 PM").tag(presetFormats[0])
              Text("13:23").tag(presetFormats[1])
              Text("12/31 1:23 PM").tag(presetFormats[2])
              Text("12/31 13:23").tag(presetFormats[3])
              Text("New York: 1:23 PM").tag(presetFormats[4])
              Text("New York: 13:23").tag(presetFormats[5])
              Text("New York: 12/31 1:23 PM").tag(presetFormats[6])
              Text("New York: 12/31 13:23").tag(presetFormats[7])
              Text("Custom").tag("")
            }
            .onChange(of: selectedPresetFormat) { _, newValue in
              if (!selectedPresetFormat.isEmpty) {
                preferences.menuBarTimeFormat = newValue
              }
            }

            if (selectedPresetFormat.isEmpty) {
              TextField("Format", text: $preferences.menuBarTimeFormat)
            }
          }
          Text("The time format shown in the menu bar (use `{name}` to include the time zone name)")
            .font(.callout)
            .foregroundStyle(.secondary)

          VStack(alignment: .leading, spacing: 8) {
            Picker("Time zone", selection: $preferences.showNonDeviceTimezoneInMenuBar) {
              Text("First in list").tag(false)
              Text("First non-device device time zone").tag(true)
            }
            Text("Whether to show the first time in the list in the menu, or to prefer a non-device timezone")
              .font(.callout)
              .foregroundStyle(.secondary)
          }
          .padding([.top], 6)

          VStack(alignment: .leading, spacing: 8) {
            Toggle("Reset to current time when the menu is closed", isOn: $preferences.menuResetEnabled)
            HStack {
              TextField("Delay", value: Binding(
                get: { preferences.menuResetDelayMinutes },
                set: { preferences.menuResetDelayMinutes = min(max(0, $0), Int.max / 60) }
              ), format: .number.grouping(.never))
              .frame(width: 70)
              Text("minutes")
            }
            .disabled(!preferences.menuResetEnabled)
            Text("How long to wait before resetting to current time")
              .font(.callout)
              .foregroundStyle(.secondary)
          }
          .padding([.top], 6)

        }
        .padding([.top], 6)
        .padding([.bottom], 12)
      }
    }
    .onChange(of: preferences.menuResetEnabled) { _, _ in
      updateMenuReset()
    }
    .onChange(of: preferences.menuResetDelayMinutes) { _, _ in
      updateMenuReset()
    }
    .onAppear {
      if presetFormats.contains(preferences.menuBarTimeFormat) {
        selectedPresetFormat = preferences.menuBarTimeFormat
      }
    }
  }

  private func updateMenuReset() {
    let delay = preferences.menuResetEnabled
      ? TimeInterval(max(0, preferences.menuResetDelayMinutes)) * 60
      : nil
    timeManager.updateMenuReset(after: delay)
  }
}

#Preview {
  MenuBarSettingsView()
    .environment(TimeManager())
}
