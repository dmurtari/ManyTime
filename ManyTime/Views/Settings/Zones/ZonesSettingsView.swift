//
//  ZonesSettingsView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/23/25.
//

import SwiftUI

struct ZonesSettingsView: View {
    @EnvironmentObject var timeZoneManager: TimeZoneManager

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading) {
                Text("Active Time Zones")
                    .font(.system(size: 14, weight: .bold))

                Divider()

                Group {
                    TimeZoneListView()
                }
            }

            VStack(alignment: .leading) {
                Text("Add New")
                    .font(.system(size: 14, weight: .bold))

                Divider()

                TimeZoneAddView()
                    .padding([.vertical])
            }
        }
    }
}

#Preview {
    ZonesSettingsView()
        .environmentObject(TimeZoneManager())
        .environment(TimeManager())
}


