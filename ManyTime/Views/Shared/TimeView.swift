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

    @State private var editableDisplayName: String = ""
    @FocusState private var isDisplayNameFocused: Bool
    @Binding var isEditing: Bool

    var timeZone: TimeZoneItem
    var date: Date

    init(
        isEditing: Binding<Bool> = .constant(false),
        timeZone: TimeZoneItem,
        date: Date
    ) {
        self._isEditing = isEditing
        self.timeZone = timeZone
        self.date = date
    }

    var offset: String {
        let offsetInHours = timeZone.timeZoneObject.secondsFromGMT() / 3600
        let formattedOffset = offsetInHours > 0
            ? "GMT+\(offsetInHours)"
            : "GMT-\(abs(offsetInHours))"

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

    var readableTimeZone: String {
        return timeZone
            .timeZoneObject
            .identifier
            .replacingOccurrences(of: "_", with: " ")
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {

                if (!isEditing) {
                    Text("\(timeZone.normalizedDisplayName)")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                } else {
                    HStack {
                        TextField("Display Name", text: $editableDisplayName)
                            .textFieldStyle(.roundedBorder)
                            .focused($isDisplayNameFocused)
                            .onExitCommand(perform: handleDisplayNameBlur)
                            .onSubmit {
                                handleDisplayNameSave()
                            }

                        Button("Cancel", systemImage: "x.circle") {
                            handleDisplayNameBlur()
                        }
                        .buttonStyle(.glass)
                        .labelStyle(.iconOnly)

                        Button("Save", systemImage: "checkmark") {
                            handleDisplayNameSave()
                        }
                        .buttonStyle(.glassProminent)
                        .labelStyle(.iconOnly)

                    }
                }

                if (timeZone.displayName != nil) {
                    Text("\(offset) (\(readableTimeZone))")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(offset)")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
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
        .onChange(of: isEditing) { _, newValue in
            if newValue {
                // Defer to next runloop to ensure TextField is in view hierarchy
                DispatchQueue.main.async { isDisplayNameFocused = true }
                editableDisplayName = timeZone.normalizedDisplayName
            } else {
                isDisplayNameFocused = false
            }
        }
    }

    func handleDisplayNameEdit() -> Void {
        isEditing = true
        editableDisplayName = timeZone.normalizedDisplayName
    }

    func handleDisplayNameSave() -> Void {
        Task {
            timeZoneManager.updateDisplayName(
                for: timeZone.id,
                newName: editableDisplayName
            )
            isEditing = false
            editableDisplayName = ""
        }
    }

    func handleDisplayNameBlur() -> Void {
        isEditing = false
        isDisplayNameFocused = false
    }
}

#Preview("Local") {
    TimeView(
        isEditing: .constant(true), timeZone: TimeZoneItem(timeZone: TimeZone.current, displayName: "Current"),
        date: Date()
    )
        .environment(TimeManager())
        .environmentObject(TimeZoneManager())
}

#Preview("Los Angeles") {
    TimeView(
        isEditing: .constant(false), timeZone: TimeZoneItem(
            timeZone: TimeZone(identifier: "America/Los_Angeles")!,
            displayName: nil
        ),
        date: Date()
    )
        .environment(TimeManager())
        .environmentObject(TimeZoneManager())

}
