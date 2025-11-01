//
//  AppPreferences.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import SwiftUI

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

    private func notifyTimeFormatChanged() {
        TimeFormatterService.shared.updateTimeFormat()
    }

    static let shared = AppPreferences()
}
