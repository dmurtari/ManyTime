//
//  TimeFormatterService.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/17/25.
//

import SwiftUI

@MainActor extension Locale {
  var is12HourTimeFormat: Bool {
    let dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .short
    dateFormatter.dateStyle = .none
    dateFormatter.locale = self
    let dateString = dateFormatter.string(from: Date())
    return dateString.contains(dateFormatter.amSymbol)
      || dateString.contains(dateFormatter.pmSymbol)
  }
}

@MainActor class TimeFormatterService {
  private var preferences = AppPreferences.shared

  static let shared = TimeFormatterService()

  private var formatters: [String: DateFormatter] = [:]

  private init() {
    updateTimeFormat()
  }

  private func formatter(for format: String, timeZone: TimeZone) -> DateFormatter {
    let key = "\(format)_\(timeZone.identifier)"

    if let existing = formatters[key] {
      return existing
    }

    let formatter = DateFormatter()
    formatter.timeZone = timeZone
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = format

    formatters[key] = formatter

    return formatter
  }

  func menuBarTimeFormat(from date: Date, timeZone: TimeZone) -> String {
    formatter(for: preferences.menuBarTimeFormat, timeZone: timeZone).string(from: date)
  }

  func dropdownTimeFormat(from date: Date, timeZone: TimeZone) -> String {
    formatter(for: preferences.dropdownTimeFormat, timeZone: timeZone).string(from: date)
  }

  func updateTimeFormat() {
    formatters.removeAll()
  }
}
