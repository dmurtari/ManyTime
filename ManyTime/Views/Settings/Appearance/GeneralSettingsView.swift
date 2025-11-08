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
                Text("Appearance")
                    .font(.system(size: 14, weight: .bold))
                Divider()

                Form {
                    Toggle("Show Time Bar", isOn: $preferences.showTimeBar)
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
