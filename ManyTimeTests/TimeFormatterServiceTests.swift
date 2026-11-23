import Foundation
import Testing

@testable import ManyTime

@MainActor
@Suite("TimeFormatterService Tests")
final class TimeFormatterServiceTests {
  private let originalMenuBarFormat: String
  private let originalDropdownFormat: String

  init() {
    originalMenuBarFormat = AppPreferences.shared.menuBarTimeFormat
    originalDropdownFormat = AppPreferences.shared.dropdownTimeFormat
  }

  @MainActor
  deinit {
    AppPreferences.shared.menuBarTimeFormat = originalMenuBarFormat
    AppPreferences.shared.dropdownTimeFormat = originalDropdownFormat
  }

  private func makeTestDate(hour: Int, minute: Int, month: Int) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!

    var components = DateComponents()
    components.year = 2026
    components.month = month
    components.day = 15
    components.hour = hour
    components.minute = minute

    return calendar.date(from: components)!
  }

  @Test("menuBarTimeFormat formats date correctly")
  func testMenuBarTimeFormatTimeZones() {
    AppPreferences.shared.menuBarTimeFormat = "HH:mm"
    let testDate = makeTestDate(hour: 12, minute: 30, month: 11)

    let utcItem = TimeZoneItem(timeZone: TimeZone(identifier: "UTC")!, displayName: "UTC")
    #expect(TimeFormatterService.shared.menuBarTimeFormat(from: testDate, timeZone: utcItem) == "12:30")

    let tokyoItem = TimeZoneItem(timeZone: TimeZone(identifier: "Asia/Tokyo")!, displayName: "Tokyo")
    #expect(TimeFormatterService.shared.menuBarTimeFormat(from: testDate, timeZone: tokyoItem) == "21:30")

    let nyItem = TimeZoneItem(timeZone: TimeZone(identifier: "America/New_York")!, displayName: "New York")
    #expect(TimeFormatterService.shared.menuBarTimeFormat(from: testDate, timeZone: nyItem) == "07:30")

    let summerDate = makeTestDate(hour: 12, minute: 30, month: 7)
    #expect(TimeFormatterService.shared.menuBarTimeFormat(from: summerDate, timeZone: nyItem) == "08:30")
  }

  @Test("dropdownTimeFormat formats date using dropdown preference format")
  func testDropdownTimeFormat() {
    AppPreferences.shared.dropdownTimeFormat = "h:mm a"
    let testDate = makeTestDate(hour: 14, minute: 45, month: 11)
    let utcItem = TimeZoneItem(timeZone: TimeZone(identifier: "UTC")!, displayName: "UTC")

    #expect(TimeFormatterService.shared.dropdownTimeFormat(from: testDate, timeZone: utcItem) == "2:45 PM")
  }

  @Test(
    "replaces {name} with a value",
    arguments: [
      ("London", "London 12:30"),
      ("King’s Cross", "King’s Cross 12:30")
    ]
  )
  func testNamePlaceholderReplacement(displayName: String, expected: String) {
    AppPreferences.shared.menuBarTimeFormat = "{name} HH:mm"
    let testDate = makeTestDate(hour: 12, minute: 30, month: 11)
    let item = TimeZoneItem(timeZone: TimeZone(identifier: "UTC")!, displayName: displayName)

    #expect(TimeFormatterService.shared.menuBarTimeFormat(from: testDate, timeZone: item) == expected)
  }

  @Test("falls back to normalizedDisplayName when displayName is nil")
  func testNormalizedDisplayNameFallback() {
    AppPreferences.shared.menuBarTimeFormat = "{name}"
    let testDate = makeTestDate(hour: 0, minute: 0, month: 11)
    let item = TimeZoneItem(timeZone: TimeZone(identifier: "America/New_York")!, displayName: nil)

    #expect(TimeFormatterService.shared.menuBarTimeFormat(from: testDate, timeZone: item) == "America/New York")
  }

  @Test("updateTimeFormat applies updated format")
  func testUpdateTimeFormatCacheClearing() {
    let testDate = makeTestDate(hour: 15, minute: 0, month: 11)
    let item = TimeZoneItem(timeZone: TimeZone(identifier: "UTC")!, displayName: "UTC")

    AppPreferences.shared.menuBarTimeFormat = "HH:mm"
    #expect(TimeFormatterService.shared.menuBarTimeFormat(from: testDate, timeZone: item) == "15:00")

    AppPreferences.shared.menuBarTimeFormat = "h a"
    #expect(TimeFormatterService.shared.menuBarTimeFormat(from: testDate, timeZone: item) == "3 PM")
  }

  @Test("Locale is12HourTimeFormat detects 12 vs 24 locales")
  func testLocaleIs12HourTimeFormat() {
    #expect(Locale(identifier: "en_US").is12HourTimeFormat)
    #expect(!Locale(identifier: "en_GB").is12HourTimeFormat)
  }
}
