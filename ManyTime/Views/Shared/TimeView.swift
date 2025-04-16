//
//  TimeView.swift
//  SharedMoment
//
//  Created by Domenic Murtari on 1/31/25.
//

import SwiftUI

struct TimeView: View {
    @EnvironmentObject private var timeManager: TimeManager
    @EnvironmentObject private var timeZoneManager: TimeZoneManager

    @State private var isEditingDisplayName: Bool = false
    @State private var editableDisplayName: String = ""

    var timeZone: TimeZoneItem
    var date: Date
    var editable: Bool = false

    var offset: String {
        let offsetInHours = timeZone.timeZoneObject.secondsFromGMT() / 3600
        let formattedOffset = if offsetInHours > 0 {
            "GMT+\(offsetInHours)"
        } else {
            "GMT-\(abs(offsetInHours))"
        }

        return formattedOffset
    }

    var readableDate: String {
        var format = Date.FormatStyle()
            .weekday(.abbreviated)
            .month()
            .day()

        format.timeZone = timeZone.timeZoneObject

        return timeManager.displayDate.formatted(
            format
        )
    }

    var displayName: String {
        return timeZone.displayName ?? timeZone
            .timeZoneObject
            .identifier
            .replacingOccurrences(of: "_", with: " ")
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {

                if (!isEditingDisplayName) {
                    Text("\(displayName)")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .onTapGesture {
                            handleDisplayNameSelect()
                        }
                } else {
                    TextField("Display Name", text: $editableDisplayName)
                        .textFieldStyle(.plain)
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .onKeyPress(keys: [.return]) { _ in
                            handleDisplayNameSave()
                        }
                        .onKeyPress(keys: [.escape]) { _ in
                            handleDisplayNameBlur()
                        }
                }


                Text("\(offset)")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                HStack {
                    Text(TimeFormatterService.shared.appTimeFormat(
                        from: timeManager.displayDate,
                        timeZone: timeZone.timeZoneObject
                    ))
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .monospacedDigit()
                }

                Text("\(readableDate)")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
        }
    }

    func handleDisplayNameSelect() -> Void {
        if (editable) {
            isEditingDisplayName = true
            editableDisplayName = displayName
        }
    }

    func handleDisplayNameSave() -> KeyPress.Result {
        Task {
            timeZoneManager.updateDisplayName(
                for: timeZone.id,
                newName: editableDisplayName
            )
            isEditingDisplayName = false
            editableDisplayName = ""
        }
        return .handled
    }

    func handleDisplayNameBlur() -> KeyPress.Result {
        isEditingDisplayName = false
        return .handled
    }
}

#Preview("Local") {
    TimeView(
        timeZone: TimeZoneItem(timeZone: TimeZone.current, displayName: "Current"),
        date: Date(),
        editable: true
    )
        .environment(TimeManager())
        .environmentObject(TimeZoneManager())
}

#Preview("Los Angeles") {
    TimeView(
        timeZone: TimeZoneItem(
            timeZone: TimeZone(identifier: "America/Los_Angeles")!,
            displayName: nil
        ),
        date: Date()
    )
        .environment(TimeManager())
        .environmentObject(TimeZoneManager())

}
