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
  @State private var timeViewPosition: TimeViewPosition = .init()

  var body: some View {
    if timeZoneManager.savedTimeZones.isEmpty {
      VStack(alignment: .leading, spacing: 16) {
        Text("Add a Time Zone below!")
          .font(.callout)

        Text(
          "Time zones that you have added will be shown here.\nThe first time zone will be shown in the Menu Bar."
        )
        .font(.callout)
        .foregroundStyle(.secondary)
      }
      .padding(.vertical)
    } else {
      VStack(alignment: .leading, spacing: 16) {
        Text(
          "Reorder Time Zones by dragging.\nThe first Time Zone will be shown in the Menu Bar.\nRight click to edit or delete."
        )
        .font(.callout)
        .foregroundStyle(.secondary)

        List {
          ForEach(timeZoneManager.savedTimeZones.enumerated(), id: \.offset) { index, timeZone in
            TimeView(
              isEditing: Binding(
                get: { editingTimeZoneId == timeZone.id },
                set: { isEditing in
                  editingTimeZoneId =
                    isEditing ? timeZone.id : nil
                }
              ),
              timeZone: timeZone,
              index: index
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
          .environment(timeViewPosition)
        }
        .padding(
          EdgeInsets(
            top: -10,
            leading: -16,
            bottom: -10,
            trailing: -16
          )
        )
        .clipShape(Rectangle())
        .frame(
          height: CGFloat(
            timeZoneManager.savedTimeZones.count
              * (preferences.showTimeBar ? 90 : 50)
          )
        )
      }
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
