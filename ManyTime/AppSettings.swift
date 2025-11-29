//
//  AppPreferences.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import SwiftUI
import ServiceManagement

class AppPreferences: ObservableObject {
    @AppStorage("showSeconds") var showSeconds = false {
        didSet {
            notifyTimeFormatChanged()
        }
    }
    @AppStorage("use24Hour") var use24Hour = false {
        didSet {
            notifyTimeFormatChanged()
        }
    }
    @AppStorage("showTimeBar") var showTimeBar = true
    @AppStorage("launchOnLogin") var launchOnLogin = false {
        didSet {
            if launchOnLogin == true {
                try? SMAppService.mainApp.register()
            } else {
                try? SMAppService.mainApp.unregister()
            }
        }
    }

    private func notifyTimeFormatChanged() {
        TimeFormatterService.shared.updateTimeFormat()
    }

    static let shared = AppPreferences()
}
