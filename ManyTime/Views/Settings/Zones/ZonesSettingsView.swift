//
//  ZonesSettingsView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/23/25.
//

import SwiftUI

struct ZonesSettingsView: View {
    @EnvironmentObject private var timeZoneManager: TimeZoneManager

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ForEach(timeZoneManager.savedTimeZones) { item in
                    SettingsTimeView(timeZone: item, showDelete: true)
                        .frame(maxWidth: .infinity)
                        .fixedSize(horizontal: true, vertical: true)
                }
            }
            .frame(maxWidth: .infinity)

            TimeZoneAddView()
                .frame(width: 300)
        }
    }
}

#Preview {
    ZonesSettingsView()
        .environment(TimeZoneManager())
        .environment(TimeManager())
}


