//
//  MenuManager.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/5/25.
//

import AppKit

class MenuManager: NSObject, NSPopoverDelegate {
    let popover: NSPopover?

    let timeManager = TimeManager()

    init(popover: NSPopover) {
        self.popover = popover
    }
}
