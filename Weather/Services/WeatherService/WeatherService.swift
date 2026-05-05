//
//  WeatherService.swift
//  Weather
//
//  Created by Anton Solovev on 07.05.2026.
//

import Foundation

enum WeatherError: Error, Equatable {
    case networkError
    case decodingError
    case cityNotFound
}

protocol WeatherService: AnyObject {
    func getCurrentWeather(city: String, completion: @escaping (Result<CityModel, WeatherError>) -> Void)
}

final class WeatherServiceImpl: WeatherService {
    private let apiKey = "1fad2589dc4c48c4b58221446251104"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func getCurrentWeather(city: String, completion: @escaping (Result<CityModel, WeatherError>) -> Void) {
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        guard let url = URL(string: "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(encodedCity)") else {
            completion(.failure(.networkError))
            return
        }

        session.dataTask(with: url) { data, _, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(.failure(.networkError))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError))
                }
                return
            }

            let decoder = JSONDecoder()

            do {
                let cityModel = try decoder.decode(CityModel.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(cityModel))
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                    if errorResponse.error?.code == 1006 {
                        DispatchQueue.main.async {
                            completion(.failure(.cityNotFound))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(.decodingError))
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.decodingError))
                    }
                }
            }
        }.resume()
    }
}

private struct ErrorResponse: Codable {
    let error: APIError?
}

private struct APIError: Codable {
    let code: Int
    let message: String
}
