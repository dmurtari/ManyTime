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

            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )

            settingsWindow?.center()
            settingsWindow?.title = "Settings"
            settingsWindow?.contentViewController = hostingController
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
