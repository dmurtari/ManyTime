import Foundation
import Testing
@testable import ManyTime

@MainActor
struct CitySearchViewModelTests {
  private let cities = [
    CityTimeZone(id: "denver", city: "Denver", countryCode: "US", name: "America/Denver", rawOffsetInMinutes: -420),
    CityTimeZone(id: "tokyo", city: "Tokyo", countryCode: "JP", name: "Asia/Tokyo", rawOffsetInMinutes: 540),
    CityTimeZone(id: "london", city: "London", countryCode: "GB", name: "Europe/London", rawOffsetInMinutes: 0)
  ]

  @Test func searchMatchesCitiesWithMinimumLength() async {
    let viewModel = CitySearchViewModel()
    await viewModel.load(cities: cities)
    viewModel.query = "  DENVER "
    await viewModel.search()
    #expect(viewModel.filtered.map(\.city.id) == ["denver"])
    viewModel.query = "tok"
    await viewModel.search()
    #expect(viewModel.filtered.map(\.city.id) == ["tokyo"])
    viewModel.query = "to"
    await viewModel.search()
    #expect(viewModel.filtered.isEmpty)
  }

  @Test func cityPrefixMatchesAppearBeforeOtherMatches() async {
    let viewModel = CitySearchViewModel(locale: Locale(identifier: "en_US"))
    let nishiTokyo = CityTimeZone(
      id: "nishi-tokyo", city: "Nishi-Tokyo-shi", countryCode: "JP",
      name: "Asia/Tokyo", rawOffsetInMinutes: 540
    )
    await viewModel.load(cities: cities + [nishiTokyo])
    viewModel.query = "  TOKYO "
    await viewModel.search()
    #expect(viewModel.filtered.map(\.city.id) == ["tokyo", "nishi-tokyo"])
  }

  @Test func loadingAfterSearchUpdatesResults() async {
    let viewModel = CitySearchViewModel()
    viewModel.query = "tok"
    await viewModel.search()
    #expect(viewModel.filtered.isEmpty)
    await viewModel.load(cities: cities)
    #expect(viewModel.filtered.map(\.city.id) == ["tokyo"])
  }

  @Test func loadingDuringNewQueryDoesNotRestoreOldResults() async {
    let viewModel = CitySearchViewModel()
    await viewModel.load(cities: cities)
    viewModel.query = "tok"
    await viewModel.search()
    #expect(viewModel.filtered.map(\.city.id) == ["tokyo"])

    viewModel.query = "lon"
    await viewModel.load(cities: cities)
    #expect(viewModel.filtered.isEmpty)
    await viewModel.search()
    #expect(viewModel.filtered.map(\.city.id) == ["london"])
  }

  @Test func searchMatchesCountryAndSortsCities() async {
    let viewModel = CitySearchViewModel(locale: Locale(identifier: "en_US"))
    await viewModel.load(cities: cities)
    #expect(viewModel.allCities.map(\.city.id) == ["denver", "london", "tokyo"])
    viewModel.query = "japan"
    await viewModel.search()
    #expect(viewModel.filtered.map(\.city.id) == ["tokyo"])
  }

  @Test func cancelledSearchDoesNotReplaceResults() async {
    let viewModel = CitySearchViewModel()
    await viewModel.load(cities: cities)
    viewModel.query = "tok"
    await viewModel.search()
    viewModel.query = "lon"
    let pending = Task { await viewModel.search() }
    pending.cancel()
    await pending.value
    #expect(viewModel.filtered.map(\.city.id) == ["tokyo"])
  }
}
