//
//  PreferencesView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/21/25.
//

import SwiftUI

struct PreferencesView: View {
    @StateObject private var preferences = AppPreferences.shared

    var body: some View {
        Form {
            Toggle("Show Date", isOn: $preferences.showDate)
            Toggle("Use 24-Hour Time", isOn: $preferences.use24Hour)
            Toggle("Show Seconds", isOn: $preferences.showSeconds)
        }
        .padding()
    }
}
