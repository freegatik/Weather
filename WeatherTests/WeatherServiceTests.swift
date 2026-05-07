//
//  WeatherServiceTests.swift
//  WeatherTests
//
//  Created by Anton Solovev on 07.05.2026.
//

import XCTest
@testable import Weather

final class WeatherServiceTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        WeatherURLProtocolStub.handler = nil
        URLProtocol.unregisterClass(WeatherURLProtocolStub.self)
    }

    private func makeSUT() -> WeatherServiceImpl {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [WeatherURLProtocolStub.self]
        let session = URLSession(configuration: config)
        return WeatherServiceImpl(session: session)
    }

    func testSuccessMapsToCityModel() {
        URLProtocol.registerClass(WeatherURLProtocolStub.self)
        // swiftlint:disable:next line_length
        let json = "{\"location\":{\"name\":\"London\",\"localtime\":\"2023-02-24 09:30\"},\"current\":{\"temp_c\":8,\"condition\":{\"text\":\"Sunny\",\"icon\":\"//cdn.weatherapi.com/icon.png\"}}}"
        WeatherURLProtocolStub.handler = { request in
            XCTAssertTrue(request.url?.absoluteString.contains("q=London") == true)
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data(json.utf8))
        }

        let sut = makeSUT()
        let exp = expectation(description: "completion")
        sut.getCurrentWeather(city: "London") { result in
            defer { exp.fulfill() }
            guard case .success(let model) = result else {
                return XCTFail("expected success")
            }
            XCTAssertEqual(model.location.name, "London")
            XCTAssertEqual(model.current.temp_c, 8)
        }
        wait(for: [exp], timeout: 2)
    }

    func testEncodesSpaceInCityQuery() {
        URLProtocol.registerClass(WeatherURLProtocolStub.self)
        WeatherURLProtocolStub.handler = { request in
            XCTAssertTrue(request.url?.absoluteString.contains("q=New%20York") == true)
            let json = #"{"location":{"name":"NY","localtime":"1"},"current":{"temp_c":0,"condition":{"text":"x","icon":"//i"}}}"#
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data(json.utf8))
        }
        let sut = makeSUT()
        let exp = expectation(description: "completion")
        sut.getCurrentWeather(city: "New York") { _ in exp.fulfill() }
        wait(for: [exp], timeout: 2)
    }

    func testCityNotFoundReturnsError() {
        URLProtocol.registerClass(WeatherURLProtocolStub.self)
        let json = #"{"error":{"code":1006,"message":"No matching location found."}}"#
        WeatherURLProtocolStub.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data(json.utf8))
        }

        let sut = makeSUT()
        let exp = expectation(description: "completion")
        sut.getCurrentWeather(city: "Nowhere") { result in
            defer { exp.fulfill() }
            guard case .failure(let error) = result else {
                return XCTFail("expected failure")
            }
            XCTAssertEqual(error, .cityNotFound)
        }
        wait(for: [exp], timeout: 2)
    }

    func testNonMatchingApiErrorCodeMapsToDecodingError() {
        URLProtocol.registerClass(WeatherURLProtocolStub.self)
        let json = #"{"error":{"code":2006,"message":"other"}}"#
        WeatherURLProtocolStub.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data(json.utf8))
        }
        let sut = makeSUT()
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

    func testTransportErrorMapsToNetworkError() {
        URLProtocol.registerClass(WeatherURLProtocolStub.self)
        WeatherURLProtocolStub.handler = { _ in
            throw URLError(.notConnectedToInternet)
        }
        let sut = makeSUT()
        let exp = expectation(description: "completion")
        sut.getCurrentWeather(city: "Z") { result in
            defer { exp.fulfill() }
            guard case .failure(let error) = result else {
                return XCTFail("expected failure")
            }
            XCTAssertEqual(error, .networkError)
        }
        wait(for: [exp], timeout: 2)
    }

    func testEmptyJsonObjectMapsToDecodingError() {
        URLProtocol.registerClass(WeatherURLProtocolStub.self)
        WeatherURLProtocolStub.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data("{}".utf8))
        }
        let sut = makeSUT()
        let exp = expectation(description: "completion")
        sut.getCurrentWeather(city: "Y") { result in
            defer { exp.fulfill() }
            guard case .failure(let error) = result else {
                return XCTFail("expected failure")
            }
            XCTAssertEqual(error, .decodingError)
        }
        wait(for: [exp], timeout: 2)
    }

    func testURLProtocolWithoutHandlerMapsToNetworkError() {
        URLProtocol.registerClass(WeatherURLProtocolStub.self)
        WeatherURLProtocolStub.handler = nil
        let sut = makeSUT()
        let exp = expectation(description: "completion")
        sut.getCurrentWeather(city: "Nohandler") { result in
            defer { exp.fulfill() }
            guard case .failure(let error) = result else {
                return XCTFail("expected failure")
            }
            XCTAssertEqual(error, .networkError)
        }
        wait(for: [exp], timeout: 2)
    }

    func testMalformedJsonMapsToDecodingError() {
        URLProtocol.registerClass(WeatherURLProtocolStub.self)
        WeatherURLProtocolStub.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data("{".utf8))
        }
        let sut = makeSUT()
        let exp = expectation(description: "completion")
        sut.getCurrentWeather(city: "Q") { result in
            defer { exp.fulfill() }
            guard case .failure(let error) = result else {
                return XCTFail("expected failure")
            }
            XCTAssertEqual(error, .decodingError)
        }
        wait(for: [exp], timeout: 2)
    }
}
