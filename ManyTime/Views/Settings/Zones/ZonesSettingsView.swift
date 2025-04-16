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
            Group {
                TimeZoneListView()

            }
            .frame(width: 300)
            .roundedBorder(shadowRadius: 2)

            TimeZoneAddView()
                .padding(12)
                .frame(width: 300)
                .roundedBorder(shadowRadius: 2)
        }
    }
}

#Preview {
    ZonesSettingsView()
        .frame(width: 350, height: 400)
        .environmentObject(TimeZoneManager())
        .environment(TimeManager())
}


