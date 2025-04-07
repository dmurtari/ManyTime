//
//  TimeView.swift
//  SharedMoment
//
//  Created by Domenic Murtari on 1/31/25.
//

import SwiftUI

// TODO: This should probably take desired time as input?
struct TimeView: View {
    @EnvironmentObject private var timeManager: TimeManager

    var timeZone: TimeZone
    var date: Date

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
            Text(TimeFormatterService.shared.appTimeFormat(
                from: timeManager.displayDate,
                timeZone: timeZone
            ))
                .font(.title).monospacedDigit()

            Text("\(timeZone.identifier.replacingOccurrences(of: "_", with: " ")) \(offset)")
        }
    }
}

#Preview("Local") {
    TimeView(timeZone: TimeZone.current, date: Date())
        .environment(TimeManager())
}

#Preview("Los Angeles") {
    TimeView(timeZone: TimeZone(identifier: "America/Los_Angeles")!, date: Date())        
        .environment(TimeManager())
}

#Preview("Japan") {
    TimeView(timeZone: TimeZone(identifier: "Asia/Tokyo")!, date: Date())
        .environment(TimeManager())
}
