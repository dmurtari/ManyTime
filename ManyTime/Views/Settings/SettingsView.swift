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
                .frame(width: 275)
            ZonesSettingsView()
                .frame(width: 275)
        }
        .frame(width: 300)
        .padding([.vertical], 8)
        .fixedSize(horizontal: true, vertical: true)
    }
}

#Preview {
    SettingsView()
        .environment(TimeZoneManager())
        .environment(TimeManager())
}
