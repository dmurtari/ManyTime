//
//  TimeBarView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/11/01.
//

import OSLog
import SwiftUI

let logger = Logger(subsystem: "com.dmurtari.ManyTime", category: "TimeBarView")

struct TimeBarView: View {
  @Environment(TimeManager.self) private var timeManager
  @Environment(TimeViewPosition.self) private var timeViewPosition: TimeViewPosition

  @Binding var timeZone: TimeZone
  @Binding var currentTime: Date
  var positionInList: Int

  @State private var dateArray: [Date] = []
  @State private var currentScrollX: CGFloat = 0
  @State private var isLoading = false

  var body: some View {
    @Bindable var timeViewPosition = timeViewPosition

    ScrollView([.horizontal]) {
      LazyHStack(spacing: 0) {
        ForEach(dateArray, id: \.timeIntervalSince1970) { date in
          let hourValue = getHour(from: date)
          TimeBarTimeView(
            date: .constant(date),
            dimension: Int(Constants.TimeBarConstants.timeViewSide),
            timeZone: timeZone,
            hour: hourValue,
            showDate: hourValue == 0
          )
          .id(date)
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
          .onAppear {
            let thresholdIndex = dateArray.index(dateArray.endIndex, offsetBy: -5)

            if dateArray.firstIndex(of: date) == thresholdIndex {
              appendDates()
            }
          }
          .onAppear {
            let thresholdIndex = dateArray.index(dateArray.startIndex, offsetBy: 5)

            if dateArray.firstIndex(of: date) == thresholdIndex {
              prependDates()
            }
          }
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

      guard timeViewPosition.indexScrolledByUser == positionInList else {
        return
      }

      let pixelsPerHour = Constants.TimeBarConstants.timeViewSide
      let viewWidth = Constants.AppViewConstants.timeMenuWidth
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
    .scrollIndicators(.hidden)
    .frame(
      width: Constants.AppViewConstants.timeMenuWidth,
      height: Constants.TimeBarConstants.timeViewSide
    )
    .overlay {
      Path { path in
        let x = Constants.AppViewConstants.timeMenuWidth / 2

        path.move(to: CGPoint(x: x, y: -1))
        path.addLine(to: CGPoint(x: x, y: Constants.TimeBarConstants.timeViewSide + 1))
      }
      .stroke(.black, lineWidth: 2)
    }
    .onAppear {
      logger.log("Starting onAppear Hook")

      guard dateArray.isEmpty else {
        scrollToTime(currentTime)
        logger.log("Date array not empty, scrolled to time")
        return
      }

      var calendar = Calendar.current
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
  }

  private func scrollToTime(_ time: Date) {
    guard let startTime = dateArray.first else {
      return
    }

    let pixelsPerHour = Constants.TimeBarConstants.timeViewSide
    let viewWidth = Constants.AppViewConstants.timeMenuWidth
    let secondsFromStart = time.timeIntervalSince(startTime)
    let targetScrollX = CGFloat(secondsFromStart / 3600) * pixelsPerHour - viewWidth / 2

    timeViewPosition.scrollPositions[positionInList] = ScrollPosition(x: targetScrollX)
  }

  private func appendDates() {
    guard isLoading == false else {
      return
    }

    guard let lastDate = dateArray.last else {
      return
    }

    isLoading = true

    var calendar = Calendar.current
    calendar.timeZone = timeZone

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

    var calendar = Calendar.current
    calendar.timeZone = timeZone

    var newDates: [Date] = []
    for i in 1...Int(Constants.TimeBarConstants.timeViewInitialCount) {
      if let date = calendar.date(byAdding: .hour, value: -i, to: firstDate) {
        newDates.append(date)
      }
    }

    dateArray.insert(contentsOf: newDates.reversed(), at: 0)

    // Shift the scroll position to compensate for the inserted content
    if (adjustScroll) {
      let addedWidth = CGFloat(newDates.count) * Constants.TimeBarConstants.timeViewSide
      timeViewPosition.scrollPositions[positionInList] = ScrollPosition(x: currentScrollX + addedWidth)
    }

    self.isLoading = false
  }

  private func getHour(from date: Date) -> Int {
    var calendar = Calendar.current
    calendar.timeZone = timeZone
    return calendar.component(.hour, from: date)
  }
}
