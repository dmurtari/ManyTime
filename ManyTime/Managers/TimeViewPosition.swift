//
//  TimeViewPosition.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2026/06/28.
//

import SwiftUI

@Observable
class TimeViewPosition {
  var scrollPositions: [ScrollPosition] = Array(
    repeating: ScrollPosition(edge: .leading),
    count: 100
  ) // some big count, just to initialize the array
  var indexScrolledByUser: Int?
}
