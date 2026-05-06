//
//  MainViewController.swift
//  Weather
//
//  Created by Anton Solovev on 07.05.2026.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    var weatherService: WeatherService = WeatherServiceImpl()
    var lastSearchCitiesProvider: LastSearchCitiesProvider = LastSearchCitiesProviderImpl()
    private var items: [CityTableCellViewModel] = []

    override func viewDidLoad() {
        if UITestingConfiguration.isUITesting {
            weatherService = UITestingStubWeatherService()
            let suiteName = "Weather.UITest.lastSearched"
            UserDefaults.standard.removePersistentDomain(forName: suiteName)
            lastSearchCitiesProvider = LastSearchCitiesProviderImpl(
                userDefaults: UserDefaults(suiteName: suiteName)!
            )
        }
        super.viewDidLoad()
        setupTableView()
        loadLastSearchedCities()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.inputAssistantItem.leadingBarButtonGroups = []
        searchBar.inputAssistantItem.trailingBarButtonGroups = []
    }

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

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CityTableCell.reuseIdentifier,
            for: indexPath
        ) as? CityTableCell else {
            fatalError("Expected CityTableCell")
        }
        let viewModel = items[indexPath.row]
        cell.configure(with: viewModel)
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let city = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !city.isEmpty else { return }
        searchCity(city)
        searchBar.resignFirstResponder()
    }
}

extension MainViewController {
    func applySearchQueryForTesting() {
        guard let city = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !city.isEmpty else { return }
        searchCity(city)
        searchBar.resignFirstResponder()
    }
}
