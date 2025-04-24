import SwiftUI
import MapKit

struct TimeZoneAddView: View {
    @EnvironmentObject private var timeZoneManager: TimeZoneManager
    @ObservedObject private var locationSearchFieldViewModel = LocationSearchFieldViewModel()
    @State private var timeZone: TimeZone = .current
    @State private var displayName: String = ""

    var body: some View {
        
        Form {
            TimeZonePicker(selectedTimeZone: $timeZone)

            LocationSearchField(viewModel: locationSearchFieldViewModel)

            TextField("Display Name", text: $displayName)

            HStack {
                Spacer()

                Button("Add") {
                    save()
                }
            }
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
