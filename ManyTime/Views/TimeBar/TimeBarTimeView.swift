//
//  TimeBarTimeView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/11/01.
//

import SwiftUI

struct TimeBarTimeView: View {
    @Binding var dimension: Int
    @Binding var date: Date
    @Binding var timeZone: TimeZone

    var body: some View {
        Rectangle()
            .foregroundStyle(backgroundColor)
            .frame(width: CGFloat(dimension), height: CGFloat(dimension))
            .overlay {
                displayContent
            }
    }

    private var displayContent: some View {
        Group {
            if hour == 0 {
                VStack(spacing: 0) {
                    Text(monthText)
                        .bold()
                        .foregroundStyle(textColor)
                        .font(.caption)
                    Text(dateText)
                        .bold()
                        .foregroundStyle(textColor)
                        .font(.caption2)
                }
            } else {
                Text("\(hour)")
                    .bold()
                    .foregroundStyle(textColor)
                    .font(.caption)
            }
        }
    }

    private var monthText: String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }


    private var hour: Int {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.component(.hour, from: date)
    }

    var backgroundColor: Color {
        if (hour <= 5 || hour >= 21) {
            return .indigo
        } else if ((hour > 5 && hour < 8) || (hour > 18 && hour < 21)) {
            return .blue
        } else {
            return .yellow
        }
    }

    var textColor: Color {
        if (hour < 8 || hour > 18) {
            return .white
        } else {
            return .black
        }
    }
}


#Preview {
    VStack {
        TimeBarTimeView(
            dimension: .constant(30),
            date: .constant(Date()),
            timeZone: .constant(TimeZone.current)
        )

        TimeBarTimeView(
            dimension: .constant(30),
            date: .constant(Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Date()) ?? Date()),
            timeZone: .constant(TimeZone.current)
        )

        TimeBarTimeView(
            dimension: .constant(30),
            date: .constant(Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()),
            timeZone: .constant(TimeZone.current)
        )

        TimeBarTimeView(
            dimension: .constant(30),
            date: .constant(Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) ?? Date()),
            timeZone: .constant(TimeZone.current)
        )
    }
}
