//
//  TimeField.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/12/25.
//

import AppKit

struct TimeField: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String?
    let timeZone: TimeZone?
}

extension TimeField {
    static var sampleTimes: [TimeField] = [
        TimeField(
            id: UUID(),
            name: "Denver",
            timeZone: TimeZone(
                identifier: "America/Denver"
            )!
        ),
        TimeField(
            id: UUID(),
            name: "Tokyo",
            timeZone: TimeZone(
                identifier: "Asia/Tokyo"
            )!
        )
    ]
}
