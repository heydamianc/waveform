//
//  AppDelegate.swift
//  Waveform
//
//  Created by Damian Carrillo on 7/5/19.
//  Copyright © 2019 Damian Carrillo. All rights reserved.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        configurationForConnecting session: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfiguration = UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: session.role
        )
        return sceneConfiguration
    }
}
