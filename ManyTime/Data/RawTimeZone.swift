//
//  RawTimeZone.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/11/01.
//

struct RawTimeZone: Decodable, Hashable {
    let name: String
    let mainCities: [String]
    let rawOffsetInMinutes: Int
    let rawFormat: String
}

