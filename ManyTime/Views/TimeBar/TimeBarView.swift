//
//  TimeBarView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/11/01.
//

import SwiftUI

struct TimeBarView: View {
  @Environment(TimeManager.self) private var timeManager

  @Binding var timeZone: TimeZone
  @Binding var currentTime: Date

  @State private var dateArray: [Date] = []
  @State private var position = ScrollPosition(edge: .leading)
  @State private var currentScrollX: CGFloat = 0

  @State private var isLoading = false
  @State private var isProgrammaticScroll = false
  @State private var isUserScrolling = false
  @State private var scrollSyncTask: Task<Void, any Error>?

  var body: some View {
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
    .onScrollGeometryChange(for: CGFloat.self) { geo in
      geo.contentOffset.x
    } action: { _, newX in
      currentScrollX = newX

      guard !isProgrammaticScroll else {
        return
      }

      guard let startTime = dateArray.first else {
        return
      }

      let pixelsPerHour = Constants.TimeBarConstants.timeViewSide
      let viewWidth = Constants.AppViewConstants.timeMenuWidth
      let contentOffsetAtCenter = newX + viewWidth / 2
      let secondsFromStart = (contentOffsetAtCenter / pixelsPerHour) * 3600
      let scrollTime = startTime.addingTimeInterval(TimeInterval(secondsFromStart))

      timeManager.liveScrollTime = scrollTime

      if !timeManager.isScrolling {
        timeManager.isScrolling = true
      }

      isUserScrolling = true
      scrollSyncTask?.cancel()
      scrollSyncTask = Task { @MainActor in
        try await Task.sleep(nanoseconds: 10_000_000)
        
        isUserScrolling = false
        timeManager.isScrolling = false
        timeManager.setFixedTime(scrollTime)
      }
    }
    .scrollIndicators(.hidden)
    .frame(
      width: Constants.AppViewConstants.timeMenuWidth,
      height: Constants.TimeBarConstants.timeViewSide
    )
    .overlay {
      Path { path in
        let x =
          Constants.AppViewConstants.timeMenuWidth / 2 + Constants.TimeBarConstants.timeViewSide / 2

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

      dateArray.append(currentTime)
      appendDates()
      prependDates()

      let initialScrollX =
        CGFloat(Constants.TimeBarConstants.timeViewInitialCount)
        * Constants.TimeBarConstants.timeViewSide
        - Constants.AppViewConstants.timeMenuWidth / 2

      position = ScrollPosition(x: initialScrollX)
    }
    .defaultScrollAnchor(.bottomLeading)
    .scrollPosition($position)
    .onDisappear {
      scrollSyncTask?.cancel()
    }
    .onChange(of: currentTime) { _, newValue in
      guard !isUserScrolling else {
        return
      }

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

    isProgrammaticScroll = true
    position = ScrollPosition(x: targetScrollX)
    Task { @MainActor in
      try? await Task.sleep(nanoseconds: 100_000_000)
      isProgrammaticScroll = false
    }
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
    isProgrammaticScroll = true
    position = ScrollPosition(x: currentScrollX + addedWidth)

    DispatchQueue.main.async {
      self.isProgrammaticScroll = false
      self.isLoading = false
    }
  }

  private func getHour(from date: Date) -> Int {
    var calendar = Calendar.current
    calendar.timeZone = timeZone
    return calendar.component(.hour, from: date)
  }
}

#Preview {
  let timeManager = TimeManager()

  TimeBarView(timeZone: .constant(TimeZone.current), currentTime: .constant(Date()))
    .environment(timeManager)

  TimeBarView(
    timeZone: .constant(TimeZone(identifier: "America/Los_Angeles")!),
    currentTime: .constant(Date())
  )
  .colorScheme(.light)
  .environment(timeManager)

  TimeBarView(
    timeZone: .constant(TimeZone(identifier: "America/Los_Angeles")!),
    currentTime: .constant(Date())
  )
  .colorScheme(.dark)
  .environment(timeManager)
}
