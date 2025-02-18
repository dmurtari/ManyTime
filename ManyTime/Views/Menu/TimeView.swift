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

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var timeZone: TimeZone
    var date: Date

    let present = Date()
    let userLocale = Locale.autoupdatingCurrent

    // TODO: This needs to only happen once
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm:ss"
        formatter.locale = userLocale
        formatter.timeZone = timeZone
        return formatter
    }

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
            Text(timeNow)
                .onReceive(timer) {_ in
                    self.timeNow = self.dateFormatter.string(from: date)
                }
                .font(.title).monospacedDigit()

            Text("\(timeZone.identifier.replacingOccurrences(of: "_", with: " ")) \(self.offset)")
        }
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
