import Foundation
import Testing

@testable import ManyTime

@MainActor
@Suite("TimeManager Tests")
struct TimeManagerTests {
  let timeManager = TimeManager()

  @Test("Initial state should be current time mode and showing current time")
  func testInitialState() {
    #expect(timeManager.timeMode == .current)
    #expect(timeManager.isShowingCurrentTime)
  }

  @Test("displayDate in current mode truncates seconds and nanoseconds")
  func testDisplayDateInCurrentMode() {
    var components = DateComponents()
    components.year = 2026
    components.month = 5
    components.day = 10
    components.hour = 14
    components.minute = 23
    components.second = 45
    components.nanosecond = 500_000_000

    let testDate = Calendar.current.date(from: components)!
    timeManager.currentDate = testDate

    let displayComponents = Calendar.current.dateComponents(
      [.year, .month, .day, .hour, .minute, .second],
      from: timeManager.displayDate
    )

    #expect(displayComponents.year == 2026)
    #expect(displayComponents.month == 5)
    #expect(displayComponents.day == 10)
    #expect(displayComponents.hour == 14)
    #expect(displayComponents.minute == 23)
    #expect(displayComponents.second == 0)
  }

  @Test("displayDate in fixed mode truncates seconds and nanoseconds")
  func testDisplayDateInFixedMode() {
    var components = DateComponents()
    components.year = 2026
    components.month = 5
    components.day = 10
    components.hour = 14
    components.minute = 23
    components.second = 45
    components.nanosecond = 500_000_000

    let testDate = Calendar.current.date(from: components)!
    timeManager.setFixedTime(testDate)

    let displayComponents = Calendar.current.dateComponents(
      [.year, .month, .day, .hour, .minute, .second],
      from: timeManager.displayDate
    )

    #expect(displayComponents.year == 2026)
    #expect(displayComponents.month == 5)
    #expect(displayComponents.day == 10)
    #expect(displayComponents.hour == 14)
    #expect(displayComponents.minute == 23)
    #expect(displayComponents.second == 0)
  }

  @Test("setFixedTime updates timeMode and displayDate")
  func testSetFixedTime() {
    let fixedDate = Calendar.current.date(
      from: DateComponents(year: 2026, month: 1, day: 1, hour: 12, minute: 0, second: 0)
    )!
    timeManager.setFixedTime(fixedDate)

    #expect(timeManager.timeMode == .fixed(fixedDate))
    #expect(timeManager.displayDate == fixedDate)
  }

  @Test("switchToCurrent resets timeMode to current")
  func testSwitchToCurrent() {
    let fixedDate = Calendar.current.date(
      from: DateComponents(year: 2026, month: 1, day: 1, hour: 12, minute: 0, second: 0)
    )!
    timeManager.setFixedTime(fixedDate)
    timeManager.switchToCurrent()

    #expect(timeManager.timeMode == .current)
    #expect(timeManager.isShowingCurrentTime)
  }

  @Test(
    "isShowingCurrentTime returns true only when the fixed date is in the same minute",
    arguments: [
      (offset: 0.0, expected: true),
      (offset: 30.0, expected: true),
      (offset: 70.0, expected: false),
      (offset: 3600.0, expected: false)
    ]
  )
  func testIsShowingCurrentTime(offset: Double, expected: Bool) {
    let base = Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 12, minute: 0, second: 0))!
    timeManager.currentDate = base
    timeManager.setFixedTime(base.addingTimeInterval(offset))

    #expect(timeManager.isShowingCurrentTime == expected)
  }

  @Test("A closed menu resets the time after the delay")
  func testScheduledMenuReset() async throws {
    let fixedDate = Date(timeIntervalSince1970: 1000)
    timeManager.setFixedTime(fixedDate)
    timeManager.scheduleMenuReset(after: 0.05)
    #expect(timeManager.timeMode == .fixed(fixedDate))
    try await Task.sleep(for: .milliseconds(200))
    #expect(timeManager.timeMode == .current)
  }

  @Test("Reopening the menu cancels the scheduled reset")
  func testCancelMenuReset() async throws {
    let fixedDate = Date(timeIntervalSince1970: 1000)
    timeManager.setFixedTime(fixedDate)
    timeManager.scheduleMenuReset(after: 0.05)
    timeManager.cancelMenuReset()
    try await Task.sleep(for: .milliseconds(200))
    #expect(timeManager.timeMode == .fixed(fixedDate))
  }

  @Test("TimeMode equality")
  func testTimeModeEquality() {
    let date1 = Date(timeIntervalSince1970: 1000)
    let date2 = Date(timeIntervalSince1970: 2000)

    #expect(TimeMode.current == TimeMode.current)
    #expect(TimeMode.fixed(date1) == TimeMode.fixed(date1))
    #expect(TimeMode.fixed(date1) != TimeMode.fixed(date2))
    #expect(TimeMode.current != TimeMode.fixed(date1))
  }
}
