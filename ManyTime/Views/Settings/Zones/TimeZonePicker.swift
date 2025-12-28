//
//  TimeZonePicker.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/15/25.
//

import SwiftUI

struct TimeZonePicker: View {
    @Binding var selectedTimeZone: String

    @State private var selectedId: String = ""

    var body: some View {
        Picker("Time Zone", selection: $selectedId) {
            Text("Select...").tag("")
                .foregroundStyle(.gray)

            Divider()

            ForEach(cityTimeZones, id: \.self) { cityTz in
                Text(formatTimeZone(cityTz))
                    .tag(cityTz.id)
            }
        }
        .pickerStyle(.menu)
        .onAppear {
            if selectedTimeZone != "" {
                selectedId = idByName[selectedTimeZone] ?? ""
            } else {
                selectedId = ""
            }
        }
        .onChange(of: selectedId) { _, newId in
            guard !newId.isEmpty else {
                selectedTimeZone = ""
                return
            }
            if let name = nameById[newId] {
                selectedTimeZone = name
            }
        }
        .onChange(of: selectedTimeZone) { _, newTimeZone in
            if newTimeZone == "" {
                selectedId = ""
            }
        }
    }

    private var cityTimeZones: [CityTimeZone] {
        return TimeZoneListService.shared.getCityTimeZones()
            .sorted { lhs, rhs in
                let lc = lhs.city.localizedCaseInsensitiveCompare(rhs.city)
                if lc == .orderedSame {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }
                return lc == .orderedAscending
            }
    }

    private var nameById: [String: String] {
        Dictionary(uniqueKeysWithValues: cityTimeZones.map { ($0.id, $0.name) })
    }

    private var idByName: [String: String] {
        Dictionary(cityTimeZones.map { ($0.name, $0.id) }, uniquingKeysWith: { first, _ in first })
    }

    private func formatTimeZone(_ tz: CityTimeZone) -> String {
        if let timeZone = TimeZone(identifier: tz.name) {
            let offset = timeZone.secondsFromGMT() / 3600
            return "\(tz.city), \(tz.countryCode) (GMT\(offset >= 0 ? "+" : "")\(offset))"
        } else {
            return "\(tz.city), \(tz.countryCode)"
        }
    }
}

#Preview {
    TimeZonePicker(selectedTimeZone: .constant("Asia/Tokyo"))
}
