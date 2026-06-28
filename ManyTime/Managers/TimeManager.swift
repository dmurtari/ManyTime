//
//  TimeManager.swift
//  SharedMoment
//
//  Created by Domenic Murtari on 2/5/25.
//

import Combine
import Foundation
import Observation
import OSLog

enum TimeMode {
  case current
  case fixed(Date)
}

@MainActor
@Observable
final class TimeManager {
  var currentDate = Date()
  var timeMode: TimeMode = .current

  @ObservationIgnored private var timerCancellable: AnyCancellable?

  private let logger = Logger(subsystem: "com.dmurtari.ManyTime", category: "TimeManager")

  var displayDate: Date {
    switch timeMode {
    case .current:
      return Calendar.current.date(
        from: Calendar.current.dateComponents(
          [.year, .month, .day, .hour, .minute],
          from: currentDate
        )
      ) ?? currentDate
    case .fixed(let date): return date
    }
  }

  // Are the currentDate and displayDate similar enough to be considered the same?
  var isShowingCurrentTime: Bool {
    return Calendar.current.isDate(currentDate, equalTo: displayDate, toGranularity: .minute)
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

  func setFixedTime(_ date: Date) {
    logger.log("Setting fixed time to: \(date)")
    timeMode = .fixed(date)
  }

  func switchToCurrent() {
    logger.log("Switching to current time")
    timeMode = .current
  }
}
