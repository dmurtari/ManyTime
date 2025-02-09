//
//  SettingsView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/9/25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            Tab("Locations", systemImage: "globe") {
                Text("Adjust locations here")
             }
         }
        .frame(width: 400, height: 400)
    }
}

#Preview {
    SettingsView()
}
