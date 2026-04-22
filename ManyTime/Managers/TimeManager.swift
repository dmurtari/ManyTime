//
//  TimeManager.swift
//  SharedMoment
//
//  Created by Domenic Murtari on 2/5/25.
//

import Combine
import Foundation

enum TimeMode {
  case current
  case fixed(Date)
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

  func setFixedTime(_ date: Date) {
    timeMode = .fixed(date)
  }

  func switchToCurrent() {
    timeMode = .current
  }
}
