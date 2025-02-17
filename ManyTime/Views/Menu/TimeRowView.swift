//
//  TimeRow.swift
//  SharedMoment
//
//  Created by Domenic Murtari on 1/31/25.
//

import SwiftUI

// TODO: Could take: timezone
struct TimeRowView: View {
    var timeZone: TimeZoneItem

    var body: some View {
        HStack {
            TimeView(timeZone: timeZone.timeZoneObject)

            Spacer()

            // Time scroller
        }
        .padding()
    }
}

#Preview {
    TimeRowView(timeZone: .init(timeZone: .current, displayName: nil))
}
