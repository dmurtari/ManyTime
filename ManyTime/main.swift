//
//  main.swift.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/04/17.
//

import Cocoa

// Create and start the application
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
