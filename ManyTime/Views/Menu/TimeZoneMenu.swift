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

  @StateObject private var preferences = AppPreferences.shared
  @State private var timeViewPosition: TimeViewPosition = .init()

  var body: some View {
    VStack(spacing: 0) {
      if timeZoneManager.displayedTimeZones.isEmpty {
        VStack(alignment: .leading, spacing: 16) {
          Text("Nothing to show yet!")
            .font(.callout)

          Text("Click Options > Preferences to get started by adding a Time Zone")
            .foregroundColor(.secondary)
            .font(.callout)
        }
        .padding()
      } else {
        VStack(spacing: 16) {
          ForEach(timeZoneManager.displayedTimeZones.enumerated(), id: \.offset) { index, timeZone in
            TimeView(timeZone: timeZone, index: index)
          }

          if (preferences.showTimeBar && preferences.showRockerControls) {
            TimeRockerControl()
              .padding(.top, 8)
          }
        }
        .environment(timeViewPosition)
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
