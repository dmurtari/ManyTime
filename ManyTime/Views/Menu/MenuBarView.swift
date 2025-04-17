//
//  MenuBarView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/16/25.
//

import SwiftUI
import Combine

struct MenuBarView: View {
    @EnvironmentObject private var timeZoneManager: TimeZoneManager
    @EnvironmentObject private var timeManager: TimeManager

    var sizePassthrough: PassthroughSubject<CGSize, Never>

    @ViewBuilder
    var mainContent: some View {
        if let primaryZone = timeZoneManager.savedTimeZones.first {
            MenuBarTimeView(timeZoneItem: primaryZone)
        } else {
            Image(systemName: "clock")
        }
    }

    var body: some View {
        mainContent
            .overlay(
                GeometryReader { geometryProxy in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
                }
            )
            .onPreferenceChange(SizePreferenceKey.self, perform: { size in
                sizePassthrough.send(size)
            })
    }
}

#Preview {
    MenuBarView(sizePassthrough: PassthroughSubject<CGSize, Never>())
        .environmentObject(TimeManager())
        .environmentObject(TimeZoneManager())
        .frame(width: 250, height: 50)
}
