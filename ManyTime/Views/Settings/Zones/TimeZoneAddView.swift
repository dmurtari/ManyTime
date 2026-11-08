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
  @State private var showingCitySearch = false

  private enum SelectionMode: String, CaseIterable, Identifiable {
    case city = "City"
    case offset = "Offset"
    var id: Self { self }
  }

  var body: some View {
    #if os(macOS)
      Form {
        LabeledContent {
          switch mode {
          case .city:
            Button {
              showingCitySearch = true
            } label: {
              HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(selectedCity.map { "\($0.city), \($0.countryCode)" } ?? "Select…")
                  .foregroundStyle(selectedCity == nil ? .secondary : .primary)
                  .padding(.trailing, 14)
                  .overlay(alignment: .trailing) {
                    Image(systemName: "chevron.up.chevron.down")
                      .font(.system(size: 10, weight: .semibold))
                      .foregroundStyle(.secondary)
                  }
              }
            }
            .popover(isPresented: $showingCitySearch) {
              TimeZoneCitySearchView(selection: $selectedCity)
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .accessibilityLabel("City")
            .accessibilityValue(selectedCity?.city ?? "None selected")

          case .offset:
            Picker("Offset", selection: $offsetMinutes) {
              ForEach(availableOffsets, id: \.self) {
                Text(TimeZone.gmtLabel(minutes: $0)).tag($0)
              }
            }
            .pickerStyle(.menu)
            .labelsHidden()
          }
        } label: {
          Picker("Mode", selection: $mode) {
            ForEach(SelectionMode.allCases) { Text($0.rawValue).tag($0) }
          }
          .pickerStyle(.menu)
          .labelsHidden()
          .fixedSize()
        }

        TextField("Display Name", text: $displayName, prompt: Text(defaultDisplayName))

        HStack {
          Spacer()
          Button("Add") { save() }
            .keyboardShortcut(.defaultAction)
            .disabled(mode == .city && selectedCity == nil)
        }
      }
      .formStyle(.columns)
    #else
      Form {
        Section {
          Picker("Mode", selection: $mode) {
            ForEach(SelectionMode.allCases) { Text($0.rawValue).tag($0) }
          }
          .pickerStyle(.segmented)
          .labelsHidden()
        }

        Section {
          switch mode {
          case .city:
            Button {
              showingCitySearch = true
            } label: {
              LabeledContent("City") {
                HStack(spacing: 4) {
                  Text(selectedCity.map { "\($0.city), \($0.countryCode)" } ?? "Select…")
                    .foregroundStyle(.secondary)
                  Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                }
              }
              .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showingCitySearch) {
              TimeZoneCitySearchView(selection: $selectedCity)
            }

          case .offset:
            Picker("Offset", selection: $offsetMinutes) {
              ForEach(availableOffsets, id: \.self) {
                Text(TimeZone.gmtLabel(minutes: $0)).tag($0)
              }
            }
            .pickerStyle(.menu)
          }

          TextField("Display Name", text: $displayName, prompt: Text(defaultDisplayName))
        }

        Section {
          Button("Add") { save() }
            .keyboardShortcut(.defaultAction)
            .disabled(mode == .city && selectedCity == nil)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
      }
      .formStyle(.grouped)
    #endif
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

  private func save() {
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
