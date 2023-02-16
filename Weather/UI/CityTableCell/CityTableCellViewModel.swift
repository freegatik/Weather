//
//  CityTableCellViewModel.swift
//  Weather
//
//  Created by Anton Solovev on 13.02.2023.
//

// Модель представления для ячейки города
public struct CityTableCellViewModel {
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
}
