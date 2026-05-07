//
//  MainViewControllerTests.swift
//  WeatherTests
//
//  Created by Anton Solovev on 07.05.2026.
//

import XCTest
@testable import Weather

private func cityModel(name: String, temp: Double = 10) throws -> CityModel {
    // swiftlint:disable:next line_length
    let json = "{\"location\":{\"name\":\"\(name)\",\"localtime\":\"09:00\"},\"current\":{\"temp_c\":\(temp),\"condition\":{\"text\":\"OK\",\"icon\":\"//host/icon.png\"}}}"
    return try JSONDecoder().decode(CityModel.self, from: Data(json.utf8))
}

private final class MockWeatherService: WeatherService {
    var resultsByCity: [String: Result<CityModel, WeatherError>] = [:]
    var fallback: Result<CityModel, WeatherError> = .failure(.networkError)
    private(set) var requestedCities: [String] = []

    func getCurrentWeather(city: String, completion: @escaping (Result<CityModel, WeatherError>) -> Void) {
        requestedCities.append(city)
        let result = resultsByCity[city] ?? fallback
        DispatchQueue.main.async {
            completion(result)
        }
    }
}

final class MainViewControllerTests: XCTestCase {
    private var window: UIWindow!

    override func setUp() {
        super.setUp()
        window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
    }

    override func tearDown() {
        window?.isHidden = true
        window?.rootViewController = nil
        window = nil
        super.tearDown()
    }

    private func makeSUT(
        weather: WeatherService,
        lastSearch: LastSearchCitiesProvider
    ) throws -> MainViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: MainViewController.self))
        let root = try XCTUnwrap(storyboard.instantiateInitialViewController())
        let nav = try XCTUnwrap(root as? UINavigationController)
        let vc = try XCTUnwrap(nav.topViewController as? MainViewController)
        vc.weatherService = weather
        vc.lastSearchCitiesProvider = lastSearch
        window.rootViewController = nav
        window.makeKeyAndVisible()
        return vc
    }

    private func flushMain(_ timeout: TimeInterval = 2.0) {
        let exp = expectation(description: "main")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: timeout)
    }

    private func waitForTableRows(_ sut: MainViewController, count: Int, timeout: TimeInterval = 3) {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if sut.tableView.numberOfRows(inSection: 0) == count { return }
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.02))
        }
    }

    func testLoadsRowsWhenHistoryReturnsCityAndServiceSucceeds() throws {
        let mock = MockWeatherService()
        mock.resultsByCity["Oslo"] = .success(try cityModel(name: "Oslo", temp: 4))

        let suite = "MainVC.tests.\(UUID().uuidString)"
        let ud = UserDefaults(suiteName: suite)!
        ud.set(["Oslo"], forKey: "lastSearchedCities")

        let sut = try makeSUT(weather: mock, lastSearch: LastSearchCitiesProviderImpl(userDefaults: ud))
        sut.loadViewIfNeeded()

        waitForTableRows(sut, count: 1)
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 1)
        XCTAssertEqual(mock.requestedCities, ["Oslo"])
        ud.removePersistentDomain(forName: suite)
    }

    func testHistoryFetchFailureLeavesTableEmpty() throws {
        let mock = MockWeatherService()
        mock.resultsByCity["Oslo"] = .failure(.networkError)

        let suite = "MainVC.tests.\(UUID().uuidString)"
        let ud = UserDefaults(suiteName: suite)!
        ud.set(["Oslo"], forKey: "lastSearchedCities")

        let sut = try makeSUT(weather: mock, lastSearch: LastSearchCitiesProviderImpl(userDefaults: ud))
        sut.loadViewIfNeeded()

        waitForTableRows(sut, count: 0)
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 0)
        XCTAssertEqual(mock.requestedCities, ["Oslo"])
        ud.removePersistentDomain(forName: suite)
    }

    func testSearchSuccessInsertsRowAndPersistsCity() throws {
        let mock = MockWeatherService()
        mock.resultsByCity["Tallinn"] = .success(try cityModel(name: "Tallinn"))

        let suite = "MainVC.tests.\(UUID().uuidString)"
        let ud = UserDefaults(suiteName: suite)!
        let provider = LastSearchCitiesProviderImpl(userDefaults: ud)

        let sut = try makeSUT(weather: mock, lastSearch: provider)
        sut.loadViewIfNeeded()

        sut.searchBar.text = "Tallinn"
        sut.applySearchQueryForTesting()

        waitForTableRows(sut, count: 1)
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 1)
        XCTAssertEqual(provider.lastSearchedCities.first, "Tallinn")
        ud.removePersistentDomain(forName: suite)
    }

    func testSearchViaSearchBarDelegateInsertsRow() throws {
        let mock = MockWeatherService()
        mock.resultsByCity["Riga"] = .success(try cityModel(name: "Riga"))

        let suite = "MainVC.tests.\(UUID().uuidString)"
        let ud = UserDefaults(suiteName: suite)!
        let sut = try makeSUT(weather: mock, lastSearch: LastSearchCitiesProviderImpl(userDefaults: ud))
        sut.loadViewIfNeeded()

        sut.searchBar.text = "Riga"
        sut.searchBar.delegate?.searchBarSearchButtonClicked?(sut.searchBar)

        waitForTableRows(sut, count: 1)
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 1)
        ud.removePersistentDomain(forName: suite)
    }

    func testSelectingRowDeselects() throws {
        let mock = MockWeatherService()
        mock.resultsByCity["Oslo"] = .success(try cityModel(name: "Oslo"))

        let suite = "MainVC.tests.\(UUID().uuidString)"
        let ud = UserDefaults(suiteName: suite)!
        ud.set(["Oslo"], forKey: "lastSearchedCities")

        let sut = try makeSUT(weather: mock, lastSearch: LastSearchCitiesProviderImpl(userDefaults: ud))
        sut.loadViewIfNeeded()
        waitForTableRows(sut, count: 1)

        let path = IndexPath(row: 0, section: 0)
        sut.tableView.selectRow(at: path, animated: false, scrollPosition: .none)
        sut.tableView.delegate?.tableView?(sut.tableView, didSelectRowAt: path)

        XCTAssertNil(sut.tableView.indexPathForSelectedRow)
        ud.removePersistentDomain(forName: suite)
    }

    func testViewWillAppearClearsSearchAssistantGroups() throws {
        let mock = MockWeatherService()
        let suite = "MainVC.tests.\(UUID().uuidString)"
        let ud = UserDefaults(suiteName: suite)!
        let sut = try makeSUT(weather: mock, lastSearch: LastSearchCitiesProviderImpl(userDefaults: ud))
        sut.loadViewIfNeeded()

        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()

        XCTAssertTrue(sut.searchBar.inputAssistantItem.leadingBarButtonGroups.isEmpty)
        XCTAssertTrue(sut.searchBar.inputAssistantItem.trailingBarButtonGroups.isEmpty)
        ud.removePersistentDomain(forName: suite)
    }

    func testSearchCityNotFoundPresentsAlert() throws {
        let mock = MockWeatherService()
        mock.resultsByCity["Void"] = .failure(.cityNotFound)

        let suite = "MainVC.tests.\(UUID().uuidString)"
        let ud = UserDefaults(suiteName: suite)!
        let sut = try makeSUT(
            weather: mock,
            lastSearch: LastSearchCitiesProviderImpl(userDefaults: ud)
        )
        sut.loadViewIfNeeded()

        sut.searchBar.text = "Void"
        sut.applySearchQueryForTesting()

        let exp = XCTNSPredicateExpectation(predicate: NSPredicate(format: "presentedViewController != nil"), object: sut)
        wait(for: [exp], timeout: 3)

        let alert = sut.presentedViewController as? UIAlertController
        XCTAssertEqual(alert?.title, "Ошибка")
        XCTAssertEqual(alert?.message, "Город не найден")
        ud.removePersistentDomain(forName: suite)
    }

    func testSearchGenericFailurePresentsGenericAlert() throws {
        let mock = MockWeatherService()
        mock.resultsByCity["X"] = .failure(.networkError)

        let suite = "MainVC.tests.\(UUID().uuidString)"
        let ud = UserDefaults(suiteName: suite)!
        let sut = try makeSUT(
            weather: mock,
            lastSearch: LastSearchCitiesProviderImpl(userDefaults: ud)
        )
        sut.loadViewIfNeeded()

        sut.searchBar.text = "X"
        sut.applySearchQueryForTesting()

        let exp = XCTNSPredicateExpectation(predicate: NSPredicate(format: "presentedViewController != nil"), object: sut)
        wait(for: [exp], timeout: 3)

        let alert = sut.presentedViewController as? UIAlertController
        XCTAssertEqual(alert?.message, "Не удалось загрузить данные")
        ud.removePersistentDomain(forName: suite)
    }

    func testEmptySearchDoesNotCallService() throws {
        let mock = MockWeatherService()
        let suite = "MainVC.tests.\(UUID().uuidString)"
        let ud = UserDefaults(suiteName: suite)!
        let sut = try makeSUT(
            weather: mock,
            lastSearch: LastSearchCitiesProviderImpl(userDefaults: ud)
        )
        sut.loadViewIfNeeded()

        sut.searchBar.text = "   "
        sut.applySearchQueryForTesting()

        flushMain()
        XCTAssertTrue(mock.requestedCities.isEmpty)
        ud.removePersistentDomain(forName: suite)
    }
}
