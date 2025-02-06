//
//  ContentView.swift
//  SharedMoment
//
//  Created by Domenic Murtari on 1/30/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            TimeRowView(timeZone: TimeZone.current)
            TimeRowView(timeZone: TimeZone(identifier: "Asia/Tokyo")!)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
