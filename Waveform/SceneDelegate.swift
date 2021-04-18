//
//  SceneDelegate.swift
//  Waveform
//
//  Created by Damian Carrillo on 7/5/19.
//  Copyright © 2019 Damian Carrillo. All rights reserved.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else {
          return
        }

        let navigationController = UINavigationController(
            rootViewController: ViewController()
        )

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

}
