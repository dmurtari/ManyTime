//
//  TimeBarView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/11/01.
//

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
  @State private var isUserScrolling = false
  @State private var scrollSyncTask: Task<Void, any Error>?

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

      for i in $timeViewPosition.scrollPositions.indices where i != timeViewPosition.indexScrolledByUser {
        timeViewPosition.scrollPositions[i].scrollTo(x: newX)
      }

      let pixelsPerHour = Constants.TimeBarConstants.timeViewSide
      let viewWidth = Constants.AppViewConstants.timeMenuWidth
      let contentOffsetAtCenter = newX + viewWidth / 2
      let secondsFromStart = (contentOffsetAtCenter / pixelsPerHour) * 3600
      let scrollTime = startTime.addingTimeInterval(TimeInterval(secondsFromStart))

      timeManager.liveScrollTime = scrollTime

      timeManager.setFixedTime(scrollTime)
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
      guard dateArray.isEmpty else {
        scrollToTime(currentTime)
        return
      }

      var calendar = Calendar.current
      calendar.timeZone = timeZone
      let seedDate = calendar.dateInterval(of: .hour, for: currentTime)?.start ?? currentTime
      dateArray.append(seedDate)
      appendDates()
      prependDates()

      guard let startTime = dateArray.first else { return }
      let secondsFromStart = currentTime.timeIntervalSince(startTime)
      let initialScrollX =
        CGFloat(secondsFromStart / 3600) * Constants.TimeBarConstants.timeViewSide
        - Constants.AppViewConstants.timeMenuWidth / 2

      timeViewPosition.scrollPositions[positionInList] = ScrollPosition(x: initialScrollX)
    }
    .defaultScrollAnchor(.bottomLeading)
    .onDisappear {
      scrollSyncTask?.cancel()
    }
    .onScrollPhaseChange { _, newPhase in
      if newPhase.isScrolling {
        timeViewPosition.indexScrolledByUser = positionInList
      }
    }
    .onChange(of: currentTime) { _, newValue in
      scrollToTime(newValue)
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

  private func prependDates() {
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
    let addedWidth = CGFloat(newDates.count) * Constants.TimeBarConstants.timeViewSide
    timeViewPosition.scrollPositions[positionInList] = ScrollPosition(x: currentScrollX + addedWidth)

    self.isLoading = false
  }

  private func getHour(from date: Date) -> Int {
    var calendar = Calendar.current
    calendar.timeZone = timeZone
    return calendar.component(.hour, from: date)
  }
}
