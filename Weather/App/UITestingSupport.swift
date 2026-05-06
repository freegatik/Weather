//
//  UITestingSupport.swift
//  Weather
//
//  Created by Anton Solovev on 07.05.2026.
//

import Foundation

enum UITestingConfiguration {
    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("-UITesting")
    }
}

final class UITestingStubWeatherService: WeatherService {

    private let forceDecodeFailure: Bool

    init(forceDecodeFailure: Bool = false) {
        self.forceDecodeFailure = forceDecodeFailure
    }

    func getCurrentWeather(city: String, completion: @escaping (Result<CityModel, WeatherError>) -> Void) {
        if forceDecodeFailure {
            DispatchQueue.main.async {
                completion(.failure(.decodingError))
            }
            return
        }

        let safeName = city.replacingOccurrences(of: "\"", with: "")
        let payload =
            "{\"location\":{\"name\":\"\(safeName)\",\"localtime\":\"2023-02-24 12:00\"}," +
            "\"current\":{\"temp_c\":5,\"condition\":{\"text\":\"Clear\"," +
            "\"icon\":\"//cdn.weatherapi.com/weather/x64/test.png\"}}}"
        let model = payload.data(using: .utf8).flatMap { try? JSONDecoder().decode(CityModel.self, from: $0) }
        guard let model else {
            DispatchQueue.main.async {
                completion(.failure(.decodingError))
            }
            return
        }
        DispatchQueue.main.async {
            completion(.success(model))
        }
    }
}
