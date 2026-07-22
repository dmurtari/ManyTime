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
  static let shared = TimeFormatterService()

  private static let namePlaceholder = "{name}"

  private var preferences = AppPreferences.shared
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

  /// Replaces {name} with the given display name
  private func resolvedFormat(_ format: String, displayName: String) -> String {
    guard format.contains(Self.namePlaceholder) else {
      return format
    }

    let escaped = displayName.replacingOccurrences(of: "'", with: "''")

    return format.replacingOccurrences(
      of: Self.namePlaceholder,
      with: "'\(escaped)'"
    )
  }

  func menuBarTimeFormat(from date: Date, timeZone: TimeZoneItem) -> String {
    let format = resolvedFormat(preferences.menuBarTimeFormat, displayName: timeZone.normalizedDisplayName)
    return formatter(for: format, timeZone: timeZone.timeZoneObject).string(from: date)
  }

  func dropdownTimeFormat(from date: Date, timeZone: TimeZoneItem) -> String {
    let format = resolvedFormat(preferences.dropdownTimeFormat, displayName: timeZone.normalizedDisplayName)
    return formatter(for: format, timeZone: timeZone.timeZoneObject).string(from: date)
  }

  func updateTimeFormat() {
    formatters.removeAll()
  }
}
