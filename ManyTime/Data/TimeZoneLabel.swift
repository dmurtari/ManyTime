//
//  TimeZoneLabel.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2026/11/07.
//

import Foundation

extension TimeZone {
  static func gmtLabel(minutes: Int) -> String {
    let sign = minutes >= 0 ? "+" : "-"
    let h = abs(minutes) / 60
    let m = abs(minutes) % 60
    return m == 0 ? "GMT\(sign)\(h)" : "GMT\(sign)\(h):" + String(format: "%02d", m)
  }

  var gmtLabel: String {
    Self.gmtLabel(minutes: secondsFromGMT() / 60)
  }
}
