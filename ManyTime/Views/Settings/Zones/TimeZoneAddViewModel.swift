import Foundation

struct TimeZoneAddViewModel {
  enum SelectionMode: String, CaseIterable, Identifiable {
    case city = "City"
    case offset = "Offset"
    var id: Self { self }
  }

  var displayName: String = ""
  var mode: SelectionMode = .city
  var selectedCity: CityTimeZone?
  var offsetMinutes: Int = 0

  var defaultDisplayName: String {
    switch mode {
    case .city: return selectedCity?.city ?? "Display Name"
    case .offset: return TimeZone.gmtLabel(minutes: offsetMinutes)
    }
  }

  @MainActor
  mutating func save(using timeZoneManager: TimeZoneManager) -> Bool {
    let timeZone: TimeZone?

    switch mode {
    case .city:
      timeZone = selectedCity.flatMap { TimeZone(identifier: $0.name) }
    case .offset:
      timeZone = TimeZone(secondsFromGMT: offsetMinutes * 60)
    }

    guard let timeZone else {
      print("Failed to build TimeZone for mode \(mode)")
      return false
    }

    timeZoneManager.addTimeZone(
      timeZone,
      displayName: displayName.isEmpty ? defaultDisplayName : displayName
    )

    displayName = ""
    selectedCity = nil
    return true
  }
}
