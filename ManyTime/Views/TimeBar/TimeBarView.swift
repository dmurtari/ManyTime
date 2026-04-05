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

    private var currentHour: Int {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.component(.hour, from: currentTime)
    }

    var body: some View {
        ScrollView([.horizontal]){
            LazyHStack(spacing: 0) {
                ForEach(dateArray, id: \.timeIntervalSince1970) { date in
                    TimeBarTimeView(
                        date: .constant(date),
                        dimension: 30,
                        timeZone: timeZone,
                        showDate: getHour(from: date) == 0
                    )
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

                        if dateArray.firstIndex(where: { $0 == date }) == thresholdIndex {
                            dateArray = appendDates()
                        }
                    }
                    .onAppear() {
                        let thresholdIndex = dateArray.index(dateArray.startIndex, offsetBy: 5)

                        if dateArray.firstIndex(where: { $0 == date }) == thresholdIndex {
                            dateArray = prependDates()
                        }
                    }
                }
            }
        }
        .defaultScrollAnchor(.bottomLeading)
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

    private func appendDates() -> [Date] {
        print("Appending")

        var calendar = Calendar.current
        calendar.timeZone = timeZone

        let lastDate = dateArray.last

        guard lastDate != nil else {
            return dateArray
        }

        for i in 1...40 {
            if let dateToAdd = calendar.date(byAdding: .hour, value: i, to: lastDate!) {
                dateArray.append(dateToAdd)
            }
        }

        return dateArray
    }

    private func prependDates() -> [Date] {
        var calendar = Calendar.current
        calendar.timeZone = timeZone

        let firstDate = dateArray.first

        guard firstDate != nil else {
            return dateArray
        }

        for i in stride(from: 40, to: 0, by: -1) {
            if let dateToAdd = calendar.date(byAdding: .hour, value: -i, to: firstDate!) {
                dateArray.append(dateToAdd)
            }
        }

        return dateArray
    }

    func generateDateArray(currentTime: Date, length: Int) -> [Date] {
        let hoursBeforeCurrent = 4
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

