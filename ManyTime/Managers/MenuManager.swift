//
//  MenuManager.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/5/25.
//

import AppKit

class MenuManager: NSObject, NSMenuDelegate {
    let statusMenu: NSMenu

    let timeManager = TimeManager()

    init(statusMenu: NSMenu) {
        self.statusMenu = statusMenu
    }
}
