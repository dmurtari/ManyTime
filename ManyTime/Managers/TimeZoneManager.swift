//
//  TimeZoneManager.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import Combine
import SwiftUI

struct TimeZoneItem: Identifiable, Codable, Equatable {
  let id: UUID
  let timeZone: String
  var displayName: String?

  init(timeZone: TimeZone, displayName: String?) {
    self.id = UUID()
    self.timeZone = timeZone.identifier
    self.displayName = displayName
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

  var normalizedDisplayName: String {
    displayName
      ?? timeZoneObject
      .identifier
      .replacingOccurrences(of: "_", with: " ")
  }
}

protocol UserDefaultsProtocol {
  func data(forKey: String) -> Data?
  func set(_ value: Any?, forKey: String)
}

extension UserDefaults: UserDefaultsProtocol {}

protocol TimeZoneProviding {
  var knownTimeZoneIdentifiers: [String] { get }
  func timeZone(identifier: String) -> TimeZone?
  var current: TimeZone { get }
}

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

@MainActor
class TimeZoneManager: ObservableObject, Observable {
  @Published var savedTimeZones: [TimeZoneItem] = []
  private let saveKey: String
  private let userDefaults: UserDefaultsProtocol
  private let timeZoneProvider: TimeZoneProviding
  private var cancellables = Set<AnyCancellable>()

  init(
    userDefaults: UserDefaultsProtocol = UserDefaults.standard,
    timeZoneProvider: TimeZoneProviding = SystemTimeZoneProvider(),
    saveKey: String = "SavedTimeZones"
  ) {
    self.userDefaults = userDefaults
    self.timeZoneProvider = timeZoneProvider
    self.saveKey = saveKey
    loadTimeZones()
    addListeners()
  }

  var availableTimeZoneIdentifiers: [String] {
    timeZoneProvider.knownTimeZoneIdentifiers
  }

  func timeZone(identifier: String) -> TimeZone? {
    timeZoneProvider.timeZone(identifier: identifier)
  }

  @discardableResult
  func addTimeZone(_ timeZone: TimeZone, displayName: String?) -> Bool {
    let newItem = TimeZoneItem(timeZone: timeZone, displayName: displayName)
    savedTimeZones.append(newItem)
    return saveTimeZones()
  }

  @discardableResult
  func updateDisplayName(for id: UUID, newName: String?) -> Bool {
    guard let index = savedTimeZones.firstIndex(where: { $0.id == id }) else {
      return false
    }

    if newName != nil {
      savedTimeZones[index].displayName = newName
    } else {
      savedTimeZones[index].displayName = nil
    }

    return saveTimeZones()
  }

  @discardableResult
  func removeTimeZoneAt(at offsets: IndexSet) -> Bool {
    savedTimeZones.remove(atOffsets: offsets)
    return saveTimeZones()
  }

  @discardableResult
  func removeTimeZone(id: UUID) -> Bool {
    guard let index = savedTimeZones.firstIndex(where: { $0.id == id }) else {
      return false
    }

    savedTimeZones.remove(at: index)
    return saveTimeZones()
  }

  @discardableResult
  func moveTimeZone(from source: IndexSet, to destination: Int) -> Bool {
    savedTimeZones.move(fromOffsets: source, toOffset: destination)
    return saveTimeZones()
  }

  @discardableResult
  func resetTimeZone(_ timeZoneItem: TimeZoneItem) -> Bool {
    return updateDisplayName(for: timeZoneItem.id, newName: nil)
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

  private func addListeners() {
    AppPreferences.shared.objectWillChange
      .sink { [weak self] _ in
        self?.objectWillChange.send()
      }
      .store(in: &cancellables)

    NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)
      .sink { [weak self] _ in
        if let self {
          self.objectWillChange.send()
        }
      }
      .store(in: &cancellables)
  }
}

extension TimeZoneManager {
  /// The timezones in display order, adjusted so the device's own timezone doesn't appear first in the list
  var displayedTimeZones: [TimeZoneItem] {
    guard AppPreferences.shared.demoteCurrentTimezoneInList else {
      return savedTimeZones
    }

    let deviceIdentifier = timeZoneProvider.current.identifier

    guard let first = savedTimeZones.first,
          first.timeZone == deviceIdentifier,
          let nextIndex = savedTimeZones.firstIndex(where: { $0.timeZone != deviceIdentifier })
    else {
      return savedTimeZones
    }

    var reordered = savedTimeZones
    let promoted = reordered.remove(at: nextIndex)
    reordered.insert(promoted, at: 0)
    return reordered
  }

  var menuBarTimezoneItem: TimeZoneItem? {
    guard AppPreferences.shared.showNonDeviceTimezoneInMenuBar else {
      return savedTimeZones.first
    }

    let deviceIdentifier = timeZoneProvider.current.identifier

    if let firstNonDevice = savedTimeZones.first(where: { $0.timeZone != deviceIdentifier }) {
      return firstNonDevice
    } else {
      return savedTimeZones.first
    }
  }
}
