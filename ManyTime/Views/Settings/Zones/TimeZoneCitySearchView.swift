//
//  TimeZoneCitySearchView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2026/11/07.
//

import SwiftUI

struct CityRow: Identifiable, Hashable {
  var id: String { city.id }

  let city: CityTimeZone
  let countryDisplayName: String
  let gmtDisplay: String
  let searchString: String
}

struct TimeZoneCitySearchView: View {
  @Binding var selection: CityTimeZone?

  @Environment(\.dismiss) private var dismiss
  @State private var query = ""
  @State private var allCities: [CityRow] = []
  @State private var filtered: [CityRow] = []

  @FocusState private var searchFocused: Bool

  var body: some View {
    VStack(spacing: 0) {
      TextField("Search for a city", text: $query)
        .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
        .focused($searchFocused)
        .padding()

      List(filtered.prefix(8), id: \.id) { row in
        Button {
          selection = row.city
          dismiss()
        } label: {
          HStack {
            VStack(alignment: .leading) {
              Text(row.city.city)
              Text(row.countryDisplayName)
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(row.gmtDisplay)
              .foregroundStyle(.secondary)

            if selection?.id == row.city.id {
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
      searchFocused = true
      let rows = await Task.detached(priority: .userInitiated) {
        await Self.getSearchableCities()
      }.value
      allCities = rows
      filtered = []
    }
    .task(id: query) {
      let trimmed = query.trimmingCharacters(in: .whitespaces)
      if trimmed.count < 3 {
        filtered = []
        return
      }

      do {
        try await Task.sleep(for: .milliseconds(150))
      } catch {
        return
      }

      let q = trimmed.folding(
        options: [.caseInsensitive, .diacriticInsensitive],
        locale: .current
      )

      filtered = allCities.filter { $0.searchString.contains(q) }
    }
  }

  private static func getSearchableCities() -> [CityRow] {
    return
      TimeZoneListService.shared.getCityTimeZones()
      .sorted {
        $0.city.localizedCaseInsensitiveCompare($1.city) == .orderedAscending
      }.map { city in
        let countryDisplayName = countryName(city.countryCode)
        let gmtDisplay = gmtLabel(for: city.name)
        let searchString = [city.city, countryDisplayName, city.countryCode]
          .joined(separator: " ")
          .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)

        return CityRow(
          city: city,
          countryDisplayName: countryDisplayName,
          gmtDisplay: gmtDisplay,
          searchString: searchString
        )
      }
  }

  private static func countryName(_ code: String) -> String {
    Locale.current.localizedString(forRegionCode: code) ?? code
  }

  private static func gmtLabel(for identifier: String) -> String {
    TimeZone(identifier: identifier)?.gmtLabel ?? ""
  }
}

#Preview {
  TimeZoneCitySearchView(selection: .constant(nil))
}
