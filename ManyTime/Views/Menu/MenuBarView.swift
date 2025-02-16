//
//  MenuBarView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import SwiftUI

struct MenuBarView: View {
    @ObservedObject var timeZoneManager: TimeZoneManager
    @StateObject private var preferences = AppPreferences.shared
    @State private var date = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        if let primaryZone = timeZoneManager.savedTimeZones.first {
            Text(timeString(for: primaryZone.timeZoneObject))
                .onReceive(timer) { _ in
                    date = Date()
                }
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

        return formatter.string(from: date)
    }
}

#Preview {
    MenuBarView(timeZoneManager: TimeZoneManager())
}
