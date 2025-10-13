//
//  MenuBarView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import SwiftUI
import Combine

struct MenuBarView: View {
    @EnvironmentObject private var timeZoneManager: TimeZoneManager
    @EnvironmentObject private var timeManager: TimeManager

    var body: some View {
        if let primaryZone = timeZoneManager.savedTimeZones.first {
            MenuBarTimeView(timeZoneItem: primaryZone)
        } else {
            Image(systemName: "clock")
        }
    }
}

#Preview {
    MenuBarView()
        .environmentObject(TimeManager())
        .environmentObject(TimeZoneManager())
        .frame(width: 250, height: 50)
}

