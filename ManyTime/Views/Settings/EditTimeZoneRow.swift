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
    let onDisplayNameUpdate: (String) -> Void

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

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
            Text(date, formatter: dateFormatter(for: timeZone))
        }
        .onReceive(timer) { _ in
            date = Date()
        }
    }

    private func dateFormatter(for timeZone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.timeStyle = .medium
        return formatter
    }
}
