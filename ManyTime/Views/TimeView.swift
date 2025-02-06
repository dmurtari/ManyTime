//
//  TimeView.swift
//  SharedMoment
//
//  Created by Domenic Murtari on 1/31/25.
//

import SwiftUI

// TODO: This should probably take desired time as input?
struct TimeView: View {
    @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var timeNow = ""

    var timeZone: TimeZone

    let present = Date()
    let userLocale = Locale.autoupdatingCurrent

    // TODO: This needs to only happen once
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm:ss a z"
        formatter.locale = userLocale
        formatter.timeZone = timeZone
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(timeNow)
                .onReceive(timer) {_ in
                    self.timeNow = self.dateFormatter.string(from: Date())
                }
            .font(.title)

            Text("\(timeZone.identifier) GMT\(timeZone.secondsFromGMT() / 60 / 60)")
        }
    }
}

#Preview("Local") {
    TimeView(timeZone: TimeZone.current)
}

#Preview("Los Angeles") {
    TimeView(timeZone: TimeZone(identifier: "America/Los_Angeles")!)
}

#Preview("Japan") {
    TimeView(timeZone: TimeZone(identifier: "Asia/Tokyo")!)
}
