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
    @State private var displayName: String = ""

    var body: some View {
        Form {
            TimeZonePicker(selectedTimeZone: $timeZone)

            TextField("Display Name", text: $displayName)

            HStack {
                Spacer()

                Button("Add") {
                    save()
                }
            }
        }
    }

    private func save() {
        let targetDisplayName = displayName.isEmpty ? timeZone.description : displayName

        timeZoneManager.addTimeZone(
            timeZone,
            displayName: targetDisplayName
        )

        displayName = ""
        timeZone = .current
    }
}

#Preview {
    TimeZoneAddView()
        .environment(TimeZoneManager())
}
