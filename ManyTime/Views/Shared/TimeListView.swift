//
//  TimeListView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2026/06/26.
//

import SwiftUI

@Observable
class TimeViewPosition {
  var scrollPositions: [ScrollPosition] = []
  var indexScrolledByUser: Int?
}

struct TimeListView: View {
  @EnvironmentObject private var timeZoneManager: TimeZoneManager
  @State private var timeViewPosition: TimeViewPosition = .init()

  init() {
    timeViewPosition.scrollPositions = Array(
      repeating: ScrollPosition(edge: .leading),
      count: 100
    ) // some big count, just to initialize the array
  }

  var body: some View {
    VStack(spacing: 16) {
      ForEach(timeZoneManager.savedTimeZones.enumerated(), id: \.offset) { index, timeZone in
        TimeView(timeZone: timeZone, index: index)
      }
    }
    .onAppear {
      timeViewPosition.scrollPositions = Array(
        repeating: ScrollPosition(edge: .leading),
        count: timeZoneManager.savedTimeZones.count
      )
    }
    .environment(timeViewPosition)
  }
}

#Preview {
  TimeListView()
    .environmentObject(TimeZoneManager())
    .environment(TimeManager())
}
