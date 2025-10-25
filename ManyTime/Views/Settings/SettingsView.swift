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
            ZonesSettingsView()
                .frame(width: 275)
            GeneralSettingsView()
                .frame(width: 275)
        }
        .frame(width: 300)
        .padding([.top], 12)
        .aspectRatio(1, contentMode: .fit)
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    SettingsView()
        .environment(TimeZoneManager())
        .environment(TimeManager())
}
