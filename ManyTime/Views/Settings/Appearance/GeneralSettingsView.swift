//
//  GeneralSettingsView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/23/25.
//

import SwiftUI

struct GeneralSettingsView: View {
    @StateObject private var preferences = AppPreferences.shared

    var body: some View {
        VStack(spacing: 16) {
            TimeView(
                timeZone: TimeZoneItem(
                    timeZone: TimeZone.current,
                    displayName: TimeZone.current.description
                ),
                date: Date()
            )
            .frame(width: 250)

            Form {
                Toggle("Use 24-Hour Time", isOn: $preferences.use24Hour)
                Toggle("Show Seconds", isOn: $preferences.showSeconds)
            }
        }
    }
}

#Preview {
    GeneralSettingsView()
        .environment(TimeManager())
}
