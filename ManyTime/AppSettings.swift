//
//  AppPreferences.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import ServiceManagement
import SwiftUI

@MainActor class AppPreferences: ObservableObject {
  @AppStorage("menuBarTimeFormat") var menuBarTimeFormat: String = "HH:mm" {
    didSet {
      notifyTimeFormatChanged()
    }
  }

  @AppStorage("dropdownTimeFormat") var dropdownTimeFormat: String = "HH:mm" {
    didSet {
      notifyTimeFormatChanged()
    }
  }

  @AppStorage("showTimeBar") var showTimeBar = true

  @AppStorage("demoteCurrentTimezoneInList") var demoteCurrentTimezoneInList = false

  @AppStorage("showNonDeviceTimezoneInMenuBar") var showNonDeviceTimezoneInMenuBar = true

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

