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

    var body: some View {
        TimeView(
            timeZone: timeZone.timeZoneObject,
            date: Date(),
            showDelete: true,
            onDelete: handleDelete
        )
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
        )
    )
        .environment(TimeManager())
        .environment(TimeZoneManager())
        .frame(width: 300, height: 200)
}
