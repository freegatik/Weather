//
//  LastSearchCitiesProvider.swift
//  Weather
//
//  Created by Anton Solovev on 11.02.2023.
//

import Foundation

// MARK: - LastSearchCitiesProvider

// Протокол для работы с историей поиска городов
protocol LastSearchCitiesProvider {
    var lastSearchedCities: [String] { get }
    func addCity(_ city: String)
    func removeCity(_ city: String)
}

// MARK: - LastSearchCitiesProviderImpl

// Реализация провайдера для работы с историей поиска городов
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
