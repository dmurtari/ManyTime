//
//  TimeRockerControl.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2026/07/30.
//

import Combine
import SwiftUI

struct TimeRockerControl: View {
  @Environment(TimeManager.self) private var timeManager
  @Environment(TimeViewPosition.self) private var timeViewPosition

  @State private var rockerOffset: CGFloat = 0
  @State private var isDragging = false
  @State private var scrollCancellable: AnyCancellable?

  @State private var dragStartOffset: CGFloat = 0
  @State private var dragBaseTime: Date = Date()
  @State private var cumulativePixels: CGFloat = 0
  @State private var travelLimit: CGFloat = (Constants.AppViewConstants.timeMenuWidth / 2) - Self.rockerRadius - 2

  private static let controlHeight: CGFloat = 20
  private static let rockerRadius: CGFloat = (Self.controlHeight / 2) - 2
  private static let scrollTickInterval: Double = 1 / 60

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        Rectangle()
          .foregroundStyle(Color.secondary.opacity(0.2))
          .cornerRadius(Self.controlHeight / 2)

        RoundedRectangle(cornerRadius: Self.controlHeight / 2)
          .strokeBorder(style: StrokeStyle(lineWidth: 1))
          .foregroundStyle(Color.primary.opacity(0.1))

        Circle()
          .fill(isDragging ? Color.accentColor : Color.secondary)
          .frame(width: Self.rockerRadius * 2, height: Self.rockerRadius * 2)
          .offset(x: rockerOffsetClamped)
          .shadow(radius: isDragging ? 4 : 2)
      }
      .gesture(dragGesture(in: geometry))
      .onChange(of: isDragging) { _, newValue in
        if !newValue {
          stopContinuousScrolling()
          centerRocker()
        }
      }
    }
    .frame(height: Self.controlHeight)
  }

  private var rockerOffsetClamped: CGFloat {
    min(max(rockerOffset, -travelLimit), travelLimit)
  }

  private func dragGesture(in geometry: GeometryProxy) -> some Gesture {
    let travel = geometry.size.width / 2 - Self.rockerRadius - 2

    return DragGesture(minimumDistance: 0)
      .onChanged { value in
        travelLimit = travel
        let centerX = geometry.size.width / 2

        if !isDragging {
          isDragging = true

          let target = min(max(value.location.x - centerX, -travel), travel)
          dragStartOffset = target
          rockerOffset = target

          dragBaseTime = timeManager.displayDate
          cumulativePixels = 0
          startContinuousScrolling()
          return
        }

        rockerOffset = min(max(dragStartOffset + value.translation.width, -travel), travel)
      }
      .onEnded { _ in
        isDragging = false
        stopContinuousScrolling()
      }
  }

  private func startContinuousScrolling() {
    scrollCancellable?.cancel()
    scrollCancellable = Timer.publish(every: Self.scrollTickInterval, on: .main, in: .common)
      .autoconnect()
      .sink { [self] _ in
        let speedMultiplier: CGFloat = 0.3
        let normalized = rockerOffsetClamped / travelLimit
        let curved = normalized * abs(normalized)
        let scrollDelta = curved * travelLimit * speedMultiplier

        cumulativePixels += scrollDelta

        for i in timeViewPosition.scrollPositions.indices {
          let currentPosition = timeViewPosition.scrollPositions[i].x ?? 0
          let newPosition = currentPosition + scrollDelta
          timeViewPosition.scrollPositions[i] = ScrollPosition(x: newPosition)
        }

        let hoursOffset = cumulativePixels / Constants.TimeBarConstants.timeViewSide
        let newTime = dragBaseTime.addingTimeInterval(hoursOffset * 3600)
        timeManager.setFixedTime(newTime)
      }
  }

  private func stopContinuousScrolling() {
    scrollCancellable?.cancel()
    scrollCancellable = nil
  }

  private func centerRocker() {
    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
      rockerOffset = 0
    }
  }
}

#Preview {
  TimeRockerControl()
    .environment(TimeViewPosition())
    .environment(TimeManager())
    .frame(width: 350)
}
