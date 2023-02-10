//
//  SceneDelegate.swift
//  Weather
//
//  Created by Anton Solovev on 07.02.2023.
//

import UIKit

// Делегат сцены приложения
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Освобождение ресурсов сцены
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Возобновление задач
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Приостановка задач
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Переход на передний план
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Сохранение данных при переходе в фон
    }


}

