//
//  TimeZoneAddView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/04/07.
//

import SwiftUI

struct TimeZoneAddView: View {
    @EnvironmentObject private var timeZoneManager: TimeZoneManager

    @State private var timeZone: TimeZone = .current

    var body: some View {
        HStack {
            TimeZonePicker(selectedTimeZone: $timeZone)

            Button("Add") {
                save()
            }
        }
    }

    private func save() {
        print("Adding time zone '\(timeZone.identifier) with name '\(timeZone.description)'")
        timeZoneManager.addTimeZone(timeZone, displayName: timeZone.description)
    }
}

#Preview {
    TimeZoneAddView()
        .environment(TimeZoneManager())
}
