//
//  PreferencesView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/21/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            GeneralSettingsView()
                .frame(width: 300)
            ZonesSettingsView()
                .frame(width: 300)
        }
        .frame(width: 320)
        .padding([.vertical], 8)
        .fixedSize(horizontal: true, vertical: true)
    }
}

#Preview {
    SettingsView()
        .environmentObject(TimeZoneManager())
        .environmentObject(TimeManager())
}
