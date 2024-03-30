//
//  AppDelegate.swift
//  ScreenRotatorDemo
//
//  Created by 周健平 on 2022/10/28.
//

import UIKit
import FunnyButton
import ScreenRotator

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    @objc var window: UIWindow? {
        set {}
        get {
            if #available(iOS 13.0, *) {
                guard let scene = UIApplication.shared.connectedScenes.first,
                      let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
                      let window = windowSceneDelegate.window
                else {
                    return nil
                }
                return window
            } else {
                return UIApplication.shared.delegate?.window ?? nil
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        ScreenRotator.shared.isLockOrientationWhenDeviceOrientationDidChange = false
        ScreenRotator.shared.isLockLandscapeWhenDeviceOrientationDidChange = false
        ScreenRotator.shared.orientationMaskDidChange = { orientationMask in
            FunnyButton.orientationMask = orientationMask
        }
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        // OC
        // return JPScreenRotator.sharedInstance().orientationMask
        
        // Swift
        return ScreenRotator.shared.orientationMask
    }
    
}

