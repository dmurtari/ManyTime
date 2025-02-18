//
//  MenuBarView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import SwiftUI

struct MenuBarView: View {
    @ObservedObject var timeZoneManager: TimeZoneManager
    @EnvironmentObject private var timeManager: TimeManager

    @StateObject private var preferences = AppPreferences.shared


    var body: some View {
        if let primaryZone = timeZoneManager.savedTimeZones.first {
            Text(timeString(for: primaryZone.timeZoneObject))
                .monospacedDigit()
        } else {
            Image(systemName: "clock")
        }
    }

    private func timeString(for timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone

        if preferences.showDate {
            formatter.dateStyle = .short
        }

        formatter.timeStyle = preferences.showSeconds ? .medium : .short

        if !preferences.use24Hour {
            formatter.dateFormat = formatter.dateFormat?.replacingOccurrences(of: "HH", with: "h")
        }

        return formatter.string(from: timeManager.displayDate)
    }
}

#Preview {
    MenuBarView(timeZoneManager: TimeZoneManager())
}
