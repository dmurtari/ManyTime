//
//  TimeZoneListService.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/11/01.
//

import Foundation

class TimeZoneListService {
    static let shared = TimeZoneListService()

    private var timeZones: [RawTimeZone] = []

    private init() {
        self.timeZones = readTimeZones()
    }

    func getTimeZones() -> [RawTimeZone] {
        return self.timeZones
    }

    func getCityTimeZones() -> [CityTimeZone] {
        return self.timeZones.flatMap { tz in
            tz.mainCities.map { city in
                CityTimeZone(
                    id: "\(city)|\(tz.countryCode)|\(tz.name)",
                    city: city,
                    countryCode: tz.countryCode,
                    name: tz.name,
                    rawOffsetInMinutes: tz.rawOffsetInMinutes,
                    rawFormat: tz.rawFormat
                )
            }
        }
    }

    private func readTimeZones() -> [RawTimeZone] {
        guard let url = Bundle.main.url(forResource: "RawTimeZones", withExtension: "json") else {
            print("[TimeZoneListService] Could not find RawTimeZones.json in bundle.")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([RawTimeZone].self, from: data)
        } catch {
            print("[TimeZoneListService] Failed to load or decode RawTimeZones.json: \(error)")
            return []
        }
    }
}
