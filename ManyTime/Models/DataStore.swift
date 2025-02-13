//
//  DataStore.swift
//  ManyTime
//
//  Created by Domenic Murtari on 2/12/25.
//

import Foundation

struct DataStore {
    var dataFileURL: URL {
        URL.documentsDirectory.appending(path: "TimeZones.json")
    }

    func readTimeFields() -> [TimeField] {
        do {
            let data = try Data(contentsOf: dataFileURL)
            let tasks = try JSONDecoder()
                .decode([TimeField].self, from: data)
            return tasks
        } catch {
            print("Read error: \(error.localizedDescription)")
            return []
        }
    }

    func save(fields: [TimeField]) {
        guard let data = try? JSONEncoder().encode(fields) else {
            return
        }
        do {
            try data.write(to: dataFileURL)
        } catch {
            print("Save error: \(error.localizedDescription)")
        }
    }
}

