//
//  TimeZoneMenu.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import SwiftUI

struct TimeZoneMenu: View {
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var timeManager: TimeManager

    @ObservedObject var timeZoneManager: TimeZoneManager

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

            Button("Add Time Zone...") {
                NSApplication.shared.activate(ignoringOtherApps: true)
                openWindow(id: "timezone-picker")
            }
            .keyboardShortcut("n", modifiers: .command)

            if !timeZoneManager.savedTimeZones.isEmpty {
                Button("Edit Time Zones...") {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                    openWindow(id: "edit-timezones")
                }
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
    TimeZoneMenu(timeZoneManager: TimeZoneManager())
        .environment(TimeManager())
}
