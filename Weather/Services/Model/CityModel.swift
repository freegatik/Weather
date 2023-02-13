//
//  CityModel.swift
//  Weather
//
//  Created by Anton Solovev on 08.02.2023.
//

import Foundation

// Модель данных для представления информации о городе и погоде
struct CityModel: Codable {
    let location: Location
    let current: Current
    
    struct Location: Codable {
        let name: String
        let localtime: String
    }
    
    struct Current: Codable {
        let temp_c: Double
        let condition: Condition
        
        struct Condition: Codable {
            let text: String
            let icon: String
        }
    }
}
