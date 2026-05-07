//
//  UITestingSupportTests.swift
//  WeatherTests
//
//  Created by Anton Solovev on 07.05.2026.
//

import XCTest
@testable import Weather

final class UITestingSupportTests: XCTestCase {
    func testStubSanitizesQuotesInCityName() {
        let sut = UITestingStubWeatherService()
        let exp = expectation(description: "completion")
        sut.getCurrentWeather(city: "O\"slo") { result in
            defer { exp.fulfill() }
            guard case .success(let model) = result else {
                return XCTFail("expected success")
            }
            XCTAssertEqual(model.location.name, "Oslo")
        }
        wait(for: [exp], timeout: 2)
    }

    func testStubForcedDecodeFailureReturnsDecodingError() {
        let sut = UITestingStubWeatherService(forceDecodeFailure: true)
        let exp = expectation(description: "completion")
        sut.getCurrentWeather(city: "X") { result in
            defer { exp.fulfill() }
            guard case .failure(let error) = result else {
                return XCTFail("expected failure")
            }
            XCTAssertEqual(error, .decodingError)
        }
        wait(for: [exp], timeout: 2)
    }
}
