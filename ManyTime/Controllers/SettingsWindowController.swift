//
//  SettingsWindowController.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/9/25.
//

import SwiftUI

class SettingsWindowController {
    private var settingsWindow: NSWindow?

    func showSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)

            settingsWindow = NSWindow(contentViewController: hostingController)
            settingsWindow?.title = "Settings"
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
