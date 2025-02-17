//
//  TimeZoneMenu.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import SwiftUI

struct TimeZoneMenu: View {
    @ObservedObject var timeZoneManager: TimeZoneManager
    @Environment(\.openWindow) private var openWindow
    @State private var date = Date()

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if timeZoneManager.savedTimeZones.isEmpty {
                Text("No Time Zones Added")
                    .foregroundColor(.secondary)
            } else {
                ForEach(timeZoneManager.savedTimeZones) { item in
                    TimeRowView(timeZone: item)
                }
            }

            Divider()

            Button("Add Time Zone...") {
                openWindow(id: "timezone-picker")
            }
            .keyboardShortcut("n", modifiers: .command)

            if !timeZoneManager.savedTimeZones.isEmpty {
                Button("Edit Time Zones...") {
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
        .onReceive(timer) { _ in
            date = Date()
        }
    }
}

#Preview {
    TimeZoneMenu(timeZoneManager: TimeZoneManager())
}
