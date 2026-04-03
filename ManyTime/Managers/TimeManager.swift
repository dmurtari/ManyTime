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

@MainActor
final class TimeManager: ObservableObject {
    @Published private(set) var currentDate = Date()
    @Published var timeMode: TimeMode = .current

    private var timerCancellable: AnyCancellable?

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
        startTimer()
    }

    private func startTimer() {
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] date in
                self?.currentDate = date
            }
    }

    func setTimeOffset(_ interval: TimeInterval) {
        timeMode = .offset(interval)
    }

    func setFixedTime(_ date: Date) {
        timeMode = .fixed(date)
    }

    func switchToCurrent() {
        timeMode = .current
    }
}
