//
//  GeneralSettingsView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/23/25.
//

import SwiftUI

struct GeneralSettingsView: View {
  @StateObject private var preferences = AppPreferences.shared

  @State private var selectedPresetFormat: String = ""

  private let presetFormats: [String] = ["hh:mm a", "HH:mm", "MM/dd hh:mm a", "MM/dd HH:mm"]

  var body: some View {
    VStack(spacing: 16) {
      VStack(alignment: .leading) {
        Text("General")
          .font(.system(size: 14, weight: .bold))
        Divider()

        VStack(alignment: .leading, spacing: 8) {
          HStack {
            Picker("Format", selection: $selectedPresetFormat) {
              Text("1:23 PM").tag(presetFormats[0])
              Text("13:23").tag(presetFormats[1])
              Text("Custom").tag("")
            }
            .onChange(of: selectedPresetFormat) { _, newValue in
              if !selectedPresetFormat.isEmpty {
                preferences.dropdownTimeFormat = newValue
              }
            }

            if selectedPresetFormat.isEmpty {
              TextField("Format", text: $preferences.dropdownTimeFormat)
            }
          }

          Text("The time format to use in the Popup Window")
            .font(.callout)
            .foregroundStyle(.secondary)
        }
        .padding([.top], 6)

        VStack(alignment: .leading, spacing: 8) {
          Toggle("Show Time Bar", isOn: $preferences.showTimeBar)
          Text("Help compare times across timezones with a visual bar")
            .font(.callout)
            .foregroundStyle(.secondary)
        }
        .padding([.top], 6)

        VStack(alignment: .leading, spacing: 8) {
          Toggle("Always list a non-device timezone first", isOn: $preferences.demoteCurrentTimezoneInList)
          Text("When the device timezone is first in the list, move it down so the next timezone is first")
            .font(.callout)
            .foregroundStyle(.secondary)
        }
        .padding([.top], 6)

        VStack(alignment: .leading, spacing: 8) {
          Toggle("Launch at login", isOn: $preferences.launchOnLogin)
          Text("Automatically start when you login to your Mac")
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
  GeneralSettingsView()
    .environment(TimeManager())
}
