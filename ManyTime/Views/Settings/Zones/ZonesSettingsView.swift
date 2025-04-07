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
        VStack {
            HStack(spacing: 16) {
                ForEach(timeZoneManager.savedTimeZones) { item in
                    SettingsTimeView(timeZone: item)
                        .frame(maxWidth: .infinity)
                        .fixedSize(horizontal: true, vertical: true)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()

            TimeZoneAddView()
                .frame(width: 300)
        }
        .padding()
    }
}

#Preview {
    ZonesSettingsView()
        .environment(TimeZoneManager())
        .environment(TimeManager())
}


