import Foundation
import Testing

@testable import ManyTime

class MockUserDefaults: UserDefaultsProtocol {
    var storage: [String: Any] = [:]

    func data(forKey key: String) -> Data? {
        return storage[key] as? Data
    }

    func set(_ value: Any?, forKey key: String) {
        storage[key] = value
    }
}

class MockTimeZoneProvider: TimeZoneProviding {
    var knownTimeZoneIdentifiers: [String] = [
        "America/Denver",
        "Europe/London",
        "Asia/Tokyo",
        "America/New_York",
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

        #expect(
            timeZoneManager.availableTimeZoneIdentifiers == mockTimeZoneProvider.knownTimeZoneIdentifiers)
    }

    @Test("timeZone(identifier:) should return correct timezone")
    func testTimeZoneByIdentifier() {
        let mockUserDefaults = MockUserDefaults()
        let mockTimeZoneProvider = MockTimeZoneProvider()
        let timeZoneManager = TimeZoneManager(
            userDefaults: mockUserDefaults,
            timeZoneProvider: mockTimeZoneProvider,
            saveKey: "TestSavedTimeZones"
        )

        let timeZone = timeZoneManager.timeZone(identifier: "Europe/London")
        #expect(timeZone != nil)
        #expect(timeZone?.identifier == "Europe/London")

        let invalidTimeZone = timeZoneManager.timeZone(identifier: "Invalid/TimeZone")
        #expect(invalidTimeZone == nil)
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

        let denverTimeZone = TimeZone(identifier: "America/Denver")
        #expect(denverTimeZone != nil, "Could not create test time zone")

        let result = timeZoneManager.addTimeZone(denverTimeZone!, displayName: "Denver")

        #expect(result)
        #expect(timeZoneManager.savedTimeZones.count == 1)
        #expect(timeZoneManager.savedTimeZones[0].timeZone == "America/Denver")
        #expect(timeZoneManager.savedTimeZones[0].displayName == "Denver")
    }

    @Test("Adding time zone with nil display name should keep display name as nil")
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
        #expect(timeZoneManager.savedTimeZones[0].displayName == nil)
        #expect(timeZoneManager.savedTimeZones[0].normalizedDisplayName == "Europe/London")
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

        timeZoneManager.addTimeZone(TimeZone(identifier: "Europe/London")!, displayName: "London")
        #expect(timeZoneManager.savedTimeZones.count == 1)

        timeZoneManager.addTimeZone(TimeZone(identifier: "Asia/Tokyo")!, displayName: "Tokyo")
        #expect(timeZoneManager.savedTimeZones.count == 2)

        #expect(timeZoneManager.savedTimeZones[0].timeZone == "Europe/London")
        #expect(timeZoneManager.savedTimeZones[0].displayName == "London")
        #expect(timeZoneManager.savedTimeZones[1].timeZone == "Asia/Tokyo")
        #expect(timeZoneManager.savedTimeZones[1].displayName == "Tokyo")
    }

    @Test("Updating display name for existing timezone should succeed")
    func testUpdateDisplayName() {
        let mockUserDefaults = MockUserDefaults()
        let mockTimeZoneProvider = MockTimeZoneProvider()
        let timeZoneManager = TimeZoneManager(
            userDefaults: mockUserDefaults,
            timeZoneProvider: mockTimeZoneProvider,
            saveKey: "TestSavedTimeZones"
        )

        timeZoneManager.addTimeZone(TimeZone(identifier: "Europe/London")!, displayName: "London")
        let timeZoneId = timeZoneManager.savedTimeZones[0].id

        let result = timeZoneManager.updateDisplayName(for: timeZoneId, newName: "London, UK")

        #expect(result)
        #expect(timeZoneManager.savedTimeZones[0].displayName == "London, UK")
    }

    @Test("Updating display name to nil should reset to nil")
    func testUpdateDisplayNameToNil() {
        let mockUserDefaults = MockUserDefaults()
        let mockTimeZoneProvider = MockTimeZoneProvider()
        let timeZoneManager = TimeZoneManager(
            userDefaults: mockUserDefaults,
            timeZoneProvider: mockTimeZoneProvider,
            saveKey: "TestSavedTimeZones"
        )

        timeZoneManager.addTimeZone(TimeZone(identifier: "Europe/London")!, displayName: "London")
        let timeZoneId = timeZoneManager.savedTimeZones[0].id

        let result = timeZoneManager.updateDisplayName(for: timeZoneId, newName: nil)

        #expect(result)
        #expect(timeZoneManager.savedTimeZones[0].displayName == nil)
        #expect(timeZoneManager.savedTimeZones[0].normalizedDisplayName == "Europe/London")
    }

    @Test("Updating display name for non-existent timezone should fail")
    func testUpdateDisplayNameForNonExistentTimeZone() {
        let mockUserDefaults = MockUserDefaults()
        let mockTimeZoneProvider = MockTimeZoneProvider()
        let timeZoneManager = TimeZoneManager(
            userDefaults: mockUserDefaults,
            timeZoneProvider: mockTimeZoneProvider,
            saveKey: "TestSavedTimeZones"
        )

        let randomUUID = UUID()
        let result = timeZoneManager.updateDisplayName(for: randomUUID, newName: "New Name")

        #expect(!result)
    }

    @Test("Removing timezone by IndexSet should succeed")
    func testRemoveTimeZoneByIndexSet() {
        let mockUserDefaults = MockUserDefaults()
        let mockTimeZoneProvider = MockTimeZoneProvider()
        let timeZoneManager = TimeZoneManager(
            userDefaults: mockUserDefaults,
            timeZoneProvider: mockTimeZoneProvider,
            saveKey: "TestSavedTimeZones"
        )

        timeZoneManager.addTimeZone(TimeZone(identifier: "Europe/London")!, displayName: "London")
        timeZoneManager.addTimeZone(TimeZone(identifier: "Asia/Tokyo")!, displayName: "Tokyo")

        #expect(timeZoneManager.savedTimeZones.count == 2)

        let result = timeZoneManager.removeTimeZoneAt(at: IndexSet(integer: 0))

        #expect(result)
        #expect(timeZoneManager.savedTimeZones.count == 1)
        #expect(timeZoneManager.savedTimeZones[0].timeZone == "Asia/Tokyo")
    }

    @Test("Removing timezone by UUID should succeed")
    func testRemoveTimeZoneByUUID() {
        let mockUserDefaults = MockUserDefaults()
        let mockTimeZoneProvider = MockTimeZoneProvider()
        let timeZoneManager = TimeZoneManager(
            userDefaults: mockUserDefaults,
            timeZoneProvider: mockTimeZoneProvider,
            saveKey: "TestSavedTimeZones"
        )

        timeZoneManager.addTimeZone(TimeZone(identifier: "Europe/London")!, displayName: "London")
        timeZoneManager.addTimeZone(TimeZone(identifier: "Asia/Tokyo")!, displayName: "Tokyo")

        let londonId = timeZoneManager.savedTimeZones[0].id
        #expect(timeZoneManager.savedTimeZones.count == 2)

        let result = timeZoneManager.removeTimeZone(id: londonId)

        #expect(result)
        #expect(timeZoneManager.savedTimeZones.count == 1)
        #expect(timeZoneManager.savedTimeZones[0].timeZone == "Asia/Tokyo")
    }

    @Test("Removing timezone with non-existent UUID should fail")
    func testRemoveTimeZoneWithNonExistentUUID() {
        let mockUserDefaults = MockUserDefaults()
        let mockTimeZoneProvider = MockTimeZoneProvider()
        let timeZoneManager = TimeZoneManager(
            userDefaults: mockUserDefaults,
            timeZoneProvider: mockTimeZoneProvider,
            saveKey: "TestSavedTimeZones"
        )

        let randomUUID = UUID()
        let result = timeZoneManager.removeTimeZone(id: randomUUID)

        #expect(!result)
    }

    @Test("Moving timezone should succeed")
    func testMoveTimeZone() {
        let mockUserDefaults = MockUserDefaults()
        let mockTimeZoneProvider = MockTimeZoneProvider()
        let timeZoneManager = TimeZoneManager(
            userDefaults: mockUserDefaults,
            timeZoneProvider: mockTimeZoneProvider,
            saveKey: "TestSavedTimeZones"
        )

        timeZoneManager.addTimeZone(TimeZone(identifier: "Europe/London")!, displayName: "London")
        timeZoneManager.addTimeZone(TimeZone(identifier: "Asia/Tokyo")!, displayName: "Tokyo")
        timeZoneManager.addTimeZone(TimeZone(identifier: "America/Denver")!, displayName: "Denver")

        #expect(timeZoneManager.savedTimeZones[0].timeZone == "Europe/London")
        #expect(timeZoneManager.savedTimeZones[1].timeZone == "Asia/Tokyo")
        #expect(timeZoneManager.savedTimeZones[2].timeZone == "America/Denver")

        let result = timeZoneManager.moveTimeZone(from: IndexSet(integer: 0), to: 2)

        #expect(result)
        #expect(timeZoneManager.savedTimeZones[0].timeZone == "Asia/Tokyo")
        #expect(timeZoneManager.savedTimeZones[1].timeZone == "Europe/London")
        #expect(timeZoneManager.savedTimeZones[2].timeZone == "America/Denver")
    }

    @Test("Resetting timezone should clear display name")
    func testResetTimeZone() {
        let mockUserDefaults = MockUserDefaults()
        let mockTimeZoneProvider = MockTimeZoneProvider()
        let timeZoneManager = TimeZoneManager(
            userDefaults: mockUserDefaults,
            timeZoneProvider: mockTimeZoneProvider,
            saveKey: "TestSavedTimeZones"
        )

        timeZoneManager.addTimeZone(TimeZone(identifier: "Europe/London")!, displayName: "London, UK")
        let timeZoneItem = timeZoneManager.savedTimeZones[0]

        #expect(timeZoneItem.displayName == "London, UK")

        let result = timeZoneManager.resetTimeZone(timeZoneItem)

        #expect(result)
        #expect(timeZoneManager.savedTimeZones[0].displayName == nil)
        #expect(timeZoneManager.savedTimeZones[0].normalizedDisplayName == "Europe/London")
    }

    @Test("TimeZoneItem with invalid identifier should fall back to current time zone")
    func testTimeZoneItemInvalidIdentifier() {
        let item = TimeZoneItem(timeZoneIdentifier: "Invalid/TimeZone", displayName: "Invalid")
        let retrievedTimeZone = item.timeZoneObject

        #expect(retrievedTimeZone == TimeZone.current)
    }

    @Test("TimeZoneItem normalizedDisplayName should handle underscores")
    func testTimeZoneItemNormalizedDisplayName() {
        let item = TimeZoneItem(timeZone: TimeZone(identifier: "America/New_York")!, displayName: nil)

        #expect(item.normalizedDisplayName == "America/New York")
    }

    @Test("TimeZoneItem normalizedDisplayName should use custom display name when available")
    func testTimeZoneItemNormalizedDisplayNameWithCustomName() {
        let item = TimeZoneItem(timeZone: TimeZone(identifier: "America/New_York")!, displayName: "NYC")

        #expect(item.normalizedDisplayName == "NYC")
    }

    @Test("TimeZones should persist between manager instances")
    func testPersistence() {
        let mockUserDefaults = MockUserDefaults()
        let mockTimeZoneProvider = MockTimeZoneProvider()

        let firstManager = TimeZoneManager(
            userDefaults: mockUserDefaults,
            timeZoneProvider: mockTimeZoneProvider,
            saveKey: "TestSavedTimeZones"
        )

        firstManager.addTimeZone(TimeZone(identifier: "Europe/London")!, displayName: "London")
        #expect(firstManager.savedTimeZones.count == 1)

        let secondManager = TimeZoneManager(
            userDefaults: mockUserDefaults,
            timeZoneProvider: mockTimeZoneProvider,
            saveKey: "TestSavedTimeZones"
        )

        #expect(secondManager.savedTimeZones.count == 1)
        #expect(secondManager.savedTimeZones[0].timeZone == "Europe/London")
        #expect(secondManager.savedTimeZones[0].displayName == "London")
    }

    @Test("Manager should handle corrupted save data gracefully")
    func testCorruptedSaveData() {
        let mockUserDefaults = MockUserDefaults()
        let mockTimeZoneProvider = MockTimeZoneProvider()

        mockUserDefaults.set("corrupted data".data(using: .utf8), forKey: "TestSavedTimeZones")

        let timeZoneManager = TimeZoneManager(
            userDefaults: mockUserDefaults,
            timeZoneProvider: mockTimeZoneProvider,
            saveKey: "TestSavedTimeZones"
        )

        #expect(timeZoneManager.savedTimeZones.isEmpty)
    }

    @Test("Manager should handle missing save data gracefully")
    func testMissingSaveData() {
        let mockUserDefaults = MockUserDefaults()
        let mockTimeZoneProvider = MockTimeZoneProvider()

        let timeZoneManager = TimeZoneManager(
            userDefaults: mockUserDefaults,
            timeZoneProvider: mockTimeZoneProvider,
            saveKey: "TestSavedTimeZones"
        )

        #expect(timeZoneManager.savedTimeZones.isEmpty)
    }

    @Test("Operations on empty timezone list should handle gracefully")
    func testOperationsOnEmptyList() {
        let mockUserDefaults = MockUserDefaults()
        let mockTimeZoneProvider = MockTimeZoneProvider()
        let timeZoneManager = TimeZoneManager(
            userDefaults: mockUserDefaults,
            timeZoneProvider: mockTimeZoneProvider,
            saveKey: "TestSavedTimeZones"
        )

        let removeResult = timeZoneManager.removeTimeZoneAt(at: IndexSet(integer: 0))
        #expect(removeResult)

        let removeByIdResult = timeZoneManager.removeTimeZone(id: UUID())
        #expect(!removeByIdResult)

        let updateResult = timeZoneManager.updateDisplayName(for: UUID(), newName: "Test")
        #expect(!updateResult)
    }
}
