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

enum TimeMode: Equatable {
  case current
  case fixed(Date)
}

@MainActor
@Observable
final class TimeManager {
  var currentDate = Date()
  var timeMode: TimeMode = .current

  @ObservationIgnored private var timerCancellable: AnyCancellable?
  @ObservationIgnored private var resetTask: Task<Void, Never>?
  @ObservationIgnored private var menuClosedAt: Date?

  private let logger = Logger(subsystem: "com.dmurtari.ManyTime", category: "TimeManager")

  var displayDate: Date {
    let date: Date
    switch timeMode {
    case .current:
      date = currentDate
    case .fixed(let fixedDate):
      date = fixedDate
    }
    return Calendar.current.date(
      from: Calendar.current.dateComponents(
        [.year, .month, .day, .hour, .minute],
        from: date
      )
    ) ?? date
  }

  // Are the currentDate and displayDate similar enough to be considered the same?
  var isShowingCurrentTime: Bool {
    switch timeMode {
    case .current:
      return true
    case .fixed(let date):
      return Calendar.current.isDate(currentDate, equalTo: date, toGranularity: .minute)
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

  func cancelMenuReset() {
    menuClosedAt = nil
    resetTask?.cancel()
    resetTask = nil
  }

  func scheduleMenuReset(after delay: TimeInterval?) {
    menuClosedAt = Date()
    updateMenuReset(after: delay)
  }

  func updateMenuReset(after delay: TimeInterval?) {
    resetTask?.cancel()
    resetTask = nil

    guard let menuClosedAt, let delay else { return }

    let remainingDelay = max(0, delay - Date().timeIntervalSince(menuClosedAt))

    resetTask = Task { [weak self] in
      do {
        try await Task.sleep(for: .seconds(remainingDelay))
        guard !Task.isCancelled else { return }
        self?.switchToCurrent()
      } catch {
        // Task was cancelled, do nothing
      }
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
