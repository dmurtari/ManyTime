//
//  IOSSettingsView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2026/11/08.
//

import SwiftUI

#if os(iOS)
struct IOSSettingsView: View {
  @StateObject private var preferences = AppPreferences.shared

  @State private var selectedPresetFormat: String = ""

  private let presetFormats: [String] = ["hh:mm a", "HH:mm"]

  var body: some View {
    Form {
      Section {
        Picker("Format", selection: $selectedPresetFormat) {
          Text("1:23 PM").tag(presetFormats[0])
          Text("13:23").tag(presetFormats[1])
          Text("Custom").tag("")
        }
        .onChange(of: selectedPresetFormat) { _, newValue in
          if !newValue.isEmpty {
            preferences.dropdownTimeFormat = newValue
          }
        }

        if selectedPresetFormat.isEmpty {
          LabeledContent("Custom Format") {
            TextField("Format", text: $preferences.dropdownTimeFormat)
              .multilineTextAlignment(.trailing)
              .textInputAutocapitalization(.never)
              .autocorrectionDisabled()
          }
        }
      } footer: {
        Text("The time format to use for each time zone in the list")
      }

      Section {
        Toggle("Non-device time zone first", isOn: $preferences.demoteCurrentTimezoneInList)
      } footer: {
        Text("When the device time zone is first in the list, move it down so the next time zone is first.")
      }
    }
    .onAppear {
      if presetFormats.contains(preferences.dropdownTimeFormat) {
        selectedPresetFormat = preferences.dropdownTimeFormat
      }
    }
  }
}

#Preview {
  NavigationStack {
    IOSSettingsView()
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
  }
}
#endif
