//
//  CityTableCell.swift
//  Weather
//
//  Created by Anton Solovev on 14.02.2023.
//

import UIKit
import SDWebImage

// Кастомная ячейка таблицы для отображения информации о городе и погоде
final class CityTableCell: UITableViewCell {

    // Внутренние типы
    typealias ViewModel = CityTableCellViewModel

    // Элементы интерфейса
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var localTimeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!

    // Статические свойства
    static var reuseIdentifier: String {
        return "CityTableCell"
    }

    static var nib: UINib {
        return .init(nibName: reuseIdentifier, bundle: .main)
    }

    // Публичные методы
    func configure(with viewModel: ViewModel) {
        nameLabel.text = viewModel.name
        localTimeLabel.text = viewModel.localTime
        temperatureLabel.text = viewModel.temperature
        conditionLabel.text = viewModel.conditionText
        
        if let iconURL = viewModel.conditionIconURL,
           let imageURL = URL(string: iconURL) {
            conditionImageView.sd_setImage(with: imageURL)
        }
    }
}
