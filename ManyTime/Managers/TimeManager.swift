//
//  TimeManager.swift
//  SharedMoment
//
//  Created by Domenic Murtari on 2/5/25.
//

import Foundation
import Combine

enum TimeMode {
    case current
    case fixed(Date)
    case offset(TimeInterval)
}

class TimeManager: ObservableObject, Observable {
    @Published var currentDate = Date()
    @Published var timeMode: TimeMode = .current
    private var timer: Timer?

    var displayDate: Date {
        switch timeMode {
        case .current:
            return currentDate
        case .fixed(let date):
            return date
        case .offset(let interval):
            return currentDate.addingTimeInterval(interval)
        }
    }

    init() {
        setupTimer()
    }

    deinit {
        timer?.invalidate()
    }

    private func setupTimer() {
        timer?.invalidate()

        let now = Date()
        let timeInterval = ceil(now.timeIntervalSinceReferenceDate) - now.timeIntervalSinceReferenceDate

        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            self?.currentDate = Date()
            self?.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.currentDate = Date()
            }
            self?.timer?.tolerance = 0.1
        }
    }

    func setTimeOffset(_ interval: TimeInterval) {
        timeMode = .offset(interval)
        setupTimer()
    }

    func setFixedTime(_ date: Date) {
        timeMode = .fixed(date)
        setupTimer()
    }

    func switchToCurrent() {
        timeMode = .current
        setupTimer()
    }
}
