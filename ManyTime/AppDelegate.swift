//
//  AppDelegate.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/5/25.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover!
    var menuManager: MenuManager?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let contentView = ContentView()
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover

        self.statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )

        if let button = statusItem?.button {
            button.title = "Many Time"
            button.imagePosition = .imageLeading
            button.image = NSImage(
                systemSymbolName: "globe",
                accessibilityDescription: "Many Time"
            )

            button.font = NSFont.menuBarFont(
                ofSize: NSFont.systemFontSize
            )

            button.target = self
            button.action = #selector(handleMenuButtonClick(sender:))
            button.sendAction(on: [.leftMouseDown, .rightMouseDown])
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    @objc func handleMenuButtonClick(sender: NSStatusItem) {
        let event = NSApp.currentEvent!

        if event.type == .rightMouseDown {
            showRightClickMenu()
        } else {
            togglePopover(sender)
        }
    }

    func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusItem?.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                self.popover.contentViewController?.view.window?.becomeKey()
            }
        }
    }

    func showRightClickMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        if let statusItem {
            // Set the menu to the status item and trigger a click event
            statusItem.menu = menu
            statusItem.button?.performClick(nil)

            // Clear the menu to ensure it doesn't stay attached
            statusItem.menu = nil
        }

    }
}

