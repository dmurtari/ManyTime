import Foundation
import Observation

struct CityRow: Identifiable, Hashable {
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

  func load(cities: [CityTimeZone]) async {
    let rows = await Task.detached(priority: .userInitiated) {
      await Self.getSearchableCities(cities)
    }.value
    allCities = rows
    filtered = []
  }

  func search() async {
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

  private static func getSearchableCities(_ cities: [CityTimeZone]) -> [CityRow] {
    return
      cities
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
