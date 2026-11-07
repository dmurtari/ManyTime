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
    @State private var editMode: EditMode = .inactive

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
              ForEach(timeZoneManager.displayedTimeZones.enumerated(), id: \.offset) { index, timeZone in
                TimeView(
                  isEditing: .constant(false),
                  timeZone: timeZone,
                  index: index
                )
                .swipeActions(edge: .trailing) {
                  Button("Delete", systemImage: "trash", role: .destructive) {
                    timeZoneManager.removeTimeZone(id: timeZone.id)
                  }
                }
              }
              .onMove { offsets, destination in
                _ = timeZoneManager.moveTimeZone(from: offsets, to: destination)
              }
              .onDelete { offsets in
                _ = timeZoneManager.removeTimeZoneAt(at: offsets)
              }
            }
            if preferences.showTimeBar && preferences.showRockerControls {
              Section {
                TimeRockerControl()
              }
            }
          }
        }
        .listStyle(.plain)
        .environment(\.editMode, $editMode)
        .environment(timeViewPosition)
        .navigationTitle("ManyTime")
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            if !timeManager.isShowingCurrentTime {
              Button("Now", systemImage: "arrow.uturn.backward.circle") {
                timeManager.switchToCurrent()
              }
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

          ToolbarItem(placement: .topBarTrailing) {
            Menu {
              Button("About") {
                showingAbout = true
              }

              Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                  UIApplication.shared.open(url)
                }
              }
            } label: {
              Image(systemName: "ellipsis.circle")
            }
          }
        }
        .sheet(isPresented: $showingAdd) {
          NavigationStack {
            TimeZoneAddView()
              .navigationTitle("Add Time Zone")
              .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                  Button("Done") { showingAdd = false }
                }
              }
          }
        }
        .sheet(isPresented: $showingAbout) {
          AboutView()
        }
      }
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
