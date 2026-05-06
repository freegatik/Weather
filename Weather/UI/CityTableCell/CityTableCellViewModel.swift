//
//  CityTableCellViewModel.swift
//  Weather
//
//  Created by Anton Solovev on 07.05.2026.
//

import Foundation

struct CityTableCellViewModel {
    let name: String?
    let localTime: String?
    let temperature: String?
    let conditionText: String?
    let conditionIconURL: String?

    init(cityModel: CityModel) {
        self.name = cityModel.location.name
        self.localTime = cityModel.location.localtime
        self.temperature = "\(Int(cityModel.current.temp_c))°C"
        self.conditionText = cityModel.current.condition.text
        self.conditionIconURL = "https:\(cityModel.current.condition.icon)"
    }

    init(
        name: String?,
        localTime: String?,
        temperature: String?,
        conditionText: String?,
        conditionIconURL: String?
    ) {
        self.name = name
        self.localTime = localTime
        self.temperature = temperature
        self.conditionText = conditionText
        self.conditionIconURL = conditionIconURL
    }
}
