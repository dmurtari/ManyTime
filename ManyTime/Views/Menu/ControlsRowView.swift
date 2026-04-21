//
//  ControlsRowView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/10/13.
//

import SwiftUI

struct ControlsRowView: View {
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var timeManager: TimeManager

    var body: some View {
        HStack(alignment: .center) {
            if case .fixed = timeManager.timeMode {
                Button("Reset to Current", systemImage: "arrow.uturn.backward.circle") {
                    timeManager.switchToCurrent()
                }
            }

            Spacer()

            Menu {
                Button("Preferences", systemImage: "gear.circle.fill") {
                    NSApp.activate(ignoringOtherApps: true)
                    openWindow(id: "settings")
                }
                .keyboardShortcut(",", modifiers: .command)

                Divider()

                Button("Quit", systemImage: "power") {
                    NSApp.terminate(nil)
                }
                .keyboardShortcut("Q", modifiers: .command)
            } label: {
                Label("Options", systemImage: "ellipsis.circle")
                    .labelStyle(.titleOnly)
            }
            .menuStyle(.automatic)
            .buttonStyle(.glass)
            .labelsHidden()
        }
    }
}

#Preview {
    ControlsRowView()
        .environmentObject(TimeManager())
}
