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
      ScrollView {
        VStack(spacing: 16) {
          GeneralSettingsView()
          MenuBarSettingsView()
        }
      }
      .frame(width: 400)
      .padding([.all], 18)
      .tabItem {
        Label("General", systemImage: "gearshape")
      }

      ZonesSettingsView()
        .padding([.all], 18)
        .tabItem {
          Label("Time Zones", systemImage: "globe")
        }
    }
    .fixedSize(horizontal: true, vertical: true)
  }
}


#Preview {
  SettingsView()
    .environmentObject(TimeZoneManager())
    .environment(TimeManager())
}
