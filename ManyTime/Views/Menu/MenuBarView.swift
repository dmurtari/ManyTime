//
//  MenuBarView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import Combine
import SwiftUI

struct MenuBarView: View {
  @EnvironmentObject private var timeZoneManager: TimeZoneManager
  @Environment(TimeManager.self) private var timeManager

  var body: some View {
    if let primaryZone = timeZoneManager.displayedTimeZones.first {
      MenuBarTimeView(timeZoneItem: primaryZone)
    } else {
      Image(systemName: "clock")
    }
  }
}

#Preview {
  MenuBarView()
    .environment(TimeManager())
    .environmentObject(TimeZoneManager())
    .frame(width: 250, height: 50)
}
