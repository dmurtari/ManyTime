//
//  TimeZoneListView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/04/14.
//

import SwiftUI

struct TimeZoneListView: View {
    @EnvironmentObject var timeZoneManager: TimeZoneManager
    @StateObject private var preferences = AppPreferences.shared
    @State private var editingTimeZoneId: UUID?

    var body: some View {
        if (timeZoneManager.savedTimeZones.isEmpty) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Add a Time Zone below!")
                    .font(.callout)

                Text(
                    "Time zones that you have added will be shown here. The first time zone will be shown in the Menu Bar."
                )
                .font(.callout)
                .foregroundStyle(.secondary)
            }
            .padding(.vertical)
        } else {
            List {
                ForEach(timeZoneManager.savedTimeZones) { timeZone in
                    TimeView(
                        isEditing: Binding(
                            get: { editingTimeZoneId == timeZone.id },
                            set: { isEditing in
                                editingTimeZoneId = isEditing ? timeZone.id : nil
                            }
                        ),
                        timeZone: timeZone,
                        date: Date()
                    )
                    .contextMenu {
                        Button("Edit Name", systemImage: "pencil") {
                            editingTimeZoneId = timeZone.id
                        }
                        Divider()
                        Button(
                            "Delete",
                            systemImage: "trash",
                            role: .destructive
                        ) {
                            onDelete(timeZone)
                        }
                    }
                }
                .onMove(perform: onMove)
                .listRowSeparator(.hidden)
            }
            .padding(
                EdgeInsets(top: -10, leading: -16, bottom: -10, trailing: -16)
            )
            .clipShape(Rectangle())
            .frame(
                height: CGFloat(
                    timeZoneManager.savedTimeZones
                        .count * (preferences.showTimeBar ? 90 : 50)
                )
            )
        }
    }

    private func onDelete(_ timeZoneItem: TimeZoneItem) {
        timeZoneManager.removeTimeZone(id: timeZoneItem.id)
    }

    private func onMove(_ indices: IndexSet, to destination: Int) {
        timeZoneManager.moveTimeZone(from: indices, to: destination)
    }
}

#Preview {
    TimeZoneListView()
        .environmentObject(TimeZoneManager())
        .environment(TimeManager())
}
