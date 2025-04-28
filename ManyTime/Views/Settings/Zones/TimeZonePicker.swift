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

            ForEach(timeZoneIdentifiers, id: \.self) { identifier in
                Text(formatTimeZone(identifier))
                    .tag(
                        identifier
                    )
            }
        }
        .pickerStyle(.menu)
    }

    private var timeZoneIdentifiers : [String] {
        return TimeZone.knownTimeZoneIdentifiers
    }

    private func formatTimeZone(_ identifier: String) -> String {
        let name = identifier.replacingOccurrences(of: "_", with: " ")
        if let timeZone = TimeZone(identifier: identifier) {
            let offset = timeZone.secondsFromGMT() / 3600
            return "\(name) (GMT\(offset >= 0 ? "+" : "")\(offset))"
        }
        return name
    }
}

#Preview {
    TimeZonePicker(selectedTimeZone: .constant("Asia/Tokyo"))
}
