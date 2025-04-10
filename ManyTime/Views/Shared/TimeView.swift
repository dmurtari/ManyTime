//
//  TimeView.swift
//  SharedMoment
//
//  Created by Domenic Murtari on 1/31/25.
//

import SwiftUI

struct TimeView: View {
    @EnvironmentObject private var timeManager: TimeManager
    @State private var isHovering = false

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

    var readableDate: String {
        let relevantDate = Calendar.current.startOfDay(for: timeManager.displayDate)
        return relevantDate.formatted(
            Date.FormatStyle()
                .weekday(.abbreviated)
                .month()
                .day()
        )
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(timeZone.identifier.replacingOccurrences(of: "_", with: " "))")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)

                Text("\(offset)")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                HStack {
                    Text(TimeFormatterService.shared.appTimeFormat(
                        from: timeManager.displayDate,
                        timeZone: timeZone
                    ))
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .monospacedDigit()
                }

                Text("\(readableDate)")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
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
