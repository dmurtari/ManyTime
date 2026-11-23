import Foundation
import Testing
@testable import ManyTime

@MainActor
struct TimeZoneAddViewModelTests {
  private let tokyo = CityTimeZone(
    id: "tokyo", city: "Tokyo", countryCode: "JP",
    name: "Asia/Tokyo", rawOffsetInMinutes: 540
  )

  @Test func citySelectionAndNames() {
    let manager = TimeZoneManager(userDefaults: MockUserDefaults())
    var viewModel = TimeZoneAddViewModel()
    #expect(viewModel.selection == nil)
    viewModel.selectedCity = tokyo
    #expect(viewModel.selection?.timeZone.identifier == "Asia/Tokyo")
    #expect(viewModel.selection?.displayName == "Tokyo")
    let saved = viewModel.save(using: manager)
    #expect(saved)
    #expect(manager.savedTimeZones.first?.timeZone == "Asia/Tokyo")
    #expect(manager.savedTimeZones.first?.displayName == "Tokyo")
    #expect(viewModel.selectedCity == nil)

    viewModel.selectedCity = tokyo
    viewModel.displayName = "Office"
    let savedCustom = viewModel.save(using: manager)
    #expect(savedCustom)
    #expect(manager.savedTimeZones.last?.displayName == "Office")
    #expect(viewModel.displayName.isEmpty)
  }

  @Test func invalidSelectionDoesNotSaveOrReset() {
    let manager = TimeZoneManager(userDefaults: MockUserDefaults())
    var viewModel = TimeZoneAddViewModel()
    viewModel.selectedCity = CityTimeZone(
      id: "tokyo", city: "Tokyo", countryCode: "JP",
      name: "Invalid/Zone", rawOffsetInMinutes: 0
    )
    viewModel.displayName = "Office"
    #expect(viewModel.selection == nil)
    let saved = viewModel.save(using: manager)
    #expect(!saved)
    #expect(manager.savedTimeZones.isEmpty)
    #expect(viewModel.displayName == "Office")
    #expect(viewModel.selectedCity?.id == "tokyo")
  }

  @Test func fixedOffsetAndCustomName() throws {
    let manager = TimeZoneManager(userDefaults: MockUserDefaults())
    var viewModel = TimeZoneAddViewModel()
    viewModel.mode = .offset
    viewModel.offsetMinutes = 330
    let saved = viewModel.save(using: manager)
    #expect(saved)
    let item = try #require(manager.savedTimeZones.first)
    #expect(item.timeZoneObject.secondsFromGMT() == 19_800)
    #expect(item.displayName == TimeZone.gmtLabel(minutes: 330))
    #expect(viewModel.mode == .offset)
    #expect(viewModel.offsetMinutes == 330)
  }
}
