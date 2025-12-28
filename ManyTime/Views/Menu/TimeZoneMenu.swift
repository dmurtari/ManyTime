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
                VStack(alignment: .leading, spacing: 16) {
                    Text("Nothing to show yet!")
                        .font(.callout)

                    
                    Text("Click Options > Preferences to get started by adding a Time Zone")
                        .foregroundColor(.secondary)
                        .font(.callout)
                }
                .padding()
            } else {
                VStack(spacing: 16) {
                    ForEach(timeZoneManager.savedTimeZones) { timeZone in
                        TimeView(timeZone: timeZone, date: date)
                    }
                }
                .padding()
            }

            ControlsRowView()
                .padding([.bottom], 12)
                .padding([.horizontal])
        }
    }
}

#Preview {
    TimeZoneMenu()
        .frame(width: 300)
        .environment(TimeManager())
        .environment(TimeZoneManager())
}
