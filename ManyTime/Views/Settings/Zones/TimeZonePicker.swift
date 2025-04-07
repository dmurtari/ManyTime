//
//  TimeZonePicker.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/15/25.
//

import SwiftUI

struct TimeZonePicker: View {
    @Binding var selectedTimeZone: TimeZone

    var body: some View {
        Picker("Time Zone", selection: $selectedTimeZone) {
            ForEach(TimeZone.knownTimeZoneIdentifiers, id: \.self) { identifier in
                Text(formatTimeZone(identifier))
                    .tag(TimeZone(identifier: identifier) ?? TimeZone.current)
            }
        }
        .pickerStyle(.menu)
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

#Preview("Standalone") {
    TimeZonePicker(selectedTimeZone: .constant(TimeZone.current))
}

