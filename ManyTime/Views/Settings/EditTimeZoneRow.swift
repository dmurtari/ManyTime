//
//  EditTimeZoneRow.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import SwiftUI

struct EditTimeZoneRow: View {
    let timeZone: TimeZone
    let displayName: String
    @State private var date = Date()
    @State private var isEditing = false
    @State private var editedName: String
    @EnvironmentObject private var timeManager: TimeManager
    @StateObject private var preferences = AppPreferences.shared


    let onDisplayNameUpdate: (String) -> Void

    init(timeZone: TimeZone, displayName: String, onDisplayNameUpdate: @escaping (String) -> Void) {
        self.timeZone = timeZone
        self.displayName = displayName
        self.onDisplayNameUpdate = onDisplayNameUpdate
        self._editedName = State(initialValue: displayName)
    }

    var body: some View {
        HStack {
            if isEditing {
                TextField("Display Name", text: $editedName, onCommit: {
                    onDisplayNameUpdate(editedName)
                    isEditing = false
                })
                .textFieldStyle(.roundedBorder)
            } else {
                Text(displayName)
                    .onTapGesture(count: 2) {
                        isEditing = true
                    }
            }
            Spacer()
            Text(TimeFormatterService.shared.menuBarString(
                from: timeManager.displayDate,
                timeZone: timeZone
            ))
        }
    }
}
