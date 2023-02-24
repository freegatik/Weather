//
//  CityModelTests.swift
//  WeatherTests
//
//  Created by Anton Solovev on 22.02.2023.
//

import XCTest
@testable import Weather

final class CityModelTests: XCTestCase {
    func testDecodeCurrentWeatherJSON() throws {
        let json = """
        {"location":{"name":"Moscow","localtime":"2023-02-22 12:00"},"current":{"temp_c":-5.5,"condition":{"text":"Cloudy","icon":"//cdn.weatherapi.com/wx/64x64/day/119.png"}}}
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let model = try JSONDecoder().decode(CityModel.self, from: data)
        XCTAssertEqual(model.location.name, "Moscow")
        XCTAssertEqual(model.location.localtime, "2023-02-22 12:00")
        XCTAssertEqual(model.current.temp_c, -5.5)
        XCTAssertEqual(model.current.condition.text, "Cloudy")
        XCTAssertTrue(model.current.condition.icon.contains("119"))
    }
}
