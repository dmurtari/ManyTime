//
//  MenuBarSettingsView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2026/05/16.
//

import SwiftUI

struct MenuBarSettingsView: View {
  @StateObject private var preferences = AppPreferences.shared

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
          Text("The time format to use in the Popup Window (use `{name}` to include the timezone name)")
            .font(.callout)
            .foregroundStyle(.secondary)
        }
        .padding([.top], 6)
        .padding([.bottom], 12)
      }
    }
    .onAppear {
      if presetFormats.contains(preferences.menuBarTimeFormat) {
        selectedPresetFormat = preferences.menuBarTimeFormat
      }
    }
  }
}

#Preview {
  MenuBarSettingsView()
    .environment(TimeManager())
}
