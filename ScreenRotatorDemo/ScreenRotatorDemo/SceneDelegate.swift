//
//  SceneDelegate.swift
//  ScreenRotatorDemo
//
//  Created by 周健平 on 2022/10/28.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        MainWindow.shared.windowScene = windowScene
        MainWindow.shared.rootViewController = UINavigationController(rootViewController: MainViewController())
        MainWindow.shared.makeKeyAndVisible()
        
        window = MainWindow.shared
    }

}

