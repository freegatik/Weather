//
//  LastSearchCitiesProviderTests.swift
//  WeatherTests
//
//  Created by Anton Solovev on 23.02.2023.
//

import XCTest
@testable import Weather

final class LastSearchCitiesProviderTests: XCTestCase {
    func testAddCityMovesToFrontAndRemovesDuplicate() {
        let suite = "WeatherTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let sut = LastSearchCitiesProviderImpl(userDefaults: defaults)
        sut.addCity("Berlin")
        sut.addCity("Paris")
        sut.addCity("Berlin")

        XCTAssertEqual(sut.lastSearchedCities, ["Berlin", "Paris"])
    }

    func testRemoveCity() {
        let suite = "WeatherTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let sut = LastSearchCitiesProviderImpl(userDefaults: defaults)
        sut.addCity("A")
        sut.addCity("B")
        sut.removeCity("A")

        XCTAssertEqual(sut.lastSearchedCities, ["B"])
    }
}
