//
//  SettingsTimeView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/23/25.
//

import SwiftUI

struct SettingsTimeView: View {
    @EnvironmentObject var timeZoneManager: TimeZoneManager

    @State var timeZone: TimeZoneItem
    @State private var isHovering = false

    var showDelete: Bool = false

    var body: some View {
        TimeView(
            timeZone: timeZone.timeZoneObject,
            date: Date(),
        )
        .padding(8)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.25), lineWidth: 2)
        )
        .overlay(alignment: .topTrailing) {
            if showDelete {
                Button(action: {
                    handleDelete()
                }) {
                    Image(systemName: "trash")
                }
                .opacity(isHovering ? 1 : 0)
                .padding([.top, .trailing], 5)
            }
        }
        .onHover { hovering in
            isHovering = hovering
        }
        .animation(.easeInOut(duration: 0.2), value: isHovering)
    }

    func handleDelete() {
        timeZoneManager.removeTimeZone(id: timeZone.id)
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

#Preview {
    SettingsTimeView(
        timeZone: TimeZoneItem(
            timeZone: TimeZone.current,
            displayName: TimeZone.current.description
        ),
        showDelete: true
    )
        .environment(TimeManager())
        .environment(TimeZoneManager())
        .frame(width: 300, height: 200)
}
