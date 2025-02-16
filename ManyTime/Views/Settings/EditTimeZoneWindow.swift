//
//  EditTimeZoneWindow.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import SwiftUI

struct EditTimeZonesWindow: Scene {
    @ObservedObject var timeZoneManager: TimeZoneManager

    var body: some Scene {
        Window("Edit Time Zones", id: "edit-timezones") {
            EditTimeZonesView(timeZoneManager: timeZoneManager)
        }
        .defaultSize(width: 300, height: 400)
    }
}

struct EditTimeZonesView: View {
    @ObservedObject var timeZoneManager: TimeZoneManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            ForEach(timeZoneManager.savedTimeZones) { item in
                EditTimeZoneRow(
                    timeZone: item.timeZoneObject,
                    displayName: item.displayName
                ) { newName in
                    timeZoneManager.updateDisplayName(for: item.id, newName: newName)
                }
            }
            .onMove { from, to in
                timeZoneManager.moveTimeZone(from: from, to: to)
            }
            .onDelete { indexSet in
                timeZoneManager.removeTimeZone(at: indexSet)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    NSApp.sendAction(#selector(NSWindow.close), to: nil, from: nil)
                }) {
                    Text("Done")
                }
                .keyboardShortcut(.return)
            }
        }
    }
}

