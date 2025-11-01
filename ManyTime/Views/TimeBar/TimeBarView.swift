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

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<width, id: \.self) { index in
                TimeBarTimeView(dimension: .constant(30), hour: .constant((currentHour() + index) % 24))
            }
        }
    }

    private func currentHour() -> Int {
        return 17
    }

    private func indexOfCurrent() -> Int {
        return width / 3
    }
}

#Preview {
    TimeBarView(timeZone: .constant(TimeZone.current), width: .constant(10))
}
