//
//  TimeZonePicker.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/15/25.
//

import SwiftUI

struct TimeZonePicker: View {
    @Binding var selectedTimeZone: String

    var body: some View {
        Picker("Time Zone", selection: $selectedTimeZone) {
            Text("Select...").tag("")
                .foregroundStyle(.gray)

            Divider()

            ForEach(rawTimeZones, id: \.self) { identifier in
                Text(identifier.rawFormat)
                    .tag(
                        identifier.name
                    )
            }
        }
        .pickerStyle(.menu)
    }

    private var rawTimeZones: [RawTimeZone] {
        return TimeZoneListService.shared.getTimeZones()
    }
}

#Preview {
    TimeZonePicker(selectedTimeZone: .constant("Asia/Tokyo"))
}
