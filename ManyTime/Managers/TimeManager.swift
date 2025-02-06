//
//  TimeManager.swift
//  SharedMoment
//
//  Created by Domenic Murtari on 2/5/25.
//

import Foundation
import Combine

class TimeManager {
    var timeZones: [String] = ["America/Denver", "Asia/Tokyo"]
    var appTimer: AnyCancellable?

    init() {
        appTimer = Timer.publish(
            every: 1,
            on: .current,
            in: .common
        )
        .autoconnect()
        .sink{
            t in print(
                t
            )
        }
    }
}
