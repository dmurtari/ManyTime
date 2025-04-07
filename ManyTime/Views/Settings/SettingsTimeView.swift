//
//  SettingsTimeView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/23/25.
//

import SwiftUI

struct SettingsTimeView: View {
    @State var timeZone: TimeZone
    
    var body: some View {
        TimeView(timeZone: timeZone, date: Date())
            .padding()
            .background(
                VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
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
    SettingsTimeView(timeZone: TimeZone.current)
        .environment(TimeManager())
        .frame(width: 300, height: 200)
}
