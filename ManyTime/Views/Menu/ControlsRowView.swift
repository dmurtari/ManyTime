//
//  ControlsRowView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/10/13.
//

import SwiftUI

struct ControlsRowView: View {
  @Environment(\.openWindow) private var openWindow
  @Environment(TimeManager.self) private var timeManager

  var body: some View {
    HStack(alignment: .center) {
      if !timeManager.isShowingCurrentTime {
        Button(
          "Back to Present",
          systemImage: "arrow.uturn.backward.circle"
        ) {
          timeManager.switchToCurrent()
        }
      }

      Spacer()

      Menu {
        Button("About") {
#if os(macOS)
          NSApp.activate(ignoringOtherApps: true)
          openWindow(id: "about")
#endif
        }

        Button("Preferences", systemImage: "gear.circle.fill") {
#if os(macOS)
          NSApp.activate(ignoringOtherApps: true)
          openWindow(id: "settings")
#endif
        }
        .keyboardShortcut(",", modifiers: .command)

#if os(macOS)
        Divider()

        Button("Quit", systemImage: "power") {
          NSApp.terminate(nil)
        }
        .keyboardShortcut("Q", modifiers: .command)
#endif
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
    .environment(TimeManager())
}
