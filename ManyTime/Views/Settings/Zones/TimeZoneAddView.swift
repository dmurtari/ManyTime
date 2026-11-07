import Combine
import MapKit
import SwiftUI

struct TimeZoneAddView: View {
  @EnvironmentObject private var timeZoneManager: TimeZoneManager
  @Environment(\.dismiss) private var dismiss

  @State private var timeZoneIdentifier: String = ""
  @State private var displayName: String = ""
  @State private var disableFields: Bool = false
  @State private var mode: SelectionMode = .city
  @State private var selectedCity: CityTimeZone?
  @State private var offsetMinutes: Int = 0

  private enum SelectionMode: String, CaseIterable, Identifiable {
    case city = "City"
    case offset = "Offset"
    var id: Self { self }
  }

  var body: some View {
    #if os(macOS)
      Form {
        HStack {
          TimeZonePicker(selectedTimeZone: $timeZoneIdentifier)
            .labelsHidden()
            .disabled(disableFields)
          TextField("Display Name", text: $displayName)
            .textFieldStyle(.roundedBorder)
            .labelsHidden()
            .disabled(disableFields)
        }

        HStack {
          Spacer()

          Button("Add") {
            save()
          }
          .disabled(disableFields)
        }
      }
      .onChange(of: timeZoneIdentifier) { _, newId in
        let timeZone = TimeZone(identifier: timeZoneIdentifier)

        guard let timeZone else {
          return
        }

        self.displayName = !self.displayName.isEmpty ? self.displayName : timeZone.description
      }
    #else
      Form {
        Section {
          Picker("Mode", selection: $mode) {
            ForEach(SelectionMode.allCases) { Text($0.rawValue).tag($0) }
          }
          .pickerStyle(.segmented)
        }

        Section {
          switch mode {
          case .city:
            NavigationLink {
              TimeZoneCitySearchView(selection: $selectedCity)
            } label: {
              LabeledContent(
                "City",
                value: selectedCity.map { "\($0.city), \($0.countryCode)" } ?? "Select…"
              )
            }
          case .offset:
            Picker("Offset", selection: $offsetMinutes) {
              ForEach(availableOffsets, id: \.self) {
                Text(TimeZone.gmtLabel(minutes: $0)).tag($0)
              }
            }
          }

          TextField("Display Name", text: $displayName, prompt: Text(defaultDisplayName))
        }

        Section {
          Button("Add") { saveIOS() }
            .disabled(mode == .city && selectedCity == nil)
        }
      }
    #endif
  }

  private func save() {
    if timeZoneIdentifier == "" {
      return
    }

    let timeZone = TimeZone(identifier: timeZoneIdentifier)

    guard let timeZone else {
      print("Failed to create TimeZone from identifier: \(timeZoneIdentifier)")
      return
    }

    let targetDisplayName = displayName.isEmpty ? timeZone.description : displayName

    timeZoneManager.addTimeZone(
      timeZone,
      displayName: targetDisplayName
    )

    self.displayName = ""
    self.timeZoneIdentifier = ""
  }

  private var defaultDisplayName: String {
    switch mode {
    case .city: return selectedCity?.city ?? "Display Name"
    case .offset: return TimeZone.gmtLabel(minutes: offsetMinutes)
    }
  }

  private var availableOffsets: [Int] {
    Set(TimeZoneListService.shared.getTimeZones().map(\.rawOffsetInMinutes)).sorted()
  }

  private func saveIOS() {
    let timeZone: TimeZone?
    switch mode {
    case .city:
      timeZone = selectedCity.flatMap { TimeZone(identifier: $0.name) }
    case .offset:
      timeZone = TimeZone(secondsFromGMT: offsetMinutes * 60)
    }

    guard let timeZone else {
      print("Failed to build TimeZone for mode \(mode)")
      return
    }

    timeZoneManager.addTimeZone(
      timeZone,
      displayName: displayName.isEmpty ? defaultDisplayName : displayName
    )

    displayName = ""
    selectedCity = nil
    dismiss()
  }
}

#Preview {
  TimeZoneAddView()
    .environment(TimeZoneManager())
}
