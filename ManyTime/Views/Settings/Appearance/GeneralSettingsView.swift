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
                Text("Format")
                    .font(.system(size: 14, weight: .bold))
                Divider()

                Form {
                    Toggle("Use 24-Hour Time", isOn: $preferences.use24Hour)
                    Toggle("Show Seconds", isOn: $preferences.showSeconds)
                }
                .padding( [.vertical], 12)
            }
        }
    }
}

#Preview {
    GeneralSettingsView()
        .environment(TimeManager())
}
