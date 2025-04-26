import SwiftUI
import MapKit
import Combine

struct TimeZoneAddView: View {
    @EnvironmentObject private var timeZoneManager: TimeZoneManager
    @ObservedObject private var locationSearchFieldViewModel = LocationSearchFieldViewModel()
    @State private var timeZone: TimeZone = .current
    @State private var displayName: String = ""
    @State private var disableFields: Bool = false

    var body: some View {
        Form {
            LocationSearchField(viewModel: locationSearchFieldViewModel)
            TimeZonePicker(selectedTimeZone: $timeZone)
                .disabled(disableFields)
            TextField("Display Name", text: $displayName)
                .disabled(disableFields)

            HStack {
                Spacer()

                Button("Add") {
                    save()
                }
                .disabled(disableFields)
            }
        }
        .onReceive(locationSearchFieldViewModel.$selectedResult) { result in
            guard let result else { return }
            print("Setting location in Add View: \(result.timeZone)")
            timeZone = TimeZone(identifier: result.timeZone) ?? .current

            if (result.displayName != nil) {
                displayName = result.displayName!
            }
        }
        .onReceive(locationSearchFieldViewModel.$isSearching) { isSearching in
            disableFields = isSearching
        }
    }

    private func save() {
        let targetDisplayName = displayName.isEmpty ? timeZone.description : displayName

        timeZoneManager.addTimeZone(
            timeZone,
            displayName: targetDisplayName
        )

        displayName = ""
        timeZone = .current
    }
}

#Preview {
    TimeZoneAddView()
        .environment(TimeZoneManager())
}
