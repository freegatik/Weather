//
//  WeatherAppLifecycleTests.swift
//  WeatherTests
//
//  Created by Anton Solovev on 07.05.2026.
//

import XCTest
@testable import Weather

@MainActor
final class WeatherAppLifecycleTests: XCTestCase {
    func testAppDelegateDidFinishLaunchingAndDiscardSessions() {
        let sut = AppDelegate()
        XCTAssertTrue(sut.application(UIApplication.shared, didFinishLaunchingWithOptions: nil))
        sut.application(UIApplication.shared, didDiscardSceneSessions: [])
    }

    func testSceneSessionConfigurationUsesDefaultName() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            XCTFail("Expected UIWindowScene from application test host.")
            return
        }
        let cfg = AppDelegate.SceneSessionConfiguration.configuration(for: scene.session)
        XCTAssertEqual(cfg.name, "Default Configuration")
    }

    func testSceneDelegateLifecycleAndWillConnectRouting() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            XCTFail("Expected UIWindowScene from application test host.")
            return
        }
        SceneDelegate.WillConnectRouting.evaluate(scene: scene)

        let sut = SceneDelegate()
        sut.sceneWillEnterForeground(scene)
        sut.sceneDidBecomeActive(scene)
        sut.sceneWillResignActive(scene)
        sut.sceneDidEnterBackground(scene)
        sut.sceneDidDisconnect(scene)
    }
}
