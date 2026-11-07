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

  var body: some View {
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
      .foregroundStyle(.primary)
    }
    .listStyle(.plain)
    .navigationTitle("Time Zone")
    .navigationBarTitleDisplayMode(.inline)
    .searchable(
      text: $query,
      placement: .navigationBarDrawer(displayMode: .always),
      prompt: "Search for a city"
    )
    .task {
      cities = TimeZoneListService.shared.getCityTimeZones()
        .sorted { $0.city.localizedCaseInsensitiveCompare($1.city) == .orderedAscending }
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

