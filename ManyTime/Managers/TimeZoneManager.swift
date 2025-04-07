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
    }

    var timeZoneObject: TimeZone {
        TimeZone(identifier: timeZone) ?? TimeZone.current
    }
}

class TimeZoneManager: ObservableObject, Observable {
    @Published var savedTimeZones: [TimeZoneItem] = []
    private let saveKey = "SavedTimeZones"

    init() {
        loadTimeZones()
    }

    var availableTimeZoneIdentifiers: [String] {
        TimeZone.knownTimeZoneIdentifiers;
    }

    func addTimeZone(_ timeZone: TimeZone, displayName: String?) {
        let newItem = TimeZoneItem(timeZone: timeZone, displayName: displayName)
        savedTimeZones.append(newItem)
        saveTimeZones()
    }

    func updateDisplayName(for id: UUID, newName: String) {
        if let index = savedTimeZones.firstIndex(where: { $0.id == id }) {
            savedTimeZones[index].displayName = newName
            saveTimeZones()
        }
    }

    func removeTimeZoneAt(at offsets: IndexSet) {
        savedTimeZones.remove(atOffsets: offsets)
        saveTimeZones()
    }

    func removeTimeZone(id: UUID) {
        if let index = savedTimeZones.firstIndex(where: { $0.id == id }) {
            savedTimeZones.remove(at: index)
            saveTimeZones()
        }
    }

    func moveTimeZone(from source: IndexSet, to destination: Int) {
        savedTimeZones.move(fromOffsets: source, toOffset: destination)
        saveTimeZones()
    }

    private func saveTimeZones() {
        if let encoded = try? JSONEncoder().encode(savedTimeZones) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func loadTimeZones() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([TimeZoneItem].self, from: data) {
            savedTimeZones = decoded
        }
    }
}
