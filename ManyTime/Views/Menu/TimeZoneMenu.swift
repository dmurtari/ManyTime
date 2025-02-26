//
//  TimeZoneMenu.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import SwiftUI

struct TimeZoneMenu: View {
    @EnvironmentObject private var timeManager: TimeManager
    @EnvironmentObject private var timeZoneManager: TimeZoneManager

    @State private var date = Date()

    var body: some View {
        Group {
            if timeZoneManager.savedTimeZones.isEmpty {
                Text("No Time Zones Added")
                    .foregroundColor(.secondary)
            } else {
                VStack(spacing: 16) {
                    ForEach(timeZoneManager.savedTimeZones) { item in
                        TimeRowView(timeZone: item, date: timeManager.currentDate)
                    }
                }
                .padding()
            }

            Divider()

            SettingsLink {
                Text("Settings...")
            }
            .keyboardShortcut(",", modifiers: .command)

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
    }
}

#Preview {
    TimeZoneMenu()
        .environment(TimeManager())
        .environment(TimeZoneManager())
}
