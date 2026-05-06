//
//  AppDelegate.swift
//  Weather
//
//  Created by Anton Solovev on 07.05.2026.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    enum SceneSessionConfiguration {
        static func configuration(for session: UISceneSession) -> UISceneConfiguration {
            UISceneConfiguration(name: "Default Configuration", sessionRole: session.role)
        }
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return true
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        SceneSessionConfiguration.configuration(for: connectingSceneSession)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
