//
//  TimeBarTimeView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/11/01.
//

import SwiftUI

extension Color {
    static let nightForeground = Color(red: 255/255, green: 255/255, blue: 255/255)
    static let dayForeground = Color(red: 88/255, green: 86/255, blue: 214/255)
    static let nightBackground = Color(red: 53/255, green: 51/255, blue: 107/255)
    static let duskBackground = Color(red: 106/255, green: 113/255, blue: 165/255)
    static let dayBackground = Color(red: 255/255, green: 236/255, blue: 156/255)
}

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
            return .nightBackground
        } else if ((hour > 5 && hour < 8) || (hour > 18 && hour < 21)) {
            return .duskBackground
        } else {
            return .dayBackground
        }
    }

    var textColor: Color {
        if (hour < 8 || hour > 18) {
            return .nightForeground
        } else {
            return .dayForeground
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
