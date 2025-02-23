//
//  PreferencesView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/21/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            Tab("General", systemImage: "gear") {
                GeneralSettingsView()
            }
        }
        .scenePadding()
        .frame(maxWidth: 350, minHeight: 100)
    }
}
