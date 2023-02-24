//
//  WeatherServiceTests.swift
//  WeatherTests
//
//  Created by Anton Solovev on 24.02.2023.
//

import XCTest
@testable import Weather

private final class StubWeatherURLProtocol: URLProtocol {
    static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

final class WeatherServiceTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        StubWeatherURLProtocol.handler = nil
        URLProtocol.unregisterClass(StubWeatherURLProtocol.self)
    }

    func testSuccessMapsToCityModel() {
        URLProtocol.registerClass(StubWeatherURLProtocol.self)
        let json = """
        {"location":{"name":"London","localtime":"2023-02-24 09:30"},"current":{"temp_c":8,"condition":{"text":"Sunny","icon":"//cdn.weatherapi.com/icon.png"}}}
        """
        StubWeatherURLProtocol.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data(json.utf8))
        }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubWeatherURLProtocol.self]
        let session = URLSession(configuration: config)
        let sut = WeatherServiceImpl(session: session)

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

    func testCityNotFoundReturnsError() {
        URLProtocol.registerClass(StubWeatherURLProtocol.self)
        let json = #"{"error":{"code":1006,"message":"No matching location found."}}"#
        StubWeatherURLProtocol.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data(json.utf8))
        }

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubWeatherURLProtocol.self]
        let session = URLSession(configuration: config)
        let sut = WeatherServiceImpl(session: session)

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
}
