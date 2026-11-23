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

  @Test func loadingClearsEarlierSearchResults() async {
    let viewModel = CitySearchViewModel()
    await viewModel.load(cities: cities)
    viewModel.query = "tok"
    await viewModel.search()
    #expect(viewModel.filtered.map(\.city.id) == ["tokyo"])
    await viewModel.load(cities: cities)
    #expect(viewModel.filtered.isEmpty)
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
