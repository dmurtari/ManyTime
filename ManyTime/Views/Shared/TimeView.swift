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

    var timeZone: TimeZoneItem
    var date: Date

    var offset: String {
        let offsetInHours = timeZone.timeZoneObject.secondsFromGMT() / 3600
        let formattedOffset = if offsetInHours > 0 {
            "GMT+\(offsetInHours)"
        } else {
            "GMT-\(abs(offsetInHours))"
        }

        return formattedOffset
    }

    var readableDate: String {
        var format = Date.FormatStyle()
            .weekday(.abbreviated)
            .month()
            .day()

        format.timeZone = timeZone.timeZoneObject

        return timeManager.displayDate.formatted(
            format
        )
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(timeZone.displayName)")
                    .font(.system(size: 20))
                    .fontWeight(.bold)

                Text("\(offset)")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                HStack {
                    Text(TimeFormatterService.shared.appTimeFormat(
                        from: timeManager.displayDate,
                        timeZone: timeZone.timeZoneObject
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
    TimeView(timeZone: TimeZoneItem(timeZone: TimeZone.current, displayName: "Current"), date: Date())
        .environment(TimeManager())
}

#Preview("Los Angeles") {
    TimeView(
        timeZone: TimeZoneItem(
            timeZone: TimeZone(identifier: "America/Los_Angeles")!,
            displayName: nil
        ),
        date: Date()
    )
        .environment(TimeManager())
}
