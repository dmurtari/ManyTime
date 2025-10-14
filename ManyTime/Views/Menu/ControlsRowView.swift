//
//  ControlsRowView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/10/13.
//

import SwiftUI

struct ControlsRowView: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        HStack(alignment: .center) {
            Spacer()

            Button(
                "Quit",
            ) {
                NSApp.terminate(nil)
            }
            .buttonStyle(.accessoryBar)

            Button(
                "Preferences",
                systemImage: "gear.circle.fill"
            ) {
                NSApp.activate(ignoringOtherApps: true)
                openWindow(id: "settings")
            }
            .buttonStyle(.glass)
        }
    }
}

#Preview {
    ControlsRowView()
}
