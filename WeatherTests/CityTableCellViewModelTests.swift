//
//  CityTableCellViewModelTests.swift
//  WeatherTests
//
//  Created by Anton Solovev on 07.05.2026.
//

import XCTest
@testable import Weather

final class CityTableCellViewModelTests: XCTestCase {
    func testMapsTemperatureRoundingAndIconURL() throws {
        let json = """
        {"location":{"name":"T","localtime":"12"},"current":{"temp_c":12.7,"condition":{"text":"Rain","icon":"//cdn.example.com/i.png"}}}
        """
        let model = try JSONDecoder().decode(CityModel.self, from: Data(json.utf8))
        let vm = CityTableCellViewModel(cityModel: model)
        XCTAssertEqual(vm.temperature, "12°C")
        XCTAssertEqual(vm.conditionIconURL, "https://cdn.example.com/i.png")
        XCTAssertEqual(vm.conditionText, "Rain")
    }

    func testNegativeTemperatureUsesIntTruncationTowardZero() throws {
        let json = """
        {"location":{"name":"X","localtime":"1"},"current":{"temp_c":-3.9,"condition":{"text":"Snow","icon":"//a"}}}
        """
        let model = try JSONDecoder().decode(CityModel.self, from: Data(json.utf8))
        let vm = CityTableCellViewModel(cityModel: model)
        XCTAssertEqual(vm.temperature, "-3°C")
    }

    func testExplicitInitPassesThroughFields() {
        let vm = CityTableCellViewModel(
            name: "Z",
            localTime: "3",
            temperature: "1°C",
            conditionText: "Fog",
            conditionIconURL: nil
        )
        XCTAssertEqual(vm.name, "Z")
        XCTAssertNil(vm.conditionIconURL)
    }
}
