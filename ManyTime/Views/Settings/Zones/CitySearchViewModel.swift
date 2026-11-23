import Foundation
import Observation

struct CityRow: Identifiable, Hashable, Sendable {
  var id: String { city.id }

  let city: CityTimeZone
  let countryDisplayName: String
  let gmtDisplay: String
  let searchString: String
}

@MainActor
@Observable
final class CitySearchViewModel {
  var query = ""
  private(set) var allCities: [CityRow] = []
  private(set) var filtered: [CityRow] = []
  private var debouncedQuery = ""
  private let locale: Locale

  init(locale: Locale = .current) {
    self.locale = locale
  }

  func load(cities: [CityTimeZone]) async {
    let locale = locale
    let task = Task.detached(priority: .userInitiated) {
      Self.prepareCities(cities, locale: locale)
    }
    let rows = await withTaskCancellationHandler {
      await task.value
    } onCancel: {
      task.cancel()
    }
    guard !Task.isCancelled else { return }
    allCities = rows

    let currentQuery = query.trimmingCharacters(in: .whitespaces)
    if currentQuery == debouncedQuery {
      apply(debouncedQuery)
    } else {
      filtered = []
    }
  }

  nonisolated private static func prepareCities(
    _ cities: [CityTimeZone], locale: Locale
  ) -> [CityRow] {
    cities.sorted {
      $0.city.localizedCaseInsensitiveCompare($1.city) == .orderedAscending
    }.map { city in
      let country = locale.localizedString(forRegionCode: city.countryCode) ?? city.countryCode
      let searchString = [city.city, country, city.countryCode]
        .joined(separator: " ")
        .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: locale)
      return CityRow(
        city: city,
        countryDisplayName: country,
        gmtDisplay: TimeZone(identifier: city.name)?.gmtLabel ?? "",
        searchString: searchString
      )
    }
  }

  func search() async {
    let trimmed = query.trimmingCharacters(in: .whitespaces)
    guard trimmed.count >= 3 else {
      debouncedQuery = ""
      filtered = []
      return
    }

    do {
      try await Task.sleep(for: .milliseconds(150))
      try Task.checkCancellation()
    } catch {
      return
    }
    guard query.trimmingCharacters(in: .whitespaces) == trimmed else { return }
    debouncedQuery = trimmed
    apply(trimmed)
  }

  private func apply(_ text: String) {
    guard text.count >= 3 else {
      filtered = []
      return
    }
    let normalized = text.folding(
      options: [.caseInsensitive, .diacriticInsensitive],
      locale: locale
    )
    var prefixMatches: [CityRow] = []
    var otherMatches: [CityRow] = []
    for row in allCities {
      if row.searchString.hasPrefix(normalized) {
        prefixMatches.append(row)
      } else if row.searchString.contains(normalized) {
        otherMatches.append(row)
      }
    }
    filtered = prefixMatches + otherMatches
  }
}
