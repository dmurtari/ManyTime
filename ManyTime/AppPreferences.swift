//
//  AppPreferences.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import SwiftUI

class AppPreferences: ObservableObject {
    @AppStorage("showDate") var showDate = false

    @AppStorage("showSeconds") var showSeconds = false {
        didSet {
            updateTimeFormat()
        }
    }
    @AppStorage("use24Hour") var use24Hour = false {
        didSet {
            updateTimeFormat()
        }
    }

    private func updateTimeFormat() {
        TimeFormatterService.shared.updateMenuBarFormat(
            use24Hour: use24Hour,
            showSeconds: showSeconds
        )
    }

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

