//
//  TimeZoneManager.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import SwiftUI

struct TimeZoneItem: Identifiable, Codable, Equatable {
    let id: UUID
    let timeZone: String
    var displayName: String

    init(timeZone: TimeZone, displayName: String?) {
        self.id = UUID()
        self.timeZone = timeZone.identifier
        self.displayName = displayName ?? timeZone.identifier
            .replacingOccurrences(of: "_", with: " ")
    }

    // Added for testing purposes
    init(id: UUID = UUID(), timeZoneIdentifier: String, displayName: String) {
        self.id = id
        self.timeZone = timeZoneIdentifier
        self.displayName = displayName
    }

    var timeZoneObject: TimeZone {
        TimeZone(identifier: timeZone) ?? TimeZone.current
    }
}

// Protocol for UserDefaults-like storage
protocol UserDefaultsProtocol {
    func data(forKey: String) -> Data?
    func set(_ value: Any?, forKey: String)
}

// Extension to make UserDefaults conform to our protocol
extension UserDefaults: UserDefaultsProtocol {}

// Protocol for TimeZone-related operations
protocol TimeZoneProviding {
    var knownTimeZoneIdentifiers: [String] { get }
    func timeZone(identifier: String) -> TimeZone?
    var current: TimeZone { get }
}

// Default implementation using system TimeZone
class SystemTimeZoneProvider: TimeZoneProviding {
    var knownTimeZoneIdentifiers: [String] {
        TimeZone.knownTimeZoneIdentifiers
    }

    func timeZone(identifier: String) -> TimeZone? {
        TimeZone(identifier: identifier)
    }

    var current: TimeZone {
        TimeZone.current
    }
}

class TimeZoneManager: ObservableObject, Observable {
    @Published var savedTimeZones: [TimeZoneItem] = []
    private let saveKey: String
    private let userDefaults: UserDefaultsProtocol
    private let timeZoneProvider: TimeZoneProviding

    init(
        userDefaults: UserDefaultsProtocol = UserDefaults.standard,
        timeZoneProvider: TimeZoneProviding = SystemTimeZoneProvider(),
        saveKey: String = "SavedTimeZones"
    ) {
        self.userDefaults = userDefaults
        self.timeZoneProvider = timeZoneProvider
        self.saveKey = saveKey
        loadTimeZones()
    }

    var availableTimeZoneIdentifiers: [String] {
        timeZoneProvider.knownTimeZoneIdentifiers
    }

    func timeZone(identifier: String) -> TimeZone? {
        timeZoneProvider.timeZone(identifier: identifier)
    }

    func addTimeZone(_ timeZone: TimeZone, displayName: String?) -> Bool {
        let newItem = TimeZoneItem(timeZone: timeZone, displayName: displayName)
        savedTimeZones.append(newItem)
        return saveTimeZones()
    }

    func updateDisplayName(for id: UUID, newName: String) -> Bool {
        guard let index = savedTimeZones.firstIndex(where: { $0.id == id }) else {
            return false
        }

        savedTimeZones[index].displayName = newName
        return saveTimeZones()
    }

    func removeTimeZoneAt(at offsets: IndexSet) -> Bool {
        savedTimeZones.remove(atOffsets: offsets)
        return saveTimeZones()
    }

    func removeTimeZone(id: UUID) -> Bool {
        guard let index = savedTimeZones.firstIndex(where: { $0.id == id }) else {
            return false
        }

        savedTimeZones.remove(at: index)
        return saveTimeZones()
    }

    func moveTimeZone(from source: IndexSet, to destination: Int) -> Bool {
        savedTimeZones.move(fromOffsets: source, toOffset: destination)
        return saveTimeZones()
    }

    @discardableResult
    private func saveTimeZones() -> Bool {
        do {
            let encoded = try JSONEncoder().encode(savedTimeZones)
            userDefaults.set(encoded, forKey: saveKey)
            return true
        } catch {
            print("Failed to save time zones: \(error)")
            return false
        }
    }

    private func loadTimeZones() {
        guard let data = userDefaults.data(forKey: saveKey) else {
            savedTimeZones = []
            return
        }

        do {
            savedTimeZones = try JSONDecoder().decode([TimeZoneItem].self, from: data)
        } catch {
            print("Failed to load time zones: \(error)")
            savedTimeZones = []
        }
    }
}
