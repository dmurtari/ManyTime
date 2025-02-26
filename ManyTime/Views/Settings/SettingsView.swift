//
//  PreferencesView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/21/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var selectedTab = 0
    @State private var generalHeight: CGFloat = 0
    @State private var zonesHeight: CGFloat = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView()
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                generalHeight = geometry.size.height
                            }
                            .onChange(of: geometry.size.height) { oldHeight, newHeight in
                                generalHeight = newHeight
                            }
                    }
                )
                .tag(0)
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            ZonesSettingsView(timeZoneManager: TimeZoneManager())
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                zonesHeight = geometry.size.height
                            }
                            .onChange(of: geometry.size.height) { oldHeight, newHeight in
                                zonesHeight = newHeight
                            }
                    }
                )
                .tag(1)
                .tabItem {
                    Label("Time Zones", systemImage: "clock")
                }
        }
        .scenePadding()
        .frame(minWidth: 350, idealHeight: currentHeight + 40)
        .fixedSize(horizontal: false, vertical: true)
    }

    var currentHeight: CGFloat {
        selectedTab == 0 ? generalHeight : zonesHeight
    }
}
