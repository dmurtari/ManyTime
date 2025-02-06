//
//  AppDelegate.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/5/25.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    @IBOutlet weak var statusMenu: NSMenu!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        statusItem?.menu = statusMenu

        statusItem?.button?.title = "MenuTime"
        statusItem?.button?.imagePosition = .imageLeading
        statusItem?.button?.image = NSImage(
            systemSymbolName: "globe",
            accessibilityDescription: "Many Time"
        )

        statusItem?.button?.font = NSFont.menuBarFont(
            ofSize: NSFont.systemFontSize
        )
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

