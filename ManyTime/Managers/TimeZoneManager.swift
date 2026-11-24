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
  var isDeviceTimeZone: Bool?

  init(timeZone: TimeZone, displayName: String?) {
    self.id = UUID()
    self.timeZone = timeZone.identifier
    self.displayName = displayName
    self.isDeviceTimeZone = nil
  }

  init(id: UUID = UUID(), timeZoneIdentifier: String, displayName: String? = nil, isDeviceTimeZone: Bool? = nil) {
    self.id = id
    self.timeZone = timeZoneIdentifier
    self.displayName = displayName
    self.isDeviceTimeZone = isDeviceTimeZone
  }

  var timeZoneObject: TimeZone {
    TimeZone(identifier: timeZone) ?? TimeZone.current
  }

  var normalizedDisplayName: String {
    if let displayName, !displayName.isEmpty {
      return displayName
    }
    return (timeZone.isEmpty ? timeZoneObject.identifier : timeZone)
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
    if AppPreferences.shared.showDeviceTimeZone {
      ensureDeviceTimeZone()
    }
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
    if offsets.contains(where: { savedTimeZones.indices.contains($0) && savedTimeZones[$0].isDeviceTimeZone == true }) {
      AppPreferences.shared.showDeviceTimeZone = false
    }
    savedTimeZones.remove(atOffsets: offsets)
    return saveTimeZones()
  }

  @discardableResult
  func removeTimeZone(id: UUID) -> Bool {
    guard let index = savedTimeZones.firstIndex(where: { $0.id == id }) else {
      return false
    }

    if savedTimeZones[index].isDeviceTimeZone == true {
      AppPreferences.shared.showDeviceTimeZone = false
    }
    savedTimeZones.remove(at: index)
    return saveTimeZones()
  }

  @discardableResult
  func moveTimeZone(from source: IndexSet, to destination: Int) -> Bool {
    savedTimeZones.move(fromOffsets: source, toOffset: destination)
    return saveTimeZones()
  }

  func setDeviceTimeZoneVisible(_ visible: Bool) {
    if visible {
      ensureDeviceTimeZone()
    }
    AppPreferences.shared.showDeviceTimeZone = visible
  }

  private func ensureDeviceTimeZone() {
    guard !savedTimeZones.contains(where: { $0.isDeviceTimeZone == true }) else { return }
    savedTimeZones.insert(
      TimeZoneItem(timeZoneIdentifier: timeZoneProvider.current.identifier, displayName: "Current", isDeviceTimeZone: true),
      at: 0
    )
    saveTimeZones()
  }

  func moveDisplayedTimeZones(from source: IndexSet, to destination: Int) {
    var visibleIDs = displayedTimeZones.map(\.id)
    visibleIDs.move(fromOffsets: source, toOffset: destination)
    let itemsByID = Dictionary(uniqueKeysWithValues: savedTimeZones.map { ($0.id, $0) })
    var visibleItems = visibleIDs.compactMap { itemsByID[$0] }.makeIterator()
    savedTimeZones = savedTimeZones.map { item in
      if item.isDeviceTimeZone == true && !AppPreferences.shared.showDeviceTimeZone { return item }
      return visibleItems.next() ?? item
    }
    saveTimeZones()
  }

  func removeDisplayedTimeZones(at offsets: IndexSet) {
    let items = displayedTimeZones
    for offset in offsets {
      removeTimeZone(id: items[offset].id)
    }
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
  var displayedTimeZones: [TimeZoneItem] {
    savedTimeZones.compactMap { item in
      guard item.isDeviceTimeZone == true else { return item }
      guard AppPreferences.shared.showDeviceTimeZone else { return nil }
      return TimeZoneItem(
        id: item.id,
        timeZoneIdentifier: timeZoneProvider.current.identifier,
        displayName: item.displayName ?? "Current",
        isDeviceTimeZone: true
      )
    }
  }

  var menuBarTimezoneItem: TimeZoneItem? {
    guard AppPreferences.shared.showNonDeviceTimezoneInMenuBar else {
      return displayedTimeZones.first
    }

    let deviceIdentifier = timeZoneProvider.current.identifier
    return displayedTimeZones.first(where: { $0.timeZone != deviceIdentifier }) ?? displayedTimeZones.first
  }
}
