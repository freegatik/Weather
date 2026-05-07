//
//  LastSearchCitiesProviderTests.swift
//  WeatherTests
//
//  Created by Anton Solovev on 07.05.2026.
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

    func testInitialHistoryEmptyWhenUnset() {
        let suite = "WeatherTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let sut = LastSearchCitiesProviderImpl(userDefaults: defaults)
        XCTAssertTrue(sut.lastSearchedCities.isEmpty)
    }

    func testRemoveMissingCityLeavesListUnchanged() {
        let suite = "WeatherTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let sut = LastSearchCitiesProviderImpl(userDefaults: defaults)
        sut.addCity("Only")
        sut.removeCity("Missing")
        XCTAssertEqual(sut.lastSearchedCities, ["Only"])
    }

    func testPreservesRelativeOrderExceptPromotedDuplicate() {
        let suite = "WeatherTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        let sut = LastSearchCitiesProviderImpl(userDefaults: defaults)
        sut.addCity("A")
        sut.addCity("B")
        sut.addCity("C")
        XCTAssertEqual(sut.lastSearchedCities, ["C", "B", "A"])
        sut.addCity("B")
        XCTAssertEqual(sut.lastSearchedCities, ["B", "C", "A"])
    }
}
