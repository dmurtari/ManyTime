//
//  TimeBarView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/11/01.
//

import OSLog
import SwiftUI

struct TimeBarView: View {
  @Environment(TimeManager.self) private var timeManager
  @Environment(TimeViewPosition.self) private var timeViewPosition: TimeViewPosition

  @Binding var timeZone: TimeZone
  @Binding var currentTime: Date
  var positionInList: Int

  @State private var dateArray: [Date] = []
  @State private var currentScrollX: CGFloat = 0
  @State private var isLoading = false
  @State private var calendar: Calendar = .current
  @State private var viewWidth: CGFloat = Constants.AppViewConstants.timeMenuWidth

  @StateObject private var preferences = AppPreferences.shared

  private let logger = Logger(subsystem: "com.dmurtari.ManyTime", category: "TimeBarView")

  var body: some View {
    @Bindable var timeViewPosition = timeViewPosition

    ScrollView([.horizontal]) {
      LazyHStack(spacing: 0) {
        ForEach(dateArray, id: \.self) { date in
          let hourValue = getHour(from: date)

          TimeBarTimeView(
            date: .constant(date),
            dimension: Int(Constants.TimeBarConstants.timeViewSide),
            timeZone: timeZone,
            hour: hourValue,
            showDate: hourValue == 0
          )
          .clipShape(
            UnevenRoundedRectangle(
              cornerRadii: .init(
                topLeading: hourValue == 0 ? 6 : 0,
                bottomLeading: hourValue == 0 ? 6 : 0,
                bottomTrailing: hourValue == 23 ? 6 : 0,
                topTrailing: hourValue == 23 ? 6 : 0
              )
            )
          )
        }
      }
    }
    .scrollPosition($timeViewPosition.scrollPositions[positionInList])
    .onScrollGeometryChange(for: CGFloat.self) { geo in
      geo.contentOffset.x
    } action: { oldX, newX in
      guard oldX != newX else {
        return
      }

      currentScrollX = newX

      guard let startTime = dateArray.first else {
        return
      }

      let pixelsPerHour = Constants.TimeBarConstants.timeViewSide
      let nearEdgeThreshold = pixelsPerHour * 5
      let totalContentWidth = CGFloat(dateArray.count) * pixelsPerHour

      if newX < nearEdgeThreshold {
        prependDates()
      } else if newX > totalContentWidth - viewWidth - nearEdgeThreshold {
        appendDates()
      }

      guard timeViewPosition.indexScrolledByUser == positionInList else {
        return
      }

      let contentOffsetAtCenter = newX + viewWidth / 2
      let secondsFromStart = (contentOffsetAtCenter / pixelsPerHour) * 3600
      let scrollTime = startTime.addingTimeInterval(TimeInterval(secondsFromStart))

      timeManager.setFixedTime(scrollTime)
    }
    .defaultScrollAnchor(.bottomLeading)
    .onScrollPhaseChange { _, newPhase in
      if newPhase.isScrolling {
        timeViewPosition.indexScrolledByUser = positionInList
      }
    }
    .scrollIndicators(preferences.showRockerControls ? .never : .hidden)
    .frame(height: Constants.TimeBarConstants.timeViewSide)
    #if os(macOS)
      .frame(width: Constants.AppViewConstants.timeMenuWidth)
    #else
      .frame(maxWidth: .infinity)
    #endif
    .onGeometryChange(for: CGFloat.self) { proxy in
      proxy.size.width
    } action: { newWidth in
      guard newWidth != viewWidth else { return }
      viewWidth = newWidth
      scrollToTime(timeManager.displayDate)
    }
    .overlay {
      Rectangle()
        .fill(.black)
        .frame(width: 2)
        .padding(.vertical, -1)
    }
    .onAppear {
      logger.log("Starting onAppear Hook")

      guard dateArray.isEmpty else {
        scrollToTime(currentTime)
        logger.log("Date array not empty, scrolled to time")
        return
      }

      calendar.timeZone = timeZone

      let seedDate = calendar.dateInterval(of: .hour, for: currentTime)?.start ?? currentTime
      dateArray.append(seedDate)
      appendDates()
      prependDates(adjustScroll: false)

      Task { @MainActor in
        await Task.yield()
        scrollToTime(currentTime)
      }
    }
    .onChange(of: currentTime) { oldValue, newValue in
      let wasCurrent = if case .current = timeManager.timeMode { true } else { false }

      logger.log("currentTime changed from \(oldValue) to \(newValue)")
      scrollToTime(newValue)

      if wasCurrent {
        // Let scroll updates finish, then switch back to currentTime
        Task { @MainActor in
          await Task.yield()
          logger.log("Time mode is current, re-switching to current time")
          timeManager.switchToCurrent()
        }
      }
    }
    .onChange(of: timeManager.timeMode) { oldMode, newMode in
      guard case .current = newMode else { return }

      logger.log("Switched to current time, resetting date array")
      resetDateArray()

      Task { @MainActor in
        await Task.yield()
        scrollToTime(timeManager.displayDate)
      }
    }
    .onChange(of: timeZone) { _, newZone in
      calendar.timeZone = newZone
      resetDateArray()

      Task { @MainActor in
        await Task.yield()
        scrollToTime(timeManager.displayDate)
      }
    }
  }

  private func scrollToTime(_ time: Date) {
    guard let startTime = dateArray.first else {
      return
    }

    let pixelsPerHour = Constants.TimeBarConstants.timeViewSide
    let secondsFromStart = time.timeIntervalSince(startTime)
    let targetScrollX = CGFloat(secondsFromStart / 3600) * pixelsPerHour - viewWidth / 2

    timeViewPosition.scrollPositions[positionInList] = ScrollPosition(x: targetScrollX)
  }

  private func resetDateArray() {
    dateArray.removeAll()

    let seedDate = calendar.dateInterval(of: .hour, for: currentTime)?.start ?? currentTime
    dateArray.append(seedDate)
    appendDates()
    prependDates(adjustScroll: false)
  }

  private func appendDates() {
    guard !isLoading, let lastDate = dateArray.last else {
      return
    }

    logger.log("appendDates count \(dateArray.count)")

    isLoading = true

    for i in 1...Int(Constants.TimeBarConstants.timeViewInitialCount) {
      if let dateToAdd = calendar.date(byAdding: .hour, value: i, to: lastDate) {
        dateArray.append(dateToAdd)
      }
    }
    isLoading = false
  }

  private func prependDates(adjustScroll: Bool = true) {
    guard !isLoading, let firstDate = dateArray.first else {
      return
    }

    isLoading = true

    var newDates: [Date] = []
    for i in 1...Int(Constants.TimeBarConstants.timeViewInitialCount) {
      if let date = calendar.date(byAdding: .hour, value: -i, to: firstDate) {
        newDates.append(date)
      }
    }

    dateArray.insert(contentsOf: newDates.reversed(), at: 0)

    // Shift the scroll position to compensate for the inserted content
    if adjustScroll {
      let addedWidth = CGFloat(newDates.count) * Constants.TimeBarConstants.timeViewSide
      timeViewPosition.scrollPositions[positionInList] = ScrollPosition(x: currentScrollX + addedWidth)
    }

    isLoading = false
  }

  private func getHour(from date: Date) -> Int {
    return calendar.component(.hour, from: date)
  }
}
