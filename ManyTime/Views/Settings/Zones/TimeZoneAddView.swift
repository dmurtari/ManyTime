import SwiftUI

struct TimeZoneAddView: View {
  @EnvironmentObject private var timeZoneManager: TimeZoneManager
  @Environment(\.dismiss) private var dismiss

  @State private var viewModel = TimeZoneAddViewModel()
  @State private var showingCitySearch = false

  var body: some View {
    #if os(macOS)
      Form {
        LabeledContent {
          switch viewModel.mode {
          case .city:
            Button {
              showingCitySearch = true
            } label: {
              HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(viewModel.selectedCity.map { "\($0.city), \($0.countryCode)" } ?? "Select…")
                  .foregroundStyle(viewModel.selectedCity == nil ? .secondary : .primary)
                  .padding(.trailing, 14)
                  .overlay(alignment: .trailing) {
                    Image(systemName: "chevron.up.chevron.down")
                      .font(.system(size: 10, weight: .semibold))
                      .foregroundStyle(.secondary)
                  }
              }
            }
            .popover(isPresented: $showingCitySearch) {
              CitySearchView(selection: $viewModel.selectedCity)
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .accessibilityLabel("City")
            .accessibilityValue(viewModel.selectedCity?.city ?? "None selected")

          case .offset:
            Picker("Offset", selection: $viewModel.offsetMinutes) {
              ForEach(availableOffsets, id: \.self) {
                Text(TimeZone.gmtLabel(minutes: $0)).tag($0)
              }
            }
            .pickerStyle(.menu)
            .labelsHidden()
          }
        } label: {
          Picker("Mode", selection: $viewModel.mode) {
            ForEach(TimeZoneAddViewModel.SelectionMode.allCases) { Text($0.rawValue).tag($0) }
          }
          .pickerStyle(.menu)
          .labelsHidden()
          .fixedSize()
        }

        TextField("Display Name", text: $viewModel.displayName, prompt: Text(viewModel.defaultDisplayName))

        HStack {
          Spacer()
          Button("Add") { save() }
            .keyboardShortcut(.defaultAction)
            .disabled(viewModel.selection == nil)
        }
      }
      .formStyle(.columns)
    #else
      Form {
        Section {
          Picker("Mode", selection: $viewModel.mode) {
            ForEach(TimeZoneAddViewModel.SelectionMode.allCases) { Text($0.rawValue).tag($0) }
          }
          .pickerStyle(.segmented)
          .labelsHidden()
        }

        Section {
          switch viewModel.mode {
          case .city:
            Button {
              showingCitySearch = true
            } label: {
              LabeledContent("City") {
                HStack(spacing: 4) {
                  Text(viewModel.selectedCity.map { "\($0.city), \($0.countryCode)" } ?? "Select…")
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
              CitySearchView(selection: $viewModel.selectedCity)
            }

          case .offset:
            Picker("Offset", selection: $viewModel.offsetMinutes) {
              ForEach(availableOffsets, id: \.self) {
                Text(TimeZone.gmtLabel(minutes: $0)).tag($0)
              }
            }
            .pickerStyle(.menu)
          }

          TextField("Display Name", text: $viewModel.displayName, prompt: Text(viewModel.defaultDisplayName))
        }

        Section {
          Button("Add") { save() }
            .keyboardShortcut(.defaultAction)
            .disabled(viewModel.selection == nil)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
      }
      .formStyle(.grouped)
    #endif
  }

  private var availableOffsets: [Int] {
    Set(TimeZoneListService.shared.getTimeZones().map(\.rawOffsetInMinutes)).sorted()
  }

  private func save() {
    guard viewModel.save(using: timeZoneManager) else { return }

#if os(iOS)
    dismiss()
#endif
  }
}

#Preview {
  TimeZoneAddView()
    .environment(TimeZoneManager())
}
