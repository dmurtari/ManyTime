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

    private var currentHour: Int {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.component(.hour, from: currentTime)
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(generateDateArray(currentTime: currentTime, length: width), id: \.timeIntervalSince1970) { date in
                TimeBarTimeView(
                    dimension: .constant(30),
                    date: .constant(date),
                    timeZone: .constant(timeZone),
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
                .overlay {
                    let hour = getHour(from: date)
                    if hour == currentHour {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.black, lineWidth: 2)
                    }
                }
                .zIndex(getHour(from: date) == currentHour ? 1 : 0)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                currentTime = Date()
            }
        }
    }

    func generateDateArray(currentTime: Date, length: Int) -> [Date] {
        let hoursBeforeCurrent = length / 3
        let hoursAfterCurrent = length - hoursBeforeCurrent - 1

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
}
