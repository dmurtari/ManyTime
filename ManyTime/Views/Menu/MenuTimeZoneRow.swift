//
//  MenuTimeZoneRow.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import SwiftUI

struct MenuTimeZoneRow: View {
    let item: TimeZoneItem
    let date: Date

    var body: some View {
        HStack {
            Text(item.displayName)
            Spacer()
            Text(timeString(for: item.timeZoneObject))
                .foregroundColor(.secondary)
                .monospacedDigit()
        }
        .contextMenu {
            Button("Remove") {
                // Implement removal
            }
            Button("Edit Name") {
                // Implement editing
            }
        }
    }

    private func timeString(for timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    MenuTimeZoneRow(
        item: TimeZoneItem(
            timeZone: TimeZone.current,
            displayName: "Denver"
        ),
        date: Date()
    )
}
