//
//  CityTimeZone.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/11/01.
//

struct CityTimeZone: Decodable, Hashable, Identifiable {
    let id: String
    let city: String
    let countryCode: String
    let name: String
    let rawOffsetInMinutes: Int
    let rawFormat: String
}
