//
//  CityTableCellTests.swift
//  WeatherTests
//
//  Created by Anton Solovev on 07.05.2026.
//

import XCTest
@testable import Weather

final class CityTableCellTests: XCTestCase {

    private func loadCell() throws -> CityTableCell {
        let bundle = Bundle(for: CityTableCell.self)
        let objects = try XCTUnwrap(bundle.loadNibNamed("CityTableCell", owner: nil))
        return try XCTUnwrap(objects.first as? CityTableCell)
    }

    func testConfigureSetsLabels() throws {
        let cell = try loadCell()
        let vm = CityTableCellViewModel(
            name: "Tallinn",
            localTime: "12:00",
            temperature: "5°C",
            conditionText: "Snow",
            conditionIconURL: "https://example.com/i.png"
        )
        cell.configure(with: vm)
        XCTAssertEqual(cell.nameLabel.text, "Tallinn")
        XCTAssertEqual(cell.localTimeLabel.text, "12:00")
        XCTAssertEqual(cell.temperatureLabel.text, "5°C")
        XCTAssertEqual(cell.conditionLabel.text, "Snow")
    }

    func testConfigureWithNilIconURLDoesNotCrash() throws {
        let cell = try loadCell()
        let vm = CityTableCellViewModel(
            name: "A",
            localTime: "1",
            temperature: "0°C",
            conditionText: "OK",
            conditionIconURL: nil
        )
        cell.configure(with: vm)
        XCTAssertEqual(cell.nameLabel.text, "A")
    }
}
