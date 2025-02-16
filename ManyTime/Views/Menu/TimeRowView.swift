//
//  TimeRow.swift
//  SharedMoment
//
//  Created by Domenic Murtari on 1/31/25.
//

import SwiftUI

// TODO: Could take: timezone
struct TimeRowView: View {
    var timeZone: TimeZone

    var body: some View {
        HStack {
            TimeView(timeZone: timeZone)

            Spacer()

            // Time scroller
        }
        .padding()
    }
}

#Preview {
    TimeRowView(timeZone: TimeZone(identifier: "Asia/Tokyo")!)
}
