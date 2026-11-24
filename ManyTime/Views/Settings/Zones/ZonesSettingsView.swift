//
//  ZonesSettingsView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/23/25.
//

import SwiftUI

struct ZonesSettingsView: View {
  @EnvironmentObject var timeZoneManager: TimeZoneManager
  @StateObject private var preferences = AppPreferences.shared

  var body: some View {
    VStack(spacing: 16) {
      VStack(alignment: .leading, spacing: 8) {
        Text("Device Time Zone")
          .font(.system(size: 14, weight: .bold))
        Divider()
        Toggle("Show device time zone", isOn: Binding(
          get: { preferences.showDeviceTimeZone },
          set: { timeZoneManager.setDeviceTimeZoneVisible($0) }
        ))
        Text("Always show a row with the device’s current time zone")
          .font(.callout)
          .foregroundStyle(.secondary)
      }

      VStack(alignment: .leading) {
        Text("Active Time Zones")
          .font(.system(size: 14, weight: .bold))

        Divider()

        TimeZoneListView()
      }

      VStack(alignment: .leading) {
        Text("Add New")
          .font(.system(size: 14, weight: .bold))

        Divider()

        TimeZoneAddView()
          .padding([.vertical], 6)
      }
    }
    .frame(width: Constants.AppViewConstants.timeMenuWidth)
  }
}

#Preview {
  ZonesSettingsView()
    .environmentObject(TimeZoneManager())
    .environment(TimeManager())
}
