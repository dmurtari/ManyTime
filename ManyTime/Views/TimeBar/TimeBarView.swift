//
//  TimeBarView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/11/01.
//

import SwiftUI

struct TimeBarView: View {
    @Binding var timeZone: TimeZone
    @Binding var currentTime: Date

    @State private var dateArray: [Date] = []
    @State private var position = ScrollPosition(edge: .leading)
    @State private var isLoading = false
    @State private var currentScrollX: CGFloat = 0

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView([.horizontal]) {
                LazyHStack(spacing: 0) {
                    ForEach(dateArray, id: \.timeIntervalSince1970) { date in
                        TimeBarTimeView(
                            date: .constant(date),
                            dimension: Int(Constants.TimeBarConstants.timeViewSide),
                            timeZone: timeZone,
                            showDate: getHour(from: date) == 0
                        )
                        .id(date)
                        .clipShape(
                            getHour(from: date) == 23
                                ? AnyShape(
                                    UnevenRoundedRectangle(cornerRadii: .init(bottomTrailing: 6, topTrailing: 6))
                                )
                                : AnyShape(
                                    Rectangle()
                                )
                        )
                        .clipShape(
                            getHour(from: date) == 0
                                ? AnyShape(
                                    UnevenRoundedRectangle(cornerRadii: .init(topLeading: 6, bottomLeading: 6))
                                )
                                : AnyShape(
                                    Rectangle()
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

                // Recalculate what the time at the location of the black bar is
            }
            .scrollIndicators(.hidden)
            .frame(width: Constants.AppViewConstants.timeMenuWidth, height: Constants.TimeBarConstants.timeViewSide)
            .overlay {
                Path() { path in
                    let x = Constants.AppViewConstants.timeMenuWidth / 2

                    path.move(to: CGPoint(x: x, y: -1))
                    path.addLine(to: CGPoint(x: x, y: Constants.TimeBarConstants.timeViewSide + 1))
                }
                .stroke(.black, lineWidth: 2)
            }
            .onAppear {
                dateArray.append(currentTime)
                appendDates()
                prependDates()

                position = ScrollPosition(
                    x: Constants.TimeBarConstants.timeViewInitialCount
                        * Constants.TimeBarConstants
                        .timeViewSide
                        - (Constants.AppViewConstants.timeMenuWidth / 2 - Constants.TimeBarConstants.timeViewSide)
                )
            }
            .defaultScrollAnchor(.bottomLeading)
            .scrollPosition($position)
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
        guard !isLoading else {
            return
        }

        guard let firstDate = dateArray.first else {
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

        let addedWidth = CGFloat(newDates.count) * Constants.TimeBarConstants.timeViewSide
        position = ScrollPosition(x: currentScrollX + addedWidth)

        DispatchQueue.main.async {
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
    TimeBarView(timeZone: .constant(TimeZone.current), currentTime: .constant(Date()))
    TimeBarView(timeZone: .constant(TimeZone(identifier: "America/Los_Angeles")!), currentTime: .constant(Date()))
        .colorScheme(.light)
    TimeBarView(timeZone: .constant(TimeZone(identifier: "America/New_York")!), currentTime: .constant(Date()))
        .colorScheme(.dark)
}
