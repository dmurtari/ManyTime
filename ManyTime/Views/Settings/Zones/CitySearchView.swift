//
//  CitySearchView.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2026/11/07.
//

import SwiftUI

struct CitySearchView: View {
  @Binding var selection: CityTimeZone?

  @Environment(\.dismiss) private var dismiss
  @State private var viewModel = CitySearchViewModel()

  @FocusState private var searchFocused: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      TextField("Search for a city", text: $viewModel.query)
        .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
        .focused($searchFocused)
        .padding()

      if (viewModel.filtered.isEmpty) {
        Spacer()
        VStack(spacing: 8) {
          Text("Start typing to search")
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        Spacer()
      } else {
        List(viewModel.filtered.prefix(8), id: \.id) { row in
          Button {
            selection = row.city
            dismiss()
          } label: {
            HStack {
              VStack(alignment: .leading) {
                Text(row.city.city)
                Text(row.countryDisplayName)
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }

              Spacer()

              Text(row.gmtDisplay)
                .foregroundStyle(.secondary)

              if selection?.id == row.city.id {
                Image(systemName: "checkmark")
                  .foregroundStyle(.tint)
              }
            }
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
        }
        .listStyle(.plain)
      }
    }
    .frame(minWidth: 320, minHeight: 380)
    .task {
      searchFocused = true
      await viewModel.load(cities: TimeZoneListService.shared.getCityTimeZones())
    }
    .task(id: viewModel.query) {
      await viewModel.search()
    }
  }
}

#Preview {
  CitySearchView(selection: .constant(nil))
}
