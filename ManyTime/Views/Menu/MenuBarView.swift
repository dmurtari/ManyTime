//
//  MenuBarView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import SwiftUI

struct MenuBarView: View {
    @ObservedObject var timeZoneManager: TimeZoneManager
    @EnvironmentObject private var timeManager: TimeManager

    @StateObject private var preferences = AppPreferences.shared


    var body: some View {
        if let primaryZone = timeZoneManager.savedTimeZones.first {
            Text(TimeFormatterService.shared.appTimeFormat(
                from: timeManager.displayDate,
                timeZone: primaryZone.timeZoneObject
            ))
              .monospacedDigit()
        } else {
            Image(systemName: "clock")
        }
    }
}

#Preview {
    MenuBarView(timeZoneManager: TimeZoneManager())
}
