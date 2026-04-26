//
//  MenuBarTimeView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/04/17.
//

import SwiftUI

struct MenuBarTimeView: View {
  @Environment(TimeManager.self) private var timeManager

  var timeZoneItem: TimeZoneItem

  var body: some View {
    Text(
      TimeFormatterService.shared.appTimeFormat(
        from: timeManager.currentDate,
        timeZone: timeZoneItem.timeZoneObject
      )
    )
  }
}

#Preview {
  MenuBarTimeView(
    timeZoneItem: TimeZoneItem(
      timeZone: TimeZone.current,
      displayName: "Current"
    )
  )
  .environment(TimeManager())
}
