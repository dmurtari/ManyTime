//
//  TimeZoneListView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/04/14.
//

import SwiftUI

struct TimeZoneListView: View {
    @EnvironmentObject var timeZoneManager: TimeZoneManager

    var body: some View {
        List {
            ForEach(timeZoneManager.savedTimeZones) { timeZone in
                TimeView(timeZone: timeZone, date: Date())
            }
            .onMove(perform: onMove)
            .onDelete(perform: onDelete)
        }
        .frame(height: 200)
    }

    private func onDelete(_ offsets: IndexSet) {
        timeZoneManager.removeTimeZoneAt(at: offsets)
    }

    private func onMove(_ indices: IndexSet, to destination: Int) {
        timeZoneManager.moveTimeZone(from: indices, to: destination)
    }
}

#Preview {
    TimeZoneListView()
        .environmentObject(TimeZoneManager())
        .environment(TimeManager())
}
