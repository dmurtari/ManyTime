//
//  LocationSearchService.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2025/04/23.
//

import MapKit
import Combine

@MainActor class LocationSearchService: NSObject, ObservableObject {
    @Published var searchQuery = ""
    @Published var searchResults: [MKLocalSearchCompletion] = []
    private var searchCompleter = MKLocalSearchCompleter()
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = [.address, .pointOfInterest]

        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] query in
                if !query.isEmpty {
                    self?.searchCompleter.queryFragment = query
                } else {
                    self?.searchResults = []
                }
            }
            .store(in: &cancellables)
    }

    func getDetails(
        for completion: MKLocalSearchCompletion,
        completion handler: @MainActor @escaping (MKMapItem?) -> Void
    ) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)

        search.start { (response, error) in
            print("Got search response: \(String(describing: response))")
            let firstItem = response?.mapItems.first
            Task { @MainActor in
                handler(firstItem)
            }
        }
    }
}

@MainActor extension LocationSearchService: @MainActor MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }

    func completer(
        _ completer: MKLocalSearchCompleter,
        didFailWithError error: Error
    ) {
        print("Search error: \(error)")
    }
}

