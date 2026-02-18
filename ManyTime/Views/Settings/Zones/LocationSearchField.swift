//
//  LocationSearchField.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/04/23.
//

import MapKit
import SwiftUI
import Combine

struct LocationSearchField: NSViewRepresentable {
    @ObservedObject var viewModel: LocationSearchFieldViewModel

    func makeNSView(context: Context) -> NSSearchField {
        let searchField = NSSearchField(
            frame: .zero,
        )
        searchField.delegate = context.coordinator

        let resultsMenu = NSMenu()
        searchField.searchMenuTemplate = resultsMenu

        context.coordinator.setupSearchResultsSubscription(
            searchField: searchField,
            resultsPublisher: viewModel.$searchResults
        )

        return searchField
    }

    func updateNSView(_ searchField: NSSearchField, context: Context) {
        if searchField.stringValue != viewModel.searchQuery {
            searchField.stringValue = viewModel.searchQuery
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    @MainActor class Coordinator: NSObject, NSSearchFieldDelegate {
        var parent: LocationSearchField
        private var cancellables = Set<AnyCancellable>()

        init(_ parent: LocationSearchField) {
            self.parent = parent
        }

        func setupSearchResultsSubscription(
            searchField: NSSearchField,
            resultsPublisher: Published<[MKLocalSearchCompletion]>.Publisher
        ) {
            resultsPublisher
                .receive(on: RunLoop.main)
                .sink { [weak searchField] searchResults in
                    guard let searchField = searchField,
                          let searchMenu = searchField.searchMenuTemplate else { return }

                    if (searchField.stringValue.isEmpty) {
                        return
                    }

                    searchMenu.removeAllItems()

                    if searchResults.isEmpty {
                        let emptyMenuItem = NSMenuItem(
                            title: "No results",
                            action: nil,
                            keyEquivalent: ""
                        )
                        searchMenu.addItem(emptyMenuItem)
                    } else {
                        let maxCount = min(searchResults.count, 5)
                        for result in searchResults.prefix(maxCount) {
                            let menuItem = NSMenuItem(
                                title: "\(result.title) (\(result.subtitle))",
                                action: #selector(self.menuItemSelected(_:)),
                                keyEquivalent: ""
                            )

                            menuItem.representedObject = result
                            menuItem.target = self
                            searchMenu.addItem(menuItem)
                        }
                    }

                    searchMenu.popUp(
                        positioning: searchMenu.item(at: 0),
                        at: NSPoint(x: 0, y: 28),
                        in: searchField
                    )

                    searchField.window?.makeFirstResponder(searchField.currentEditor())
                }
                .store(in: &cancellables)
        }

        @objc func menuItemSelected(_ sender: NSMenuItem) {
            guard let result = sender.representedObject as? MKLocalSearchCompletion else { return }
            parent.viewModel.selectResult(result)
        }

        func controlTextDidChange(_ notification: Notification) {
            guard let searchField = notification.object as? NSSearchField else { return }
            let query = searchField.stringValue

            parent.viewModel.updateQuery(query)
        }
    }
}

@MainActor class LocationSearchFieldViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var selectedResult: TimeZoneItem?
    @Published var isSearching: Bool = false

    private var locationSearchService: LocationSearchService!
    private var cancellables: Set<AnyCancellable> = []

    init() {
        locationSearchService = LocationSearchService()
        locationSearchService.$searchResults
            .receive(on: RunLoop.main)
            .sink { [weak self] results in
                self?.searchResults = results
            }
            .store(in: &cancellables)
    }

    func updateQuery(_ query: String) {
        searchQuery = query
        locationSearchService.searchQuery = query

        if (query.isEmpty) {
            searchResults = []
            return;
        }
    }

    func selectResult(_ result: MKLocalSearchCompletion) -> Void {
        isSearching = true
        
        locationSearchService.getDetails(for: result) { [weak self] item in
            self?.isSearching = false
            guard let timeZone = item?.timeZone else { return }

            print("Setting selected result: \(String(describing: item))")
            self?.searchQuery = result.title
            if let self = self {
                self.selectedResult = TimeZoneItem(
                    timeZone: timeZone,
                    displayName: result.title
                )
            }
        }
    }
}

#Preview {
    LocationSearchField(viewModel: LocationSearchFieldViewModel())
}
