//
//  iOSView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2026/11/04.
//

import SwiftUI

#if os(iOS)
  struct MainIOSView: View {
    @Environment(TimeManager.self) private var timeManager
    @EnvironmentObject private var timeZoneManager: TimeZoneManager
    @StateObject private var preferences = AppPreferences.shared

    @State private var timeViewPosition = TimeViewPosition()
    @State private var showingAdd = false
    @State private var showingAbout = false
    @State private var showingSettings = false
    @State private var editMode: EditMode = .inactive
    @State private var editingTimeZoneID: UUID?

    var body: some View {
      NavigationStack {
        List {
          if timeZoneManager.displayedTimeZones.isEmpty {
            Section {
              VStack(alignment: .leading, spacing: 8) {
                Text("Nothing to show yet!")
                Text("Tap + to add a Time Zone")
                  .foregroundStyle(.secondary)
              }
              .padding(.vertical, 8)
            }
          } else {
            Section {
              ForEach(timeZoneManager.displayedTimeZones.enumerated(), id: \.element.id) { index, timeZone in
                TimeView(
                  isEditing: Binding(
                    get: { editingTimeZoneID == timeZone.id },
                    set: { editingTimeZoneID = $0 ? timeZone.id : nil }
                  ),
                  timeZone: timeZone,
                  index: index
                )
                .swipeActions(edge: .trailing) {
                  Button("Delete", systemImage: "trash", role: .destructive) {
                    timeZoneManager.removeTimeZone(id: timeZone.id)
                  }
                  Button("Edit Name", systemImage: "pencil") {
                    editingTimeZoneID = timeZone.id
                  }
                  .tint(.blue)
                }
              }
              .onMove { offsets, destination in
                timeZoneManager.moveDisplayedTimeZones(from: offsets, to: destination)
              }
              .onDelete { offsets in
                timeZoneManager.removeDisplayedTimeZones(at: offsets)
              }
            }
          }
        }
        .listStyle(.plain)
        .frame(maxHeight: .infinity)
        .navigationTitle("Time Zones")
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Button("Settings", systemImage: "gearshape") {
              showingSettings = true
            }
          }

          ToolbarItem(placement: .topBarTrailing) {
            Button("Add", systemImage: "plus") {
              showingAdd = true
            }
          }

          ToolbarItem(placement: .topBarTrailing) {
            EditButton()
          }
        }
        .sheet(isPresented: $showingAdd) {
          NavigationStack {
            TimeZoneAddView()
              .navigationTitle("Add a Time Zone")
              .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                  Button("Done") { showingAdd = false }
                }
              }
          }
        }
        .sheet(isPresented: $showingSettings) {
          NavigationStack {
            IOSSettingsView()
              .navigationTitle("Settings")
              .navigationBarTitleDisplayMode(.inline)
              .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                  Button("Done") { showingSettings = false }
                }
              }
          }
        }
        .safeAreaInset(edge: .bottom) {
          if preferences.showTimeBar && preferences.showRockerControls && !timeZoneManager.displayedTimeZones.isEmpty {
            HStack {
              Button("", systemImage: "arrow.uturn.backward.circle") {
                timeViewPosition.indexScrolledByUser = nil
                timeManager.switchToCurrent()
              }
              .disabled(timeManager.isShowingCurrentTime)

              TimeRockerControl()
            }
            .padding()
            .glassEffect(.regular, in: .rect(cornerRadius: 24))
            .padding(.horizontal)
          }
        }
      }
      .environment(\.editMode, $editMode)
      .environment(timeViewPosition)
    }

    @ViewBuilder
    private func primaryHeader(for item: TimeZoneItem) -> some View {
      Section {
        HStack {
          VStack(alignment: .leading) {
            Text(item.normalizedDisplayName)
              .font(.headline)
            Text(TimeFormatterService.shared.dropdownTimeFormat(from: timeManager.displayDate, timeZone: item))
              .font(.caption)
              .foregroundStyle(.secondary)
          }

          Spacer()

          MenuBarTimeView(timeZoneItem: item)
            .font(.largeTitle)
            .monospacedDigit()
        }
      }
    }
  }

  #Preview {
    MainIOSView()
      .environment(TimeManager())
      .environmentObject(TimeZoneManager())
  }
#endif
