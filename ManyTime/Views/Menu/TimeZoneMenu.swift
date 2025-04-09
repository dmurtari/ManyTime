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
        VStack(spacing: 0) {
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

            HStack {
                SettingsLink {
                    Image(systemName: "gear")
                }
                .keyboardShortcut(",", modifiers: .command)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding([.all], 7)
            .keyboardShortcut("q", modifiers: .command)
        }
    }
}

#Preview {
    TimeZoneMenu()
        .environment(TimeManager())
        .environment(TimeZoneManager())
}
