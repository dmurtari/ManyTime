//
//  ContentView.swift
//  SharedMoment
//
//  Created by Domenic Murtari on 1/30/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var timeZoneManager: TimeZoneManager
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack {
            List {
                ForEach(timeZoneManager.savedTimeZones) { item in
                    EditTimeZoneRow(
                        timeZone: item.timeZoneObject,
                        displayName: item.displayName
                    ) { newName in
                        timeZoneManager.updateDisplayName(for: item.id, newName: newName)
                    }
                }
                .onDelete(perform: timeZoneManager.removeTimeZone)
            }

            HStack {
                Spacer()
                Button(action: {
                    openWindow(id: "timezone-picker")
                }) {
                    Image(systemName: "plus")
                }
                .help("Add Time Zone")
            }
            .padding(.horizontal)
        }
        .frame(minWidth: 300, minHeight: 400)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    openWindow(id: "timezone-picker")
                }) {
                    Image(systemName: "plus")
                }
            }

            ToolbarItem(placement: .automatic) {
                Button(action: {
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                }) {
                    Image(systemName: "gear")
                }
            }
        }
        .navigationTitle("Time Zones")
        .navigationSubtitle("\(timeZoneManager.savedTimeZones.count) zones")
    }
}
#Preview {
    ContentView(timeZoneManager: TimeZoneManager())
}
