//
//  TimeBarTimeView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/11/01.
//

import SwiftUI

struct TimeBarTimeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Binding var date: Date

    var dimension: Int
    var timeZone: TimeZone

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
            return colorScheme == .light ? Color(red: 109/255, green: 83/255, blue: 242/255) : Color(
                red: 121/255,
                green: 122/255,
                blue: 252/255
            )
        } else if ((hour > 5 && hour < 8) || (hour > 18 && hour < 21)) {
            return colorScheme == .light ? Color(red: 16/255, green: 133/255, blue: 252/255) : Color(
                red: 63/255,
                green: 142/255,
                blue: 252/255
            )
        } else {
            return colorScheme == .light ? Color(red: 249/255, green: 206/255, blue: 46/255) : Color(
                red: 249/255,
                green: 216/255,
                blue: 16/255
            )
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
            date: .constant(Date()),
            dimension: 30,
            timeZone: TimeZone.current
        )

        TimeBarTimeView(
            date: .constant(Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: Date()) ?? Date()),
            dimension: 30,
            timeZone: TimeZone.current
        )

        TimeBarTimeView(
            date: .constant(Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()),
            dimension: 30,
            timeZone: TimeZone.current
        )

        TimeBarTimeView(
            date: .constant(Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) ?? Date()),
            dimension: 30,
            timeZone: TimeZone.current
        )
    }
}
