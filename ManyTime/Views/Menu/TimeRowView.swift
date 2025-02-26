//
//  TimeRow.swift
//  SharedMoment
//
//  Created by Domenic Murtari on 1/31/25.
//

import SwiftUI

struct TimeRowView: View {
    var timeZone: TimeZoneItem
    var date: Date

    var body: some View {
        HStack {
            TimeView(timeZone: timeZone.timeZoneObject, date: date)

            Spacer()

            // Time scroller
        }
    }
}

#Preview {
    TimeRowView(timeZone: .init(timeZone: .current, displayName: nil), date: Date())
        .environment(TimeManager())
}
