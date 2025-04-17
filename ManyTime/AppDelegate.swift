import Cocoa
import Combine
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!

    private var hostingView: NSHostingView<AnyView>?
    private var sizePassthrough = PassthroughSubject<CGSize, Never>()
    private var sizeCancellable: AnyCancellable?

    private var timeZoneManager = TimeZoneManager()
    private var timeManager = TimeManager()
    private var settingsWindow: NSWindow?
    private var menu: NSMenu?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        configureStatusItemButton()
        setupSizeObserver()
        setupMenu()
    }

    private func configureStatusItemButton() {
        guard let button = statusItem.button else { return }

        hostingView = NSHostingView(
            rootView: AnyView(MenuBarView(sizePassthrough: sizePassthrough)
                .environmentObject(timeManager)
                .environmentObject(timeZoneManager))
        )

        if let hostingView = hostingView {
            hostingView.frame = NSRect(x: 0, y: 0, width: 60, height: 22)
            button.subviews.forEach { $0.removeFromSuperview() }
            button.frame = hostingView.frame
            button.addSubview(hostingView)
        }

        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        button.action = #selector(handleStatusItemClick)
    }

    private func setupSizeObserver() {
        sizeCancellable = sizePassthrough.sink { [weak self] size in
            guard let self = self else { return }
            let frame = NSRect(origin: .zero, size: .init(width: size.width, height: 24))
            self.hostingView?.frame = frame
            self.statusItem?.button?.frame = frame
        }
    }

    private func setupMenu() {
        menu = NSMenu()
        guard let menu = menu else { return }

        menu.addItem(NSMenuItem(
            title: "Settings...",
            action: #selector(openSettings),
            keyEquivalent: ","
        ))

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(
            title: "Quit",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))
    }

    private func setupPopover() {
        popover = NSPopover()

        let contentView = TimeZoneMenu()
            .environment(timeManager)
            .environmentObject(timeZoneManager)

        popover.contentViewController = NSHostingController(rootView: contentView)
        popover.behavior = .transient
    }

    @objc func handleStatusItemClick(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!

        if event.type == .rightMouseUp {
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            statusItem.menu?.popUp(
                positioning: nil,
                at: NSPoint(x: 0, y: 0),
                in: sender
            )
            statusItem.menu = nil
        } else if event.type == .leftMouseUp {
            togglePopover()
        }
    }

    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(
                    relativeTo: button.bounds,
                    of: button,
                    preferredEdge: .minY
                )
            }
        }
    }

    @objc func openSettings() {
        if let window = settingsWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView()
            .environment(timeManager)
            .environmentObject(timeZoneManager)

        let settingsController = NSHostingController(rootView: settingsView)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.contentViewController = settingsController
        window.center()
        window.title = "Settings"

        window.isReleasedWhenClosed = false
        window.delegate = self

        self.settingsWindow = window

        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if notification.object as? NSWindow == settingsWindow {
            settingsWindow = nil
        }
    }
}

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}
