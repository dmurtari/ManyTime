//
//  TimeManager.swift
//  SharedMoment
//
//  Created by Domenic Murtari on 2/5/25.
//

import Combine
import Foundation
import Observation

enum TimeMode {
  case current
  case fixed(Date)
}

@MainActor
@Observable
final class TimeManager {
  private(set) var currentDate = Date()
  var timeMode: TimeMode = .current
  var liveScrollTime: Date = Date()
  var isScrolling: Bool = false

  @ObservationIgnored private var timerCancellable: AnyCancellable?

  var committedDisplayDate: Date {
    switch timeMode {
    case .current: return currentDate
    case .fixed(let date): return date
    }
  }

  var displayDate: Date {
    isScrolling ? liveScrollTime : committedDisplayDate
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
    timeMode = .fixed(date)
  }

  func switchToCurrent() {
    timeMode = .current
  }
}
