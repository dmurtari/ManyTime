//
//  TimeManager.swift
//  SharedMoment
//
//  Created by Domenic Murtari on 2/5/25.
//

import Foundation
import Combine

class TimeManager {
    var appTimer: AnyCancellable?

    init() {
        appTimer = Timer.publish(
            every: 1,
            on: .current,
            in: .common
        )
        .autoconnect()
        .sink{ _ in }
    }

    var availableTimeZoneIdentifiers: [String] {
        TimeZone.knownTimeZoneIdentifiers;
    }
}
