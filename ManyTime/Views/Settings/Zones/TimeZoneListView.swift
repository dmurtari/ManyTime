//
//  TimeZoneListView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/04/14.
//

import SwiftUI

struct TimeZoneListView: View {
    @EnvironmentObject var timeZoneManager: TimeZoneManager
    @State private var editingTimeZoneId: UUID?

    var body: some View {
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
                    Button("Edit") {
                        editingTimeZoneId = timeZone.id
                    }
                    Divider()
                    Button("Reset") {
                        onReset(timeZone)
                    }
                    Button("Delete", role: .destructive) {
                        onDelete(timeZone)
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        onDelete(timeZone)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button {
                        onReset(timeZone)
                    } label: {
                        Label("Reset", systemImage: "arrow.clockwise")
                    }
                }
            }
            .onMove(perform: onMove)
        }
        .padding(EdgeInsets(top: -10, leading: -16, bottom: -10, trailing: -16))
        .clipShape(Rectangle())
        .frame(height: CGFloat(timeZoneManager.savedTimeZones.count * 50))
    }

    private func onDelete(_ timeZoneItem: TimeZoneItem) {
        timeZoneManager.removeTimeZone(id: timeZoneItem.id)
    }

    private func onMove(_ indices: IndexSet, to destination: Int) {
        timeZoneManager.moveTimeZone(from: indices, to: destination)
    }

    private func onReset(_ timeZoneItem: TimeZoneItem) {
        timeZoneManager.resetTimeZone(timeZoneItem)
    }
}

#Preview {
    TimeZoneListView()
        .environmentObject(TimeZoneManager())
        .environment(TimeManager())
}
