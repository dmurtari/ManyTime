//
//  TimeZoneCitySearchView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2026/11/07.
//

import SwiftUI

struct TimeZoneCitySearchView: View {
  @Binding var selection: CityTimeZone?

  @Environment(\.dismiss) private var dismiss
  @State private var query = ""
  @State private var cities: [CityTimeZone] = []

  @FocusState private var searchFocused: Bool

  var body: some View {
    VStack(spacing: 0) {
      TextField("Search for a city", text: $query)
        .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
        .focused($searchFocused)
        .padding()

      List(results, id: \.id) { city in
        Button {
          selection = city
          dismiss()
        } label: {
          HStack {
            VStack(alignment: .leading) {
              Text(city.city)
              Text(countryName(city.countryCode))
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(gmtLabel(for: city.name))
              .foregroundStyle(.secondary)

            if selection?.id == city.id {
              Image(systemName: "checkmark")
                .foregroundStyle(.tint)
            }
          }
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
      }
      .listStyle(.plain)
    }
    .frame(minWidth: 320, minHeight: 380)
    .task {
      cities = TimeZoneListService.shared.getCityTimeZones()
        .sorted { $0.city.localizedCaseInsensitiveCompare($1.city) == .orderedAscending }
      searchFocused = true
    }
  }

  private var results: [CityTimeZone] {
    let q = query.trimmingCharacters(in: .whitespaces)
    guard !q.isEmpty else { return cities }
    return cities.filter {
      $0.city.localizedStandardContains(q)
        || countryName($0.countryCode).localizedStandardContains(q)
        || $0.countryCode.localizedCaseInsensitiveContains(q)
        || $0.name.localizedStandardContains(q)
    }
  }

  private func countryName(_ code: String) -> String {
    Locale.current.localizedString(forRegionCode: code) ?? code
  }

  private func gmtLabel(for identifier: String) -> String {
    TimeZone(identifier: identifier)?.gmtLabel ?? ""
  }
}
