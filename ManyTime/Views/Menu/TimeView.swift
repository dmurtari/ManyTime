//
//  TimeView.swift
//  SharedMoment
//
//  Created by Domenic Murtari on 1/31/25.
//

import SwiftUI

// TODO: This should probably take desired time as input?
struct TimeView: View {
    @State var timeNow = ""

    @EnvironmentObject private var timeManager: TimeManager
    @StateObject private var preferences = AppPreferences.shared

    var timeZone: TimeZone
    var date: Date

    let present = Date()
    let userLocale = Locale.autoupdatingCurrent

    var offset: String {
        let offsetInHours = timeZone.secondsFromGMT() / 3600
        let formattedOffset = if offsetInHours > 0 {
            "GMT+\(offsetInHours)"
        } else {
            "GMT-\(abs(offsetInHours))"
        }

        return formattedOffset
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(timeString(for: timeZone))
                .font(.title).monospacedDigit()

            Text("\(timeZone.identifier.replacingOccurrences(of: "_", with: " ")) \(self.offset)")
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

#Preview("Local") {
    TimeView(timeZone: TimeZone.current, date: Date())
}

#Preview("Los Angeles") {
    TimeView(timeZone: TimeZone(identifier: "America/Los_Angeles")!, date: Date())
}

#Preview("Japan") {
    TimeView(timeZone: TimeZone(identifier: "Asia/Tokyo")!, date: Date())
}
