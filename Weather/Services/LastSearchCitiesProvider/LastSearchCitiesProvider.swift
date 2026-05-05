//
//  LastSearchCitiesProvider.swift
//  Weather
//
//  Created by Anton Solovev on 07.05.2026.
//

import Foundation

protocol LastSearchCitiesProvider {
    var lastSearchedCities: [String] { get }
    func addCity(_ city: String)
    func removeCity(_ city: String)
}

final class LastSearchCitiesProviderImpl: LastSearchCitiesProvider {
    private let userDefaults: UserDefaults
    private let key = "lastSearchedCities"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var lastSearchedCities: [String] {
        userDefaults.stringArray(forKey: key) ?? []
    }

    func addCity(_ city: String) {
        var cities = lastSearchedCities

        if let index = cities.firstIndex(of: city) {
            cities.remove(at: index)
        }

        cities.insert(city, at: 0)
        userDefaults.set(cities, forKey: key)
    }

    func removeCity(_ city: String) {
        var cities = lastSearchedCities

        if let index = cities.firstIndex(of: city) {
            cities.remove(at: index)
            userDefaults.set(cities, forKey: key)
        }
    }
}
