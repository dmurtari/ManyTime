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
        VStack {
            TimeView(timeZone: TimeZone.current, date: Date())
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.lightGray))
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 2, y: 2)
                        .shadow(color: .white.opacity(0.7), radius: 2, x: -2, y: -2)
                )
                .padding()

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
