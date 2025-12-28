import SwiftUI
import MapKit
import Combine

struct TimeZoneAddView: View {
    @EnvironmentObject private var timeZoneManager: TimeZoneManager

    @State private var timeZoneIdentifier: String = ""
    @State private var displayName: String = ""
    @State private var disableFields: Bool = false

    var body: some View {
        Form {
//            ZStack {
//                Map()
//                    .mapControlVisibility(.hidden)
//
//                LocationSearchField(viewModel: locationSearchFieldViewModel)
//                    .shadow(radius: 5)
//                    .position(x: -90, y: 20)
//                    .frame(width: 200)
//            }

            HStack {
                TimeZonePicker(selectedTimeZone: $timeZoneIdentifier)
                    .labelsHidden()
                    .disabled(disableFields)
                TextField("Display Name", text: $displayName)
                    .textFieldStyle(.roundedBorder)
                    .labelsHidden()
                    .disabled(disableFields)
            }

            HStack {
                Spacer()

                Button("Add") {
                    save()
                }
                .disabled(disableFields)
            }
        }
        .onChange(of: timeZoneIdentifier) { _, newId in
            let timeZone = TimeZone(identifier: timeZoneIdentifier)

            guard let timeZone else {
                return
            }
            
            self.displayName = !self.displayName.isEmpty ? self.displayName : timeZone.description
        }
    }

    private func save() {
        if (timeZoneIdentifier == "") {
            return
        }

        let timeZone = TimeZone(identifier: timeZoneIdentifier)

        guard let timeZone else {
            print("Failed to create TimeZone from identifier: \(timeZoneIdentifier)")
            return
        }

        let targetDisplayName = displayName.isEmpty ? timeZone.description : displayName

        timeZoneManager.addTimeZone(
            timeZone,
            displayName: targetDisplayName
        )

        self.displayName = ""
        self.timeZoneIdentifier = ""
    }
}

#Preview {
    TimeZoneAddView()
        .environment(TimeZoneManager())
}
