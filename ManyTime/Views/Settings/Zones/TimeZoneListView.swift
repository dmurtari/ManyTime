//
//  TimeZoneListView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/04/14.
//

import SwiftUI

struct TimeZoneListView: View {
    @EnvironmentObject var timeZoneManager: TimeZoneManager

    @Binding var timeZones: [TimeZoneItem]

    var body: some View {
        List{
            ForEach(timeZones) { timeZone in
                TimeView(timeZone: timeZone, date: Date())
            }
            .onMove(perform: onMove)
            .onDelete(perform: onDelete)
        }
    }

    private func onDelete(_ offsets: IndexSet) {
        timeZoneManager.removeTimeZoneAt(at: offsets)
    }

    private func onMove(_ indices: IndexSet, to destination: Int) {
        timeZoneManager.moveTimeZone(from: indices, to: destination)
    }
}

#Preview {
    TimeZoneListView(timeZones: .constant([
        TimeZoneItem(timeZone: TimeZone.current, displayName: "Current"),
    ]))
        .environment(TimeManager())
}
