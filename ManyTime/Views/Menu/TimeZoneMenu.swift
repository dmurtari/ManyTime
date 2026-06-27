//
//  TimeZoneMenu.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import SwiftUI

struct TimeZoneMenu: View {
  @Environment(TimeManager.self) private var timeManager
  @EnvironmentObject private var timeZoneManager: TimeZoneManager

  var body: some View {
    VStack(spacing: 0) {
      if timeZoneManager.savedTimeZones.isEmpty {
        VStack(alignment: .leading, spacing: 16) {
          Text("Nothing to show yet!")
            .font(.callout)

          Text("Click Options > Preferences to get started by adding a Time Zone")
            .foregroundColor(.secondary)
            .font(.callout)
        }
        .padding()
      } else {
        TimeListView()
          .padding()
      }

      ControlsRowView()
        .padding([.bottom], 12)
        .padding([.horizontal])
    }
  }
}

#Preview {
  TimeZoneMenu()
    .frame(width: 300)
    .environment(TimeManager())
    .environmentObject(TimeZoneManager())
}
