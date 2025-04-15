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
            VStack(spacing: 16) {
                TimeZoneListView()
            }
            .frame(width: 300)

            TimeZoneAddView()
                .frame(width: 300)
        }
    }
}

#Preview {
    ZonesSettingsView()
        .environmentObject(TimeZoneManager())
        .environment(TimeManager())
}


