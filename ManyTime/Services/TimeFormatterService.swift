//
//  TimeFormatterService.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/17/25.
//

import SwiftUI

class TimeFormatterService {
    private var preferences = AppPreferences.shared

    static let shared = TimeFormatterService()

    private var formatters: [String: DateFormatter] = [:]
    private var currentFormat: Format = .short

    enum Format: String {
        case short = "hh:mm a"
        case medium = "hh:mm:ss a"
        case short24 = "HH:mm"
        case medium24 = "HH:mm:ss"
    }

    private init() {
        updateTimeFormat()
    }

    private func formatter(for format: Format, timeZone: TimeZone) -> DateFormatter {
        let key = "\(format.rawValue)_\(timeZone.identifier)"

        if let existing = formatters[key] {
            return existing
        }

        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale(identifier: "en_US_POSIX")

        switch format {
        case .short, .short24:
            formatter.timeStyle = .short
        case .medium, .medium24:
            formatter.timeStyle = .medium
        }

        if format == .short24 || format == .medium24 {
            formatter.setLocalizedDateFormatFromTemplate(format == .medium24 ? "HH:mm:ss" : "HH:mm")
        } else {
            formatter.setLocalizedDateFormatFromTemplate(format == .medium ? "hh:mm:ss a" : "hh:mm a")
        }

        formatters[key] = formatter

        return formatter
    }

    func string(from date: Date, format: Format = .short, timeZone: TimeZone) -> String {
        formatter(for: format, timeZone: timeZone).string(from: date)
    }

    func appTimeFormat(from date: Date, timeZone: TimeZone) -> String {
        formatter(for: currentFormat, timeZone: timeZone).string(from: date)
    }

    func updateTimeFormat() {
        let use24Hour = preferences.use24Hour
        let showSeconds = preferences.showSeconds

        currentFormat = if use24Hour {
            showSeconds ? .medium24 : .short24
        } else {
            showSeconds ? .medium : .short
        }

        // Clear existing formatters to force recreation
        formatters.removeAll()
    }
}
