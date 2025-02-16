//
//  AppPreferences.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import SwiftUI

class AppPreferences: ObservableObject {
    @AppStorage("showDate") var showDate = false
    @AppStorage("use24Hour") var use24Hour = false
    @AppStorage("showSeconds") var showSeconds = false

    static let shared = AppPreferences()
}

struct PreferencesWindow: Scene {
    var body: some Scene {
        Window("Preferences", id: "preferences") {
            PreferencesView()
        }
        .defaultSize(width: 300, height: 200)
    }
}

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
