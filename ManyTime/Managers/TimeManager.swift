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

    private func setupTimer() {
        timer?.invalidate()

        // Only run timer if we're in current time mode
        if case .current = timeMode {
            timer = Timer.scheduledTimer(
                withTimeInterval: 1.0,
                repeats: true
            ) { [weak self] _ in
                self?.currentDate = Date()
            }
            RunLoop.current.add(timer!, forMode: .common)
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

    deinit {
        timer?.invalidate()
    }
}
