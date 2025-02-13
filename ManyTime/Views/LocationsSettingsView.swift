//
//  LocationsSettingsView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/12/25.
//

import SwiftUI

struct TmpTimeField: Identifiable {
    var id = UUID()
    var name: String = ""
    var timeZone: TimeZone?
}

struct LocationsSettingsView: View {
    @State private var dataStore = DataStore()
    @State private var timeFields: [TimeField] = []

    var body: some View {
        VStack {
            ForEach($timeFields) { $timeField in
                HStack {
                    Picker(selection: $timeField) {
                        Text("America/Denver").tag("America/Denver")
                    } label: {
                        Text("Time Zone")
                    }
                }
            }
        }

        Button(action: addTimeField) {
            Text("Add Time")
        }
    }

    func getExistingTimeFields() {
        timeFields = dataStore.readTimeFields()
    }

    func addTimeField() {
        timeFields.append(
            TimeField(
                id: UUID(),
                name: "New Timezone",
                timeZone: TimeZone.current
            )
        )
    }
}

#Preview {
    LocationsSettingsView()
        .frame(width: 200, height: 200)
}
