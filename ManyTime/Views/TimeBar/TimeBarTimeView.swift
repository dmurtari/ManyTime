//
//  TimeBarTimeView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/11/01.
//

import SwiftUI

struct TimeBarTimeView: View {
    @Binding var dimension: Int
    @Binding var hour: Int

    var body: some View {
        Rectangle()
            .foregroundStyle(backgroundColor)
            .frame(width: CGFloat(dimension), height: CGFloat(dimension))
            .overlay {
                Text("\(hour)")
                    .bold()
                    .foregroundStyle(textColor)
            }
    }

    var backgroundColor : Color {
        if (hour <= 5 || hour >= 22) {
            return .indigo
        } else if ((hour > 5 && hour < 8) || (hour > 18 && hour < 22)) {
            return .blue
        } else {
            return .yellow
        }
    }

    var textColor : Color {
        if (hour < 8 || hour > 18) {
            return .white
        } else {
            return .indigo
        }
    }
}

#Preview {
    TimeBarTimeView(dimension: .constant(30), hour: .constant(24))
    TimeBarTimeView(dimension: .constant(30), hour: .constant(6))
    TimeBarTimeView(dimension: .constant(30), hour: .constant(12))

}
