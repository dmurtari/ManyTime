//
//  ZonesSettingsView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/23/25.
//

import SwiftUI

struct ZonesSettingsView: View {
    @EnvironmentObject private var timeZoneManager: TimeZoneManager
    @State private var timeZones: [TimeZoneItem] = []

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 16) {
                TimeZoneListView(timeZones: $timeZones)
            }
            .frame(width: 300)

            TimeZoneAddView()
                .frame(width: 300)
        }
        .onAppear() {
            timeZones = timeZoneManager.savedTimeZones
        }
    }
}

#Preview {
    ZonesSettingsView()
        .environment(TimeZoneManager())
        .environment(TimeManager())
}


