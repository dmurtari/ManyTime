import Testing
import Foundation
@testable import ManyTime

// Mock UserDefaults for testing
class MockUserDefaults: UserDefaultsProtocol {
    var storage: [String: Any] = [:]

    func data(forKey key: String) -> Data? {
        return storage[key] as? Data
    }

    func set(_ value: Any?, forKey key: String) {
        storage[key] = value
    }
}

// Mock TimeZoneProvider for testing
class MockTimeZoneProvider: TimeZoneProviding {
    var knownTimeZoneIdentifiers: [String] = [
        "America/Denver",
        "Europe/London",
        "Asia/Tokyo"
    ]

    var mockCurrent = TimeZone(secondsFromGMT: 0)!

    var current: TimeZone {
        return mockCurrent
    }

    func timeZone(identifier: String) -> TimeZone? {
        if knownTimeZoneIdentifiers.contains(identifier) {
            return TimeZone(identifier: identifier)
        }
        return nil
    }
}

@Suite("TimeZoneManager Tests")
struct TimeZoneManagerTests {
    @Test("Initial state should be empty")
    func testInitialState() {
        let mockUserDefaults = MockUserDefaults()
        let mockTimeZoneProvider = MockTimeZoneProvider()
        let timeZoneManager = TimeZoneManager(
            userDefaults: mockUserDefaults,
            timeZoneProvider: mockTimeZoneProvider,
            saveKey: "TestSavedTimeZones"
        )

        #expect(timeZoneManager.savedTimeZones.isEmpty)
    }

    @Test("Available time zone identifiers should match provider's identifiers")
    func testAvailableTimeZoneIdentifiers() {
        let mockUserDefaults = MockUserDefaults()
        let mockTimeZoneProvider = MockTimeZoneProvider()
        let timeZoneManager = TimeZoneManager(
            userDefaults: mockUserDefaults,
            timeZoneProvider: mockTimeZoneProvider,
            saveKey: "TestSavedTimeZones"
        )

        #expect(timeZoneManager.availableTimeZoneIdentifiers == mockTimeZoneProvider.knownTimeZoneIdentifiers)
    }

    @Test("Adding time zone with display name should succeed")
    func testAddTimeZone() {
        let mockUserDefaults = MockUserDefaults()
        let mockTimeZoneProvider = MockTimeZoneProvider()
        let timeZoneManager = TimeZoneManager(
            userDefaults: mockUserDefaults,
            timeZoneProvider: mockTimeZoneProvider,
            saveKey: "TestSavedTimeZones"
        )

        let nyTimeZone = TimeZone(identifier: "America/Denver")
        #expect(nyTimeZone != nil, "Could not create test time zone")

        let result = timeZoneManager.addTimeZone(nyTimeZone!, displayName: "Denver")

        #expect(result)
        #expect(timeZoneManager.savedTimeZones.count == 1)
        #expect(timeZoneManager.savedTimeZones[0].timeZone == "America/Denver")
        #expect(timeZoneManager.savedTimeZones[0].displayName == "Denver")
    }

    @Test("Adding time zone with nil display name should use identifier as display name")
    func testAddTimeZoneWithNilDisplayName() {
        let mockUserDefaults = MockUserDefaults()
        let mockTimeZoneProvider = MockTimeZoneProvider()
        let timeZoneManager = TimeZoneManager(
            userDefaults: mockUserDefaults,
            timeZoneProvider: mockTimeZoneProvider,
            saveKey: "TestSavedTimeZones"
        )

        let londonTimeZone = TimeZone(identifier: "Europe/London")
        #expect(londonTimeZone != nil, "Could not create test time zone")

        let result = timeZoneManager.addTimeZone(londonTimeZone!, displayName: nil)

        #expect(result)
        #expect(timeZoneManager.savedTimeZones.count == 1)
        #expect(timeZoneManager.savedTimeZones[0].timeZone == "Europe/London")
        #expect(timeZoneManager.savedTimeZones[0].displayName == "Europe/London")
    }

    @Test("TimeZoneItem with invalid identifier should fall back to current time zone")
    func testTimeZoneItemInvalidIdentifier() {
        let item = TimeZoneItem(timeZoneIdentifier: "Invalid/TimeZone", displayName: "Invalid")
        let retrievedTimeZone = item.timeZoneObject

        #expect(retrievedTimeZone == TimeZone.current)
    }

    @Test("Adding multiple time zones should succeed")
    func testAddMultipleTimeZones() {
        let mockUserDefaults = MockUserDefaults()
        let mockTimeZoneProvider = MockTimeZoneProvider()
        let timeZoneManager = TimeZoneManager(
            userDefaults: mockUserDefaults,
            timeZoneProvider: mockTimeZoneProvider,
            saveKey: "TestSavedTimeZones"
        )

        timeZoneManager.addTimeZone(TimeZone(identifier: "Europe/London")!, displayName: nil)
        #expect(timeZoneManager.savedTimeZones.count == 1)

        timeZoneManager.addTimeZone(TimeZone(identifier: "Asia/Tokyo")!, displayName: nil)
        #expect(timeZoneManager.savedTimeZones.count == 2)

        #expect(timeZoneManager.savedTimeZones[0].timeZone == "Europe/London")
        #expect(timeZoneManager.savedTimeZones[0].displayName == "Europe/London")
        #expect(timeZoneManager.savedTimeZones[1].timeZone == "Asia/Tokyo")
        #expect(timeZoneManager.savedTimeZones[1].displayName == "Asia/Tokyo")
    }
}
