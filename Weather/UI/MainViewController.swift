//
//  MainViewController.swift
//  Weather
//
//  Created by Anton Solovev on 15.02.2023.
//

import UIKit

// Главный контроллер приложения
class MainViewController: UIViewController {
    // Элементы интерфейса
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    
    // Приватные свойства
    private lazy var weatherService: WeatherService = WeatherServiceImpl()
    private lazy var lastSearchCitiesProvider: LastSearchCitiesProvider = LastSearchCitiesProviderImpl()
    private var items: [CityTableCellViewModel] = []
    
    // Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadLastSearchedCities()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Убираем дополнительные кнопки с клавиатуры
        searchBar.inputAssistantItem.leadingBarButtonGroups = []
        searchBar.inputAssistantItem.trailingBarButtonGroups = []
    }
    
    // Приватные методы
    private func setupTableView() {
        tableView.register(CityTableCell.nib, forCellReuseIdentifier: CityTableCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func loadLastSearchedCities() {
        let cities = lastSearchCitiesProvider.lastSearchedCities
        fetchWeather(for: cities)
    }
    
    private func fetchWeather(for cities: [String]) {
        items.removeAll()
        tableView.reloadData()
        
        for city in cities {
            weatherService.getCurrentWeather(city: city) { [weak self] result in
                switch result {
                case .success(let model):
                    DispatchQueue.main.async {
                        let viewModel = CityTableCellViewModel(cityModel: model)
                        self?.items.append(viewModel)
                        self?.tableView.reloadData()
                    }
                case .failure(let error):
                    print("Ошибка загрузки для \(city): \(error)")
                }
            }
        }
    }
    
    private func searchCity(_ city: String) {
        weatherService.getCurrentWeather(city: city) { [weak self] result in
            switch result {
            case .success(let model):
                DispatchQueue.main.async {
                    let viewModel = CityTableCellViewModel(cityModel: model)
                    self?.items.insert(viewModel, at: 0)
                    self?.lastSearchCitiesProvider.addCity(city)
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    if error == .cityNotFound {
                        self?.showAlert(title: "Ошибка", message: "Город не найден")
                    } else {
                        self?.showAlert(title: "Ошибка", message: "Не удалось загрузить данные")
                    }
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}

// Источник данных таблицы
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CityTableCell.reuseIdentifier, for: indexPath) as! CityTableCell
        let viewModel = items[indexPath.row]
        cell.configure(with: viewModel)
        return cell
    }
}

// Делегат таблицы
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// Делегат поисковой строки
extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let city = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !city.isEmpty else { return }
        searchCity(city)
        searchBar.resignFirstResponder()
    }
}
