//
//  WeatherUITests.swift
//  WeatherUITests
//
//  Created by Anton Solovev on 07.05.2026.
//

import XCTest

final class WeatherUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchAndSearchShowsStubbedCityRow() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-UITesting")
        app.launch()

        let searchField = app.searchFields["Добавить новый город"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
        searchField.tap()
        searchField.typeText("Oslo\n")

        let tables = app.tables
        XCTAssertTrue(tables.firstMatch.waitForExistence(timeout: 2))

        let cell = tables.cells.element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        XCTAssertTrue(cell.staticTexts["Oslo"].exists)
    }

    func testAppLaunchesToWeatherTitle() throws {
        let app = XCUIApplication()
        app.launchArguments.append("-UITesting")
        app.launch()
        XCTAssertTrue(app.navigationBars["Погода"].waitForExistence(timeout: 5))
    }
}
