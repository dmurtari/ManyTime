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
            VStack(alignment: .leading) {
                Text("General")
                    .font(.system(size: 14, weight: .bold))
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Show Time Bar", isOn: $preferences.showTimeBar)
                    Text("Show a bar visualizing time")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding( [.top], 6)

                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Launch at login", isOn: $preferences.launchOnLogin)
                    Text("Launch when you Login to your Mac")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding( [.top], 6)
                .padding( [.bottom], 12)
            }
        }
    }
}

#Preview {
    GeneralSettingsView()
        .environment(TimeManager())
}
