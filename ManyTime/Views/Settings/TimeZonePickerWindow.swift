//
//  TimeZonePickerWindow.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import SwiftUI

struct TimeZonePickerWindow: Scene {
    @Environment(\.dismiss) var dismiss
    let onSave: (TimeZone, String?) -> Void

    var body: some Scene {
        Window("Add Time Zone", id: "timezone-picker") {
            TimeZonePickerView(onSave: onSave)
        }
        .defaultSize(width: 480, height: 300)
    }
}

struct TimeZonePickerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTimeZone: TimeZone = TimeZone.current
    @State private var displayName: String = ""
    let onSave: (TimeZone, String?) -> Void

    var body: some View {
        VStack(spacing: 16) {
            HSplitView {
                // Left side - will be replaced with map in future
                TimeZonePicker(selectedTimeZone: $selectedTimeZone)

                // Right side - timezone details
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Display Name (Optional)", text: $displayName)
                        .textFieldStyle(.roundedBorder)

                    Text("Time Zone: \(selectedTimeZone.identifier)")
                        .foregroundColor(.secondary)

                    Text("Current Time: \(currentTimeString)")
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .padding()
                .frame(minWidth: 200)
            }

            // Bottom toolbar
            HStack {
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                Button("Add") {
                    onSave(selectedTimeZone, displayName.isEmpty ? nil : displayName)
                    dismiss()
                }
                .keyboardShortcut(.return)
            }
            .padding()
        }
    }

    private var currentTimeString: String {
        let formatter = DateFormatter()
        formatter.timeZone = selectedTimeZone
        formatter.timeStyle = .medium
        return formatter.string(from: Date())
    }
}

