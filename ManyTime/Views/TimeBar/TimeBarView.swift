//
//  TimeBarView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/11/01.
//

import SwiftUI

struct TimeBarView: View {
    @Binding var timeZone: TimeZone
    @Binding var width: Int
    @State private var currentTime = Date()
    @State private var dateArray: [Date] = []
    @State private var position = ScrollPosition(x: 40 * 30 - (300 / 2 - 30))
    @State private var isLoading = false
    @State private var currentScrollX: CGFloat = 0

    private var currentHour: Int {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.component(.hour, from: currentTime)
    }

    var body: some View {
        ScrollView([.horizontal]){
            ScrollViewReader { proxy in
                LazyHStack(spacing: 0) {
                    ForEach(dateArray, id: \.timeIntervalSince1970) { date in
                        TimeBarTimeView(
                            date: .constant(date),
                            dimension: 30,
                            timeZone: timeZone,
                            showDate: getHour(from: date) == 0
                        )
                        .id(date)
                        .clipShape(
                            getHour(from: date) == 23 ? AnyShape(
                                UnevenRoundedRectangle(cornerRadii: .init(bottomTrailing: 6, topTrailing: 6))) : AnyShape(
                                    Rectangle()
                                )
                        )
                        .clipShape(
                            getHour(from: date) == 0 ? AnyShape(
                                UnevenRoundedRectangle(cornerRadii: .init(topLeading: 6, bottomLeading: 6))) : AnyShape(
                                    Rectangle()
                                )
                        )
                        .zIndex(getHour(from: date) == currentHour ? 1 : 0)
                        .onAppear() {
                            let thresholdIndex = dateArray.index(dateArray.endIndex, offsetBy: -5)

                            if dateArray.firstIndex(of: date) == thresholdIndex {
                                appendDates()
                            }
                        }
                        .onAppear() {
                            let thresholdIndex = dateArray.index(dateArray.startIndex, offsetBy: 5)

                            if dateArray.firstIndex(of: date) == thresholdIndex {
                                prependDates()
                            }
                        }
                    }
                }
            }
        }
        .defaultScrollAnchor(.bottomLeading)
        .scrollPosition($position)
        .onScrollGeometryChange(for: CGFloat.self) { geo in
            geo.contentOffset.x
        } action: { _, newX in
            currentScrollX = newX
        }
        .scrollIndicators(.hidden)
        .frame(width: 300, height: 30)
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.black, lineWidth: 2)
                .frame(width: 30, height: 30)
                .offset(x: -15)
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            currentTime = Date()
        }
        .onAppear() {
            dateArray = generateDateArray(currentTime: currentTime, length: width)
        }
    }

    private func appendDates() {
        guard isLoading == false else {
            return
        }

        var calendar = Calendar.current
        calendar.timeZone = timeZone

        let lastDate = dateArray.last

        guard lastDate != nil else {
            return
        }

        isLoading = true
        for i in 1...40 {
            if let dateToAdd = calendar.date(byAdding: .hour, value: i, to: lastDate!) {
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
        for i in 1...40 {
            if let date = calendar.date(byAdding: .hour, value: -i, to: firstDate) {
                newDates.append(date)
            }
        }

        dateArray.insert(contentsOf: newDates.reversed(), at: 0)

        let addedWidth = CGFloat(newDates.count) * 30
        position = ScrollPosition(x: currentScrollX + addedWidth)

        DispatchQueue.main.async {
            self.isLoading = false
        }
    }

    func generateDateArray(currentTime: Date, length: Int) -> [Date] {
        let hoursBeforeCurrent = 40
        let hoursAfterCurrent = 40

        var calendar = Calendar.current
        calendar.timeZone = timeZone

        var result: [Date] = []

        for i in stride(from: hoursBeforeCurrent, to: 0, by: -1) {
            if let date = calendar.date(byAdding: .hour, value: -i, to: currentTime) {
                result.append(date)
            }
        }

        result.append(currentTime)

        for i in 1...hoursAfterCurrent {
            if let date = calendar.date(byAdding: .hour, value: i, to: currentTime) {
                result.append(date)
            }
        }

        return result
    }

    private func getHour(from date: Date) -> Int {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.component(.hour, from: date)
    }
}

#Preview {
    TimeBarView(timeZone: .constant(TimeZone.current), width: .constant(10))
    TimeBarView(timeZone: .constant(TimeZone(identifier: "America/Los_Angeles")!), width: .constant(10))
        .colorScheme(.light)
    TimeBarView(timeZone: .constant(TimeZone(identifier: "America/New_York")!), width: .constant(10))
        .colorScheme(.dark)
}

